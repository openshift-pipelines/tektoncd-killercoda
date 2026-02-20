#!/bin/bash
# Verify step 3: The 'shared-task' Task exists in the shared-tasks namespace
kubectl get task shared-task -n shared-tasks &>/dev/null
