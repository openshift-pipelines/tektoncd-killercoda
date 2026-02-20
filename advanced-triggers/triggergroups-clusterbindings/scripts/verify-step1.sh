#!/bin/bash
# Verify step 1: ClusterTriggerBinding exists
kubectl get clustertriggerbinding common-git-fields &>/dev/null
