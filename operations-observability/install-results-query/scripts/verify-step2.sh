#!/bin/bash
# Verify step 2: PipelineRun succeeded
kubectl get pipelinerun -l tekton.dev/pipeline=greeting-pipeline -o jsonpath='{.items[-1].status.conditions[0].status}' 2>/dev/null | grep -q True
