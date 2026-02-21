#!/bin/bash
# Verify step 3: Multiple PipelineRuns exist
COUNT=$(kubectl get pipelinerun -l tekton.dev/pipeline=traced-pipeline -o name 2>/dev/null | wc -l | tr -d ' ')
[ "$COUNT" -ge 2 ]
