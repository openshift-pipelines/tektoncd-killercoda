#!/bin/bash
kubectl get rolebinding team-a-tekton-binding -n team-a &>/dev/null && \
kubectl get rolebinding team-b-tekton-binding -n team-b &>/dev/null
