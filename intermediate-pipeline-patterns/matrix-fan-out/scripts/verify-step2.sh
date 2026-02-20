#!/bin/bash
# Verify step 2: At least 6 fan-out TaskRuns exist for the 'test' PipelineTask
[ "$(kubectl get taskrun -l tekton.dev/pipelineTask=test --no-headers 2>/dev/null | wc -l)" -ge 6 ]
