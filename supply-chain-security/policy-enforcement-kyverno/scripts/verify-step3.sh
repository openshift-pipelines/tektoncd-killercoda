#!/bin/bash
# Verify step 3: signed-app deployment exists in secure-deployments namespace
kubectl get deployment signed-app -n secure-deployments -o name 2>/dev/null | \
  grep -q "deployment.apps/signed-app"
