#!/bin/bash
# Verify step 3: buggy-pipeline has a successful run (the fixed run)
kubectl get pipelinerun -l tekton.dev/pipeline=buggy-pipeline \
  -o jsonpath='{.items[-1].status.conditions[0].status}' 2>/dev/null | grep -q True
