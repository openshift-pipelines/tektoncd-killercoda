#!/bin/bash
# Verify step 1: The 'build-with-config' Task with object param exists
kubectl get task build-with-config &>/dev/null
