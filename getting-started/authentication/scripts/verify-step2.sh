#!/bin/bash
# Verify step 2: registry-credentials Secret and build-bot ServiceAccount exist
kubectl get secret registry-credentials &>/dev/null && kubectl get serviceaccount build-bot &>/dev/null
