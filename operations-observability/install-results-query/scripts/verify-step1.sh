#!/bin/bash
# Verify step 1: Results pods are running
kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-results -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q Running
