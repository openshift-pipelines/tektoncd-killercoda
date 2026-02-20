#!/bin/bash
# Verify step 1: Feature flags ConfigMap or TektonConfig exists
kubectl get configmap feature-flags -n tekton-pipelines &>/dev/null || \
  kubectl get tektonconfig config &>/dev/null
