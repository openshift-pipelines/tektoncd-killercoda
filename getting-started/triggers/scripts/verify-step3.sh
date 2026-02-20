#!/bin/bash
# Verify step 3: At least one PipelineRun was created by the trigger
kubectl get pipelinerun -l tekton.dev/pipeline=ci-pipeline --no-headers 2>/dev/null | grep -q .
