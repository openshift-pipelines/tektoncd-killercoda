#!/bin/bash
STATUS=$(kubectl get pipelinerun -l tekton.dev/pipeline=migrated-pipeline -o jsonpath='{.items[0].status.conditions[0].status}' 2>/dev/null)
[ "$STATUS" = "True" ]
