#!/bin/bash
# Verify step 2: image exists in local registry
curl -s http://localhost:5000/v2/_catalog 2>/dev/null | grep -q "test-image" || \
  kubectl get taskrun --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[-1].status.conditions[0].status}' 2>/dev/null | grep -q "True"
