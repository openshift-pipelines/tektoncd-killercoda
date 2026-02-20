#!/bin/bash
# Verify step 3: Pipeline exists and has been run
kubectl get pipeline build-and-deploy &>/dev/null && \
  kubectl get pipelinerun -l tekton.dev/pipeline=build-and-deploy --no-headers 2>/dev/null | grep -q .
