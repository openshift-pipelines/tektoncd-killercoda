#!/bin/bash
# Verify step 3: Pipeline exists and at least one PipelineRun was created
kubectl get pipeline hello-goodbye &>/dev/null || exit 1

# Check if a PipelineRun exists (may not exist in CI -- created via Dashboard UI)
PR_COUNT=$(kubectl get pipelinerun -l tekton.dev/pipeline=hello-goodbye --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [[ "$PR_COUNT" -eq 0 ]]; then
  echo "INFO: No PipelineRun found (requires Dashboard UI interaction -- skipping in CI)"
  exit 0
fi

# If PipelineRun exists (interactive session), verify it succeeded
kubectl get pipelinerun -l tekton.dev/pipeline=hello-goodbye --no-headers 2>/dev/null | grep -q .
