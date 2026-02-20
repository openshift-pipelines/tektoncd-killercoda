#!/bin/bash
# Verify step 3: Chains signed the image (signed annotation is true)
kubectl get taskrun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null \
  | grep -q "true"
