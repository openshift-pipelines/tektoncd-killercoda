#!/bin/bash
# Verify step 3: TaskRun exists (completed or still paused)
kubectl get taskrun -l tekton.dev/task=buggy-task -o name 2>/dev/null | grep -q taskrun
