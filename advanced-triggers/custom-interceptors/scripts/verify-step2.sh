#!/bin/bash
# Verify step 2: Custom interceptor pod is running
kubectl get pod -l app=custom-interceptor -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q Running
