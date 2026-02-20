#!/bin/bash
# Verify step 4: demo-app Deployment exists in the default namespace
kubectl get deployment demo-app --no-headers 2>/dev/null | wc -l | grep -q '[1-9]'
