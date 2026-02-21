#!/usr/bin/env bash
# extract-bash-blocks.sh -- Extract executable bash blocks from a Markdown file
#
# Usage: ./extract-bash-blocks.sh <path-to-markdown-file>
#
# Outputs each ```bash block separated by a delimiter: --- BLOCK N ---
# Skips ```yaml, ```json, bare ```, and any other fenced code blocks.
# Skips ```bash blocks preceded by an <!-- e2e-skip --> HTML comment.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <markdown-file>" >&2
  exit 1
fi

if [[ ! -f "$1" ]]; then
  echo "Error: file not found: $1" >&2
  exit 1
fi

awk '
BEGIN {
  state = "outside"
  block_num = 0
  skip_next = 0
}
/^[[:space:]]*<!--[[:space:]]*e2e-skip[[:space:]]*-->[[:space:]]*$/ {
  if (state == "outside") {
    skip_next = 1
    next
  }
}
/^```bash[[:space:]]*$/ {
  if (state == "outside") {
    if (skip_next) {
      state = "inside_skip"
      skip_next = 0
      next
    }
    state = "inside_bash"
    block_num++
    print "--- BLOCK " block_num " ---"
    next
  }
}
/^```[a-zA-Z]/ {
  if (state == "outside") {
    state = "inside_other"
    skip_next = 0
    next
  }
}
/^```[[:space:]]*$/ {
  if (state == "inside_bash") {
    state = "outside"
    next
  }
  if (state == "inside_other" || state == "inside_skip") {
    state = "outside"
    next
  }
  if (state == "outside") {
    # Bare ``` fence (no language) -- treat as display-only
    state = "inside_other"
    skip_next = 0
    next
  }
}
{
  if (state == "inside_bash") {
    print
  }
  # Reset skip_next on non-blank, non-comment lines in outside state
  if (state == "outside" && !/^[[:space:]]*$/ && !/^[[:space:]]*<!--/) {
    skip_next = 0
  }
}
' "$1"
