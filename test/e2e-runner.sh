#!/usr/bin/env bash
# e2e-runner.sh -- End-to-end test runner for a single Killercoda tutorial
#
# Usage: ./test/e2e-runner.sh <tutorial-path> [--log-dir DIR]
#
# Runs the full tutorial lifecycle on a real Kubernetes cluster:
#   1. Parses index.json for step list, verify scripts, and install script
#   2. Runs install.sh in foreground (5-minute timeout)
#   3. For each step: extracts + runs bash blocks, then runs verify script with retry
#   4. Prints a summary table and exits 0 (all pass) or 1 (any fail)

set -uo pipefail

# ---------------------------------------------------------------------------
# Resolve script directory and source utilities
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
INSTALL_TIMEOUT=300   # 5 minutes for install.sh
BLOCK_TIMEOUT=180     # 3 minutes per bash block
VERIFY_TIMEOUT=60     # 1 minute per verify attempt
VERIFY_RETRIES=3      # retry verify scripts 3 times
VERIFY_DELAY=5        # 5 seconds between verify retries

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
TUTORIAL_PATH=""
LOG_DIR="/tmp/e2e-logs"

usage() {
  echo "Usage: $0 <tutorial-path> [--log-dir DIR]"
  echo ""
  echo "Arguments:"
  echo "  tutorial-path    Path to a tutorial directory (e.g., getting-started/basic-pipeline)"
  echo ""
  echo "Options:"
  echo "  --log-dir DIR    Directory for per-step logs (default: /tmp/e2e-logs)"
  echo ""
  echo "Examples:"
  echo "  $0 getting-started/basic-pipeline"
  echo "  $0 getting-started/basic-pipeline --log-dir ./logs"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --log-dir)
      LOG_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      if [[ -z "$TUTORIAL_PATH" ]]; then
        TUTORIAL_PATH="$1"
      else
        echo "Error: unexpected argument: $1" >&2
        usage
      fi
      shift
      ;;
  esac
done

if [[ -z "$TUTORIAL_PATH" ]]; then
  usage
fi

# ---------------------------------------------------------------------------
# Validate tutorial path
# ---------------------------------------------------------------------------
# Strip trailing slash
TUTORIAL_PATH="${TUTORIAL_PATH%/}"

if [[ ! -d "$TUTORIAL_PATH" ]]; then
  log_error "Tutorial directory not found: ${TUTORIAL_PATH}"
  exit 1
fi

INDEX_FILE="${TUTORIAL_PATH}/index.json"
if [[ ! -f "$INDEX_FILE" ]]; then
  log_error "index.json not found in: ${TUTORIAL_PATH}"
  exit 1
fi

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
mkdir -p "${LOG_DIR}/blocks"

# Cleanup handler
TEMP_FILES=()
cleanup() {
  for f in "${TEMP_FILES[@]:-}"; do
    rm -f "$f" 2>/dev/null || true
  done
}
trap cleanup EXIT

# On SIGINT/SIGTERM: print partial summary, clean up, exit
interrupted=false
handle_interrupt() {
  interrupted=true
  log_warn "Interrupted! Printing partial summary..."
}
trap handle_interrupt INT TERM

# ---------------------------------------------------------------------------
# Parse index.json
# ---------------------------------------------------------------------------
TUTORIAL_TITLE=$(jq -r '.title // "Unknown"' "$INDEX_FILE")
log_info "=== E2E Test: ${TUTORIAL_TITLE} ==="
log_info "Tutorial path: ${TUTORIAL_PATH}"

# Get install script path
INSTALL_SCRIPT=$(jq -r '.details.intro.background // empty' "$INDEX_FILE")

# Get ordered step list
STEP_COUNT=$(jq -r '.details.steps | length' "$INDEX_FILE")
if [[ "$STEP_COUNT" -eq 0 ]]; then
  log_error "No steps found in index.json"
  exit 1
fi

# Build arrays of step texts and verify scripts
declare -a STEP_TEXTS
declare -a VERIFY_SCRIPTS
declare -a STEP_TITLES

