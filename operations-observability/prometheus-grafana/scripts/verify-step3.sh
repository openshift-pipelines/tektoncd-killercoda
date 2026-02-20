#!/bin/bash
# Verify step 3: Grafana has the Tekton dashboard
curl -s http://admin:admin@localhost:3000/api/search?query=Tekton 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
sys.exit(0 if len(data) >= 1 else 1)
" 2>/dev/null
