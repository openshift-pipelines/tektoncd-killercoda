#!/bin/bash
# Verify step 4: demo-app Deployment was updated to nginx:1.26 by auto-sync
kubectl get deployment demo-app -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null | grep -q 'nginx:1.2'
