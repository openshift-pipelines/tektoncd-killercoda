#!/bin/bash
# Verify step 3: A PipelineRun completed successfully
kubectl get pipelinerun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].status.conditions[0].status}' 2>/dev/null | grep -q True
