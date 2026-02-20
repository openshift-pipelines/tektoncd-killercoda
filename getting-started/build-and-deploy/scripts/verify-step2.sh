#!/bin/bash
# Verify step 2: build-image and deploy-app Tasks exist
kubectl get task build-image &>/dev/null && kubectl get task deploy-app &>/dev/null
