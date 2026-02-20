#!/bin/bash
# Verify step 1: Results is running
kubectl get pods -l app.kubernetes.io/part-of=tekton-results -n tekton-pipelines -o name 2>/dev/null | grep -q pod
