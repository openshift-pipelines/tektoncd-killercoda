#!/bin/bash
# Verify step 2: The parent 'release-pipeline' exists and a child PipelineRun was created
kubectl get pipeline release-pipeline &>/dev/null && \
kubectl get pipelinerun -l tekton.dev/pipeline=build-pipeline -o name | grep -q pipelinerun
