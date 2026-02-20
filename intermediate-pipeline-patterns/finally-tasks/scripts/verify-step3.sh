#!/bin/bash
# Verify step 3: Latest PipelineRun completed (succeeded or failed with finally tasks running)
kubectl get pipelinerun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].status.conditions[0].status}' 2>/dev/null | grep -qE '(True|False)'
