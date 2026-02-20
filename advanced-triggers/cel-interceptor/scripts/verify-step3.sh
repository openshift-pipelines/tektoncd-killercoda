#!/bin/bash
# Verify step 3: PipelineRun has transformed parameters (branch_name or short_sha)
kubectl get pipelinerun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].spec.params}' 2>/dev/null \
  | grep -q "branch-name\|short-sha"
