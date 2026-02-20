#!/bin/bash
# Verify step 1: TaskRun with debug breakpoint exists
kubectl get taskrun -l tekton.dev/task=buggy-task -o name 2>/dev/null | grep -q taskrun
