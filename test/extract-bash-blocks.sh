#!/usr/bin/env bash
# extract-bash-blocks.sh -- Extract executable bash blocks from a Markdown file
#
# Usage: ./extract-bash-blocks.sh <path-to-markdown-file>
#
# Outputs each ```bash block separated by a delimiter: --- BLOCK N ---
# Skips ```yaml, ```json, bare ```, and any other fenced code blocks.

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
}
/^```bash[[:space:]]*$/ {
  if (state == "outside") {
    state = "inside_bash"
    block_num++
    print "--- BLOCK " block_num " ---"
    next
  }
}
/^```[a-zA-Z]/ {
  if (state == "outside") {
    state = "inside_other"
    next
  }
}
/^```[[:space:]]*$/ {
  if (state == "inside_bash") {
    state = "outside"
    next
  }
  if (state == "inside_other") {
    state = "outside"
    next
  }
  if (state == "outside") {
    # Bare ``` fence (no language) -- treat as display-only
    state = "inside_other"
    next
  }
}
{
  if (state == "inside_bash") {
    print
  }
}
' "$1"
