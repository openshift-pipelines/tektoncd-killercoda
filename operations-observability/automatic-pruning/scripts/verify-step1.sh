#!/bin/bash
# Verify step 1: At least 5 TaskRuns exist
[ "$(kubectl get taskrun --no-headers 2>/dev/null | wc -l)" -ge 5 ]
