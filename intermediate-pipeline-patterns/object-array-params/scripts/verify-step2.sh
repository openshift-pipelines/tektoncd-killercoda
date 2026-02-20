#!/bin/bash
# Verify step 2: The 'run-with-flags' Task with array params exists
kubectl get task run-with-flags &>/dev/null
