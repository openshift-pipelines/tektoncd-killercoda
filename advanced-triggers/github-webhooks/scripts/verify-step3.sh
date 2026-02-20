#!/bin/bash
# Verify step 3: A PipelineRun was triggered with refs/heads/main in params
kubectl get pipelinerun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].spec.params}' 2>/dev/null \
  | grep -q "refs/heads/main"
