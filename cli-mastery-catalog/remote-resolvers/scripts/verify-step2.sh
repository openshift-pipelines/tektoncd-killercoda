#!/bin/bash
# Verify step 2: The 'git-resolver-demo' TaskRun exists
kubectl get taskrun git-resolver-demo &>/dev/null
