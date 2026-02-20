#!/bin/bash
# Verify step 1: signing-secrets exists and a TaskRun has been signed
kubectl get secret signing-secrets -n tekton-chains &>/dev/null && \
  kubectl get taskrun --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[-1].metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null \
    | grep -q "true"
