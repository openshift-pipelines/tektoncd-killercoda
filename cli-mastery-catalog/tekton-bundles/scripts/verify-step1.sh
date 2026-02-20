#!/bin/bash
# Verify step 1: Bundle was pushed to the local registry
curl -s http://localhost:5000/v2/my-task-bundle/tags/list 2>/dev/null | grep -q "v1"
