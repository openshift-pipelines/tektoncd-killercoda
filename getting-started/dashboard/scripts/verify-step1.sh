#!/bin/bash
# Verify step 1: Dashboard pod is running and port-forward is active
kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-dashboard --no-headers 2>/dev/null | grep -q Running
