#!/bin/bash
# Verify step 4: Result CRDs are browsable via kubectl
kubectl get results.results.tekton.dev -n default --no-headers 2>/dev/null | grep -q .
