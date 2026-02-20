#!/bin/bash
# Verify step 4: unsigned image was pushed to registry
curl -s http://localhost:5000/v2/_catalog 2>/dev/null | grep -q "unsigned-app"
