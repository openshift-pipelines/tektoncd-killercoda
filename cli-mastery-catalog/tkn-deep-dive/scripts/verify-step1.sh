#!/bin/bash
# Verify step 1: At least one TaskRun exists
kubectl get taskrun --no-headers 2>/dev/null | wc -l | grep -q '[1-9]'
