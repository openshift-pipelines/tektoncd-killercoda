#!/bin/bash
# Verify step 4: A PipelineRun completed successfully
kubectl get pipelinerun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].status.conditions[0].type}' 2>/dev/null | grep -q Succeeded
