#!/bin/bash
# Verify step 1: The 'hub-resolver-demo' TaskRun exists
kubectl get taskrun hub-resolver-demo &>/dev/null
