#!/bin/bash
# Verify step 2: User has inspected TaskRun details (TaskRuns exist for buggy-pipeline)
kubectl get taskrun -l tekton.dev/pipeline=buggy-pipeline -o name 2>/dev/null | grep -q taskrun
