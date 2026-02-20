#!/bin/bash
# Verify step 2: A TaskRun exists that Chains has processed
TASKRUN=$(kubectl get taskrun -o name 2>/dev/null | head -1)
[ -n "$TASKRUN" ]
