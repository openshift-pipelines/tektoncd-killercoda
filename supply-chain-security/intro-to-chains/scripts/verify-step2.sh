#!/bin/bash
# Verify step 2: TaskRun has chains.tekton.dev/signed=true annotation
kubectl get taskrun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null \
  | grep -q "true"
