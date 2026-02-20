#!/bin/bash
# Verify step 2: At least one PipelineRun for finally-failure-demo exists
kubectl get pipelinerun -l tekton.dev/pipeline=finally-failure-demo --no-headers 2>/dev/null | wc -l | grep -q '[1-9]'
