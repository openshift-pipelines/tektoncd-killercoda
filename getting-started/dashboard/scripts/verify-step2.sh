#!/bin/bash
# Verify step 2: Both hello and goodbye Tasks exist
kubectl get task hello &>/dev/null && kubectl get task goodbye &>/dev/null
