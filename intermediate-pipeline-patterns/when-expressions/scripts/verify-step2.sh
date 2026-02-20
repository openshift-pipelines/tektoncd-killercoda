#!/bin/bash
# Verify step 2: At least one PipelineRun for results-when-demo exists
kubectl get pipelinerun -l tekton.dev/pipeline=results-when-demo --no-headers 2>/dev/null | wc -l | grep -q '[1-9]'
