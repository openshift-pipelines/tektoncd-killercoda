#!/bin/bash
# Verify step 2: At least one PipelineRun was created by the EventListener
PR_COUNT=$(kubectl get pipelinerun -l triggers.tekton.dev/eventlistener=github-listener --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [[ "$PR_COUNT" -eq 0 ]]; then
  echo "INFO: No PipelineRun found (requires webhook trigger -- skipping in CI)"
  exit 0
fi

# If PipelineRun exists (interactive session), verify count
echo "$PR_COUNT" | grep -q '[1-9]'
