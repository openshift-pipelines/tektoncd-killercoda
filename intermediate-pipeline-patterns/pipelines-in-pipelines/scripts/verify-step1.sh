#!/bin/bash
# Verify step 1: The child 'build-pipeline' Pipeline exists
kubectl get pipeline build-pipeline &>/dev/null
