#!/bin/bash
# Verify step 3: Build privilege test TaskRun succeeded
kubectl get taskrun build-privilege-test -o jsonpath='{.status.conditions[0].status}' 2>/dev/null | grep -q "True"
