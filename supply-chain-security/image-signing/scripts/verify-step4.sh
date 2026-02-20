#!/bin/bash
# Verify step 4: attestation exists (check signed annotation or cosign verify-attestation)
cosign verify-attestation --key /root/cosign.pub \
  --type slsaprovenance \
  --insecure-ignore-tlog --allow-insecure-registry \
  localhost:5000/test-image:latest &>/dev/null || \
  kubectl get taskrun --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[-1].metadata.annotations}' 2>/dev/null \
    | grep -q "chains.tekton.dev/signed"
