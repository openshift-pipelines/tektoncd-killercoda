#!/bin/bash
# Verify step 2: Pipeline exists and at least one PipelineRun succeeded
kubectl get pipeline metrics-pipeline &>/dev/null && \
kubectl get pipelinerun -l tekton.dev/pipeline=metrics-pipeline -o jsonpath='{.items[-1].status.conditions[0].status}' 2>/dev/null | grep -q True
