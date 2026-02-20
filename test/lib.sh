#!/usr/bin/env bash
# lib.sh -- Shared utility functions for E2E tutorial testing
# Sourced by e2e-runner.sh. Provides logging, retry, timeout, and summary utilities.

set -euo pipefail

# ---------------------------------------------------------------------------
# Color constants (respect NO_COLOR environment variable)
# ---------------------------------------------------------------------------
if [[ -z "${NO_COLOR:-}" ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BOLD='\033[1m'
  NC='\033[0m' # No Color
else
  RED=''
  GREEN=''
  YELLOW=''
  BOLD=''
  NC=''
fi

# ---------------------------------------------------------------------------
# Logging functions
# ---------------------------------------------------------------------------
_timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log_info() {
  echo -e "${BOLD}[$(_timestamp)] INFO:${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}[$(_timestamp)] WARN:${NC} $*" >&2
}

log_error() {
  echo -e "${RED}[$(_timestamp)] ERROR:${NC} $*" >&2
}

log_pass() {
  echo -e "${GREEN}[$(_timestamp)] PASS:${NC} $*"
}

log_fail() {
  echo -e "${RED}[$(_timestamp)] FAIL:${NC} $*"
}

# ---------------------------------------------------------------------------
# run_with_timeout SECONDS DESCRIPTION CMD...
#
# Runs CMD with a timeout of SECONDS. On timeout, kills process group and
# returns 124. Otherwise returns CMD's exit code.
# ---------------------------------------------------------------------------
run_with_timeout() {
  local timeout_secs="$1"
  local description="$2"
  shift 2

  # Prefer the 'timeout' command if available (coreutils on Linux)
  if command -v timeout &>/dev/null; then
    timeout --signal=KILL "${timeout_secs}" "$@"
    local rc=$?
    if [[ $rc -eq 137 || $rc -eq 124 ]]; then
      log_error "TIMEOUT: ${description} after ${timeout_secs}s"
      return 124
    fi
    return $rc
  fi

  # Fallback for macOS: background + wait + kill
  "$@" &
  local pid=$!
  local count=0

  while [[ $count -lt $timeout_secs ]]; do
    if ! kill -0 "$pid" 2>/dev/null; then
      # Process has exited
      wait "$pid"
      return $?
    fi
    sleep 1
    count=$((count + 1))
  done

  # Timeout reached -- kill the process
  kill -KILL "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  log_error "TIMEOUT: ${description} after ${timeout_secs}s"
  return 124
}

# ---------------------------------------------------------------------------
# retry COUNT DELAY_SECONDS DESCRIPTION CMD...
#
# Runs CMD up to COUNT times, sleeping DELAY_SECONDS between attempts.
# Returns 0 on first success. Returns last exit code on all-fail.
# ---------------------------------------------------------------------------
retry() {
  local max_attempts="$1"
  local delay="$2"
  local description="$3"
  shift 3

  local attempt=1
  local rc=0

  while [[ $attempt -le $max_attempts ]]; do
    log_info "Attempt ${attempt}/${max_attempts}: ${description}"
    set +e
    "$@"
    rc=$?
    set -e

    if [[ $rc -eq 0 ]]; then
      return 0
    fi

    if [[ $attempt -lt $max_attempts ]]; then
      log_warn "Attempt ${attempt} failed (exit ${rc}), retrying in ${delay}s..."
      sleep "$delay"
    fi
    attempt=$((attempt + 1))
  done

  log_error "All ${max_attempts} attempts failed for: ${description}"
  return $rc
}

# ---------------------------------------------------------------------------
# print_summary_table STEP_NAMES_ARRAY STATUSES_ARRAY DURATIONS_ARRAY
#
# Prints a formatted ASCII summary table. Arrays are passed as space-separated
# strings via positional parameters.
#
# Usage:
#   print_summary_table "step1 step2 step3" "PASS FAIL PASS" "12s 45s 8s"
# ---------------------------------------------------------------------------
print_summary_table() {
  local -a names=($1)
  local -a statuses=($2)
  local -a durations=($3)
  local count=${#names[@]}

  # Determine max width for step name column
  local max_name_len=4 # minimum: "Step"
  for name in "${names[@]}"; do
    if [[ ${#name} -gt $max_name_len ]]; then
      max_name_len=${#name}
    fi
  done

  # Print header
  local sep
  sep=$(printf '+-%-*s-+--------+----------+' "$max_name_len" "" | tr ' ' '-')
  echo ""
  echo "$sep"
  printf '| %-*s | Status | Duration |\n' "$max_name_len" "Step"
  echo "$sep"

  # Print rows
  for ((i = 0; i < count; i++)); do
    local status_colored
    if [[ "${statuses[$i]}" == "PASS" ]]; then
      status_colored="${GREEN} PASS ${NC}"
    else
      status_colored="${RED} FAIL ${NC}"
    fi
    printf "| %-*s |${status_colored}| %8s |\n" "$max_name_len" "${names[$i]}" "${durations[$i]}"
  done

  echo "$sep"
  echo ""
}
