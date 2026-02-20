#!/bin/bash
# Verify step 3: Pipeline exists and at least one PipelineRun was created
kubectl get pipeline hello-goodbye &>/dev/null && \
  kubectl get pipelinerun -l tekton.dev/pipeline=hello-goodbye --no-headers 2>/dev/null | grep -q .
