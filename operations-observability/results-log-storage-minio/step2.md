# Run Pipelines and verify logs are stored

Now that Results is configured to store logs in MinIO, let's run a Pipeline
with verbose output and prove the logs survive pod deletion.

## Create a Pipeline with multiple Tasks

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-step
spec:
  steps:
    - name: build
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== BUILD PHASE ==="
        echo "[INFO] Fetching dependencies from registry..."
        sleep 2
        echo "[INFO] Compiling main.go..."
        echo "[INFO] Compiling utils.go..."
        echo "[INFO] Compiling handlers.go..."
        echo "[INFO] Build output: /workspace/bin/app (4.2MB)"
        echo "[SUCCESS] Build completed at $(date -u)"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: test-step
spec:
  steps:
    - name: test
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== TEST PHASE ==="
        echo "[INFO] Running unit tests..."
        echo "  PASS: TestUserCreate (0.02s)"
        echo "  PASS: TestUserDelete (0.01s)"
        echo "  PASS: TestOrderProcess (0.15s)"
        echo "  PASS: TestPaymentValidation (0.03s)"
        echo "[INFO] Running integration tests..."
        echo "  PASS: TestAPIEndpoints (1.2s)"
        echo "  PASS: TestDatabaseConnections (0.8s)"
        echo "[RESULT] 6 passed, 0 failed, 0 skipped"
        echo "[SUCCESS] Tests completed at $(date -u)"
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: build-and-test
spec:
  tasks:
    - name: build
      taskRef:
        name: build-step
    - name: test
      taskRef:
        name: test-step
      runAfter:
        - build
EOF
```

## Run the Pipeline

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: build-and-test-run-1
spec:
  pipelineRef:
    name: build-and-test
EOF
```

Wait for the PipelineRun to complete:

```bash
kubectl wait --for=condition=Succeeded pipelinerun/build-and-test-run-1 --timeout=120s
```

View the logs while the pods still exist:

```bash
tkn pipelinerun logs build-and-test-run-1
```

You should see the detailed build and test output.

## Give Results time to capture the logs

The Results watcher needs a few moments to detect the completed run and upload
the logs to MinIO:

```bash
sleep 15
```

## Delete the pods

Now delete the TaskRun pods -- simulating what happens during pruning or garbage
collection:

```bash
kubectl delete pod -l tekton.dev/pipelineRun=build-and-test-run-1
```

Confirm the pods are gone:

```bash
kubectl get pods -l tekton.dev/pipelineRun=build-and-test-run-1
```

You should see "No resources found" -- the pods and their logs are deleted.

## Retrieve logs from the Results API

Even though the pods are gone, the logs were stored in MinIO by Results. Let's
access them through the Results API. First, port-forward the Results API
service:

```bash
kubectl port-forward -n tekton-pipelines svc/tekton-results-api-service 8080:8080 &
sleep 3
```

List all results in the default namespace:

```bash
curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results | python3 -m json.tool | head -30
```

Get the logs for the PipelineRun. First, find the result and its records:

```bash
RESULT_UID=$(curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results | python3 -c "
import sys, json
data = json.load(sys.stdin)
for r in data.get('results', []):
    print(r['name'])
" | head -1)
echo "Result: ${RESULT_UID}"
```

List the records (which include log references):

```bash
curl -sk "https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/${RESULT_UID}/records" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for r in data.get('records', []):
    rtype = r.get('data', {}).get('type', 'unknown')
    print(f\"  Record: {r['name']} (type: {rtype})\")
"
```

The key insight: the PipelineRun metadata and TaskRun data is still accessible
through Results, even though the pods have been deleted from the cluster.
