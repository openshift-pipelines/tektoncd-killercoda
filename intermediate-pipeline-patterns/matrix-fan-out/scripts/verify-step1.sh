#!/bin/bash
# Verify step 1: The 'matrix-demo' Pipeline exists
kubectl get pipeline matrix-demo &>/dev/null