for ((i = 0; i < STEP_COUNT; i++)); do
  STEP_TEXTS+=("$(jq -r ".details.steps[$i].text" "$INDEX_FILE")")
  VERIFY_SCRIPTS+=("$(jq -r ".details.steps[$i].verify // empty" "$INDEX_FILE")")
  STEP_TITLES+=("$(jq -r ".details.steps[$i].title // \"Step $((i+1))\"" "$INDEX_FILE")")
done

log_info "Found ${STEP_COUNT} steps"

# ---------------------------------------------------------------------------
# Result tracking
# ---------------------------------------------------------------------------
declare -a RESULT_NAMES
declare -a RESULT_STATUSES
declare -a RESULT_DURATIONS
OVERALL_PASS=true

record_result() {
  RESULT_NAMES+=("$1")
  RESULT_STATUSES+=("$2")
  RESULT_DURATIONS+=("$3")
  if [[ "$2" == "FAIL" ]]; then
    OVERALL_PASS=false
  fi
}

# ---------------------------------------------------------------------------
# Phase 1: Run install.sh
# ---------------------------------------------------------------------------
if [[ -n "$INSTALL_SCRIPT" ]]; then
  INSTALL_PATH="${TUTORIAL_PATH}/${INSTALL_SCRIPT}"
  if [[ -f "$INSTALL_PATH" ]]; then
    log_info "--- Running install script: ${INSTALL_SCRIPT} (timeout: ${INSTALL_TIMEOUT}s) ---"
    INSTALL_LOG="${LOG_DIR}/install.log"
    INSTALL_START=$(date +%s)

    set +e
    run_with_timeout "$INSTALL_TIMEOUT" "install.sh" \
      bash -e "$INSTALL_PATH" >"$INSTALL_LOG" 2>&1
    INSTALL_RC=$?
    set -e

    INSTALL_END=$(date +%s)
    INSTALL_DURATION=$((INSTALL_END - INSTALL_START))

    if [[ $INSTALL_RC -ne 0 ]]; then
      log_fail "Install script failed (exit ${INSTALL_RC}). See: ${INSTALL_LOG}"
      record_result "install" "FAIL" "${INSTALL_DURATION}s"
      # Print summary and exit -- cannot proceed without install
      print_summary_table "${RESULT_NAMES[*]}" "${RESULT_STATUSES[*]}" "${RESULT_DURATIONS[*]}"
      exit 1
    else
      log_pass "Install script completed in ${INSTALL_DURATION}s"
      record_result "install" "PASS" "${INSTALL_DURATION}s"
    fi
  else
    log_warn "Install script referenced but not found: ${INSTALL_PATH}"
  fi
else
  log_info "No install script defined"
fi

# ---------------------------------------------------------------------------
# Phase 2: Execute each step
# ---------------------------------------------------------------------------
for ((step_idx = 0; step_idx < STEP_COUNT; step_idx++)); do
  if [[ "$interrupted" == true ]]; then
    break
  fi

  STEP_NUM=$((step_idx + 1))
  STEP_FILE="${STEP_TEXTS[$step_idx]}"
  STEP_TITLE="${STEP_TITLES[$step_idx]}"
  VERIFY_SCRIPT="${VERIFY_SCRIPTS[$step_idx]}"
  STEP_MD="${TUTORIAL_PATH}/${STEP_FILE}"

  log_info "=== Step ${STEP_NUM}/${STEP_COUNT}: ${STEP_TITLE} ==="

  STEP_START=$(date +%s)
  STEP_PASS=true

  # --- Extract and execute bash blocks ---
  if [[ -f "$STEP_MD" ]]; then
    BLOCKS_OUTPUT=$("${SCRIPT_DIR}/extract-bash-blocks.sh" "$STEP_MD")

    if [[ -z "$BLOCKS_OUTPUT" ]]; then
      log_info "No bash blocks in ${STEP_FILE}"
    else
      BLOCK_NUM=0
      CURRENT_BLOCK=""

      while IFS= read -r line; do
        if [[ "$line" =~ ^---\ BLOCK\ [0-9]+\ ---$ ]]; then
          # Process previous block if any
          if [[ -n "$CURRENT_BLOCK" ]]; then
            BLOCK_NUM=$((BLOCK_NUM))
            BLOCK_FILE="${LOG_DIR}/blocks/step${STEP_NUM}-block${BLOCK_NUM}.sh"
            BLOCK_LOG="${LOG_DIR}/step${STEP_NUM}-block${BLOCK_NUM}.log"
            echo "$CURRENT_BLOCK" > "$BLOCK_FILE"
            TEMP_FILES+=("$BLOCK_FILE")

            log_info "  Running block ${BLOCK_NUM} (timeout: ${BLOCK_TIMEOUT}s)..."
            set +e
            run_with_timeout "$BLOCK_TIMEOUT" "step${STEP_NUM}-block${BLOCK_NUM}" \
              bash -e "$BLOCK_FILE" >"$BLOCK_LOG" 2>&1
            BLOCK_RC=$?
            set -e

            if [[ $BLOCK_RC -ne 0 ]]; then
              log_fail "  Block ${BLOCK_NUM} in ${STEP_FILE} failed (exit ${BLOCK_RC}). See: ${BLOCK_LOG}"
              STEP_PASS=false
            else
              log_pass "  Block ${BLOCK_NUM} passed"
            fi
          fi

          # Start new block
          BLOCK_NUM=$((BLOCK_NUM + 1))
          CURRENT_BLOCK=""
        else
          if [[ -n "$CURRENT_BLOCK" ]]; then
            CURRENT_BLOCK="${CURRENT_BLOCK}
${line}"
          else
            CURRENT_BLOCK="${line}"
          fi
        fi
      done <<< "$BLOCKS_OUTPUT"

      # Process the last block
      if [[ -n "$CURRENT_BLOCK" ]]; then
        BLOCK_FILE="${LOG_DIR}/blocks/step${STEP_NUM}-block${BLOCK_NUM}.sh"
        BLOCK_LOG="${LOG_DIR}/step${STEP_NUM}-block${BLOCK_NUM}.log"
        echo "$CURRENT_BLOCK" > "$BLOCK_FILE"
        TEMP_FILES+=("$BLOCK_FILE")

        log_info "  Running block ${BLOCK_NUM} (timeout: ${BLOCK_TIMEOUT}s)..."
        set +e
        run_with_timeout "$BLOCK_TIMEOUT" "step${STEP_NUM}-block${BLOCK_NUM}" \
          bash -e "$BLOCK_FILE" >"$BLOCK_LOG" 2>&1
        BLOCK_RC=$?
        set -e

        if [[ $BLOCK_RC -ne 0 ]]; then
          log_fail "  Block ${BLOCK_NUM} in ${STEP_FILE} failed (exit ${BLOCK_RC}). See: ${BLOCK_LOG}"
          STEP_PASS=false
        else
          log_pass "  Block ${BLOCK_NUM} passed"
        fi
      fi
    fi
  else
    log_warn "Step file not found: ${STEP_MD}"
    STEP_PASS=false
  fi

  # --- Run verify script with retry ---
  if [[ -n "$VERIFY_SCRIPT" ]]; then
    VERIFY_PATH="${TUTORIAL_PATH}/${VERIFY_SCRIPT}"
    if [[ -f "$VERIFY_PATH" ]]; then
      VERIFY_LOG="${LOG_DIR}/step${STEP_NUM}-verify.log"
      log_info "  Running verify: ${VERIFY_SCRIPT} (retries: ${VERIFY_RETRIES}, delay: ${VERIFY_DELAY}s)"

      set +e
      retry "$VERIFY_RETRIES" "$VERIFY_DELAY" "verify-step${STEP_NUM}" \
        run_with_timeout "$VERIFY_TIMEOUT" "verify-step${STEP_NUM}" \
        bash -e "$VERIFY_PATH" >"$VERIFY_LOG" 2>&1
      VERIFY_RC=$?
      set -e

      if [[ $VERIFY_RC -ne 0 ]]; then
        log_fail "  Verify step${STEP_NUM} failed after ${VERIFY_RETRIES} attempts. See: ${VERIFY_LOG}"
        STEP_PASS=false
      else
        log_pass "  Verify step${STEP_NUM} passed"
      fi
    else
      log_warn "Verify script not found: ${VERIFY_PATH}"
      # Not a failure -- some tutorials may not have verify scripts
    fi
  fi

  # Record step result
  STEP_END=$(date +%s)
  STEP_DURATION=$((STEP_END - STEP_START))

  if [[ "$STEP_PASS" == true ]]; then
    record_result "step${STEP_NUM}" "PASS" "${STEP_DURATION}s"
  else
    record_result "step${STEP_NUM}" "FAIL" "${STEP_DURATION}s"
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
log_info "=== Test Summary: ${TUTORIAL_TITLE} ==="

if [[ ${#RESULT_NAMES[@]} -gt 0 ]]; then
  print_summary_table "${RESULT_NAMES[*]}" "${RESULT_STATUSES[*]}" "${RESULT_DURATIONS[*]}"
fi

PASS_COUNT=0
FAIL_COUNT=0
for status in "${RESULT_STATUSES[@]}"; do
  if [[ "$status" == "PASS" ]]; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

log_info "Results: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"

if [[ "$OVERALL_PASS" == true ]]; then
  log_pass "TUTORIAL PASSED: ${TUTORIAL_TITLE}"
  exit 0
else
  log_fail "TUTORIAL FAILED: ${TUTORIAL_TITLE}"
  exit 1
fi
