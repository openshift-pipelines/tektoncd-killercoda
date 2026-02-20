#!/bin/bash
# Verify step 2: Pod exists for the debug TaskRun
POD=$(kubectl get taskrun -l tekton.dev/task=buggy-task -o jsonpath='{.items[0].status.podName}' 2>/dev/null)
[ -n "$POD" ]
