#!/bin/bash
# Verify step 3: resolver-demo Pipeline exists and a PipelineRun was created
kubectl get pipeline resolver-demo -o name 2>/dev/null | grep -q "pipeline.tekton.dev/resolver-demo" && \
kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}' 2>/dev/null | grep -q "resolver-demo-run"
