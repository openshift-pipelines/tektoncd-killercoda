#!/bin/bash
# Verify step 3: Multi-bundle exists and Pipeline using it succeeded
curl -s http://localhost:5000/v2/multi-bundle/tags/list 2>/dev/null | grep -q "v1" && \
kubectl get pipelinerun -l tekton.dev/pipeline=multi-bundle-pipeline -o jsonpath='{.items[-1].status.conditions[0].status}' 2>/dev/null | grep -q True
