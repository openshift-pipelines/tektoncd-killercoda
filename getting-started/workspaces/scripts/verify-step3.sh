#!/bin/bash
# Verify step 3: Pipeline exists and has been run
kubectl get pipeline message-pipeline &>/dev/null && \
  kubectl get pipelinerun -l tekton.dev/pipeline=message-pipeline --no-headers 2>/dev/null | grep -q .
