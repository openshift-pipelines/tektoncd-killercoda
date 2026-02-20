#!/bin/bash
# Verify step 1: buggy-pipeline exists and has been run
kubectl get pipeline buggy-pipeline &>/dev/null && \
  kubectl get pipelinerun -l tekton.dev/pipeline=buggy-pipeline -o name 2>/dev/null | grep -q pipelinerun
