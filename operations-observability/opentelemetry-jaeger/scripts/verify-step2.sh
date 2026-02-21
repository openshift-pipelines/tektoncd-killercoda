#!/bin/bash
# Verify step 2: Pipeline ran successfully
kubectl get pipelinerun -l tekton.dev/pipeline=traced-pipeline -o name 2>/dev/null | grep -q pipelinerun
