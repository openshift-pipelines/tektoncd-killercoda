#!/bin/bash
# Verify step 2: timeout-demo Pipeline exists and has been run
kubectl get pipeline timeout-demo &>/dev/null && \
  kubectl get pipelinerun -l tekton.dev/pipeline=timeout-demo -o name 2>/dev/null | grep -q pipelinerun
