#!/bin/bash
# Verify step 3: The 'hello-goodbye' Pipeline exists and has been run
kubectl get pipeline hello-goodbye &>/dev/null && \
  kubectl get pipelinerun -l tekton.dev/pipeline=hello-goodbye --no-headers 2>/dev/null | grep -q .
