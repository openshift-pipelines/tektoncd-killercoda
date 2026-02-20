#!/bin/bash
# Verify step 3: At least one PipelineRun for gitops-ci exists
kubectl get pipelinerun -l tekton.dev/pipeline=gitops-ci --no-headers 2>/dev/null | wc -l | grep -q '[1-9]'
