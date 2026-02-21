#!/bin/bash
# Verify step 1: Jaeger service is accessible
kubectl get svc jaeger-query -n tekton-pipelines &>/dev/null
