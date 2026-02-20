#!/bin/bash
# Verify step 3: PipelineRun completed and image exists in registry
PR_NAME=$(kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}' 2>/dev/null)
kubectl get pipelinerun "$PR_NAME" -o jsonpath='{.status.conditions[0].status}' 2>/dev/null | grep -q "True" && \
curl -s http://localhost:5000/v2/_catalog 2>/dev/null | grep -q "secure-app"
