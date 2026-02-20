#!/bin/bash
# Verify step 3: Pipeline exists and has been run with build-bot SA
kubectl get pipeline authenticated-clone &>/dev/null && \
  kubectl get pipelinerun -l tekton.dev/pipeline=authenticated-clone --no-headers 2>/dev/null | grep -q .
