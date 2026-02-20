#!/bin/bash
# Verify step 2: TriggerBinding, TriggerTemplate, and EventListener exist
kubectl get triggerbinding github-push-binding &>/dev/null && \
  kubectl get triggertemplate github-push-template &>/dev/null && \
  kubectl get eventlistener github-listener &>/dev/null
