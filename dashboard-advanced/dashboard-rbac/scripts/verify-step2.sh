#!/bin/bash
# Verify step 2: RBAC roles and bindings are created
kubectl get clusterrole tekton-admin -o name 2>/dev/null | grep -q "clusterrole/tekton-admin" && \
kubectl get clusterrole tekton-viewer -o name 2>/dev/null | grep -q "clusterrole/tekton-viewer" && \
kubectl get rolebinding tekton-admin-binding -n team-alpha -o name 2>/dev/null | grep -q "rolebinding" && \
kubectl get rolebinding tekton-viewer-binding -n team-alpha -o name 2>/dev/null | grep -q "rolebinding"
