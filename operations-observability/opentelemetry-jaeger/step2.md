# Generate traces from Pipeline runs

Now let's run a multi-task Pipeline and see the traces appear in Jaeger.

## Create a multi-task Pipeline

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: clone
spec:
  steps:
    - name: clone
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Cloning repository..."
        sleep 3
        echo "Clone complete!"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: lint
spec:
  steps:
    - name: lint
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Running linter..."
        sleep 2
        echo "Lint passed!"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: unit-test
spec:
  steps:
    - name: test
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Running unit tests..."
        sleep 4
        echo "All tests passed!"
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
        #!/usr/bin/env sh
        echo "Building container image..."
        sleep 5
        echo "Image built!"
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: traced-pipeline
spec:
  tasks:
    - name: clone
      taskRef:
        name: clone
    - name: lint
      runAfter: [clone]
      taskRef:
        name: lint
    - name: unit-test
      runAfter: [clone]
      taskRef:
        name: unit-test
    - name: build
      runAfter: [lint, unit-test]
      taskRef:
        name: build-image
EOF
```

## Run the Pipeline

```bash
tkn pipeline start traced-pipeline --showlog
```

The Pipeline has this execution pattern:
- clone (3s) -> lint (2s) + unit-test (4s) in parallel -> build (5s)
- Total wall time: ~12 seconds

## Check traces in Jaeger

```bash
sleep 5
echo "=== Traces should now be visible in Jaeger ==="
echo ""
echo "Open the Jaeger UI (port 16686) and:"
echo "1. Select service: 'tekton-pipelines-controller'"
echo "2. Click 'Find Traces'"
echo "3. You should see the traced-pipeline PipelineRun"
echo "4. Click on the trace to see the span timeline"
echo ""
echo "Each Task and step appears as a span, showing:"
echo "  - Start time and duration"
echo "  - Parent-child relationships"
echo "  - Parallel execution (lint and unit-test overlap)"
```

## Verify

Confirm the Pipeline ran:

```bash
kubectl get pipelinerun -l tekton.dev/pipeline=traced-pipeline -o name | grep -q pipelinerun
```
