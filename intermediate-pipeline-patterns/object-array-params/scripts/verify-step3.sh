#!/bin/bash
# Verify step 3: The 'structured-data-pipeline' Pipeline succeeded
STATUS=$(kubectl get pipelinerun -l tekton.dev/pipeline=structured-data-pipeline \
  -o jsonpath='{.items[0].status.conditions[0].status}' 2>/dev/null)
[ "$STATUS" = "True" ]
