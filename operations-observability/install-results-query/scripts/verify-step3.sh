#!/bin/bash
# Verify step 3: Results API returns data
curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('results', [])
sys.exit(0 if len(results) >= 1 else 1)
" 2>/dev/null
