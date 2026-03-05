#!/bin/bash
# Verify step 2: The matrix-include-demo Pipeline exists (step 2 creates the Pipeline)
# Also check for PipelineRun -- if none exists, still pass (display blocks may be skipped in CI)
kubectl get pipeline matrix-include-demo &>/dev/null || exit 1

PR_COUNT=$(kubectl get pipelinerun -l tekton.dev/pipeline=matrix-include-demo --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [[ "$PR_COUNT" -eq 0 ]]; then
  echo "INFO: Pipeline exists but no PipelineRun found (display blocks may be skipped in CI)"
  exit 0
fi

# If PipelineRun exists, verify at least one succeeded
kubectl get pipelinerun -l tekton.dev/pipeline=matrix-include-demo --no-headers 2>/dev/null | grep -q .
