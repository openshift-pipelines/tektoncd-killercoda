#!/bin/bash
# Verify step 1: retry-demo Pipeline exists and has been run
kubectl get pipeline retry-demo &>/dev/null && \
  kubectl get pipelinerun -l tekton.dev/pipeline=retry-demo -o name 2>/dev/null | grep -q pipelinerun
