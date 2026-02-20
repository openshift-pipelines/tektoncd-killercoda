#!/bin/bash
# Verify step 1: git-credentials Secret and git-bot ServiceAccount exist
kubectl get secret git-credentials &>/dev/null && kubectl get serviceaccount git-bot &>/dev/null
