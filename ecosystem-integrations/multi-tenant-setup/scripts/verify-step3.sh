#!/bin/bash
kubectl get resourcequota tekton-quota -n team-a &>/dev/null && \
kubectl get task shared-lint -n shared-tasks &>/dev/null
