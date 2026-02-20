#!/bin/bash
# Verify step 3: The full-release-pipeline succeeded with results from child
STATUS=$(kubectl get pipelinerun -l tekton.dev/pipeline=full-release-pipeline \
  -o jsonpath='{.items[0].status.conditions[0].status}' 2>/dev/null)
[ "$STATUS" = "True" ]
