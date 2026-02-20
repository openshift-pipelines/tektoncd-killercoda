#!/bin/bash
# Verify step 3: robust-pipeline exists and has been run
kubectl get pipeline robust-pipeline &>/dev/null && \
  kubectl get pipelinerun -l tekton.dev/pipeline=robust-pipeline -o name 2>/dev/null | grep -q pipelinerun
