# Run Pipelines and view logs in Dashboard

## Create a Pipeline with detailed output

Create a Pipeline that generates meaningful log output across multiple Tasks:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: lint-code
spec:
  steps:
    - name: lint
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== LINT PHASE ==="
        echo "[INFO] Scanning source files for style violations..."
        echo "[PASS] main.go: no issues"
        echo "[PASS] handler.go: no issues"
        echo "[WARN] utils.go: line 42 - unused variable 'tmp'"
        echo "[INFO] Lint completed: 0 errors, 1 warning"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: run-tests
spec:
  steps:
    - name: test
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== TEST PHASE ==="
        echo "[INFO] Starting test suite..."
        echo "  PASS: TestCreateUser (0.03s)"
        echo "  PASS: TestDeleteUser (0.01s)"
        echo "  PASS: TestListUsers (0.05s)"
        echo "  PASS: TestUpdateUser (0.02s)"
        echo "  PASS: TestAuthMiddleware (0.10s)"
        echo "[RESULT] 5 passed, 0 failed"
        echo "[SUCCESS] All tests passed at $(date -u)"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-image
spec:
  steps:
    - name: build
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== BUILD PHASE ==="
        echo "[INFO] Building container image..."
        echo "[INFO] Layer 1/4: base OS (alpine:3.19)"
        echo "[INFO] Layer 2/4: install dependencies"
        echo "[INFO] Layer 3/4: copy application binary"
        echo "[INFO] Layer 4/4: set entrypoint"
        echo "[INFO] Image built: myapp:v1.0.$(date +%s)"
        echo "[SUCCESS] Build completed at $(date -u)"
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: ci-pipeline
spec:
  tasks:
    - name: lint
      taskRef:
        name: lint-code
    - name: test
      taskRef:
        name: run-tests
      runAfter:
        - lint
    - name: build
      taskRef:
        name: build-image
      runAfter:
        - test
EOF
```

## Run the Pipeline

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: ci-pipeline-run-1
spec:
  pipelineRef:
    name: ci-pipeline
EOF
```

Wait for completion:

```bash
kubectl wait --for=condition=Succeeded pipelinerun/ci-pipeline-run-1 --timeout=120s
```

## View logs while pods exist

At this point, both the Dashboard and `tkn` can show logs because the pods
still exist:

```bash
tkn pipelinerun logs ci-pipeline-run-1
```

The Dashboard (at http://localhost:9097) would show the same logs by reading
directly from the pods.

## Wait for Results to capture the logs

Give the Results watcher time to capture the completed run:

```bash
sleep 15
```

Verify Results captured the run:

```bash
kubectl get results.results.tekton.dev -n default
```

## Delete the pods

Now simulate pruning by deleting the pods:

```bash
kubectl delete pod -l tekton.dev/pipelineRun=ci-pipeline-run-1
```

Confirm the pods are gone:

```bash
kubectl get pods -l tekton.dev/pipelineRun=ci-pipeline-run-1
```

## Verify the Dashboard can still show logs

With the `--external-logs` configuration, the Dashboard automatically falls
back to the Results API when pod logs are unavailable. Let's verify Results
still has the data:

```bash
kubectl port-forward -n tekton-pipelines svc/tekton-results-api-service 8080:8080 &
sleep 3

curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('results', [])
print(f'Results stored: {len(results)}')
for r in results:
    print(f'  - {r[\"name\"]}')
"
```

The PipelineRun still appears in Results. When you navigate to this
PipelineRun in the Dashboard, it queries the Results API and displays the
logs - even though the pods no longer exist.

This is the critical difference: **without** Results, the Dashboard would
show "Unable to fetch logs" after pod deletion. **With** Results, logs are
seamlessly available from the external backend.
