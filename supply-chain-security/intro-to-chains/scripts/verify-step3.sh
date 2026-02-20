#!/bin/bash
# Verify step 3: User has verified the signature (cosign.pub exists or signature annotation present)
ls /root/cosign.pub &>/dev/null || \
  kubectl get taskrun --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[-1].metadata.annotations}' 2>/dev/null \
    | grep -q "chains.tekton.dev/signature"
