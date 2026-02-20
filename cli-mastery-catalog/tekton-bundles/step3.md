# Bundle versioning and multi-resource bundles

Tekton Bundles support versioning through OCI tags, just like container
images. You can also package multiple Tasks into a single bundle. This makes
bundles a powerful distribution mechanism for reusable CI/CD components.

## Push a v2 of the Task

Let's update the Task and push it as a new version:

```bash
cat <<'EOF' > /root/my-task-v2.yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: my-task
  labels:
    app.kubernetes.io/version: "2.0"
spec:
  params:
    - name: message
      type: string
      default: "Hello from Bundle v2!"
  steps:
    - name: print-message
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== Bundle v2 ==="
        echo "$(params.message)"
        echo "New in v2: enhanced output formatting"
        echo "=================="
EOF
```

Push it with a `v2` tag:

```bash
tkn bundle push localhost:5000/my-task-bundle:v2 -f /root/my-task-v2.yaml
```

Verify both versions exist:

```bash
curl -s http://localhost:5000/v2/my-task-bundle/tags/list | python3 -m json.tool
```

You should see both `v1` and `v2` tags.

## Create a multi-resource bundle

Bundles can contain multiple Tasks. Let's create two Tasks and package them
together:

```bash
cat <<'EOF' > /root/task-lint.yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: lint
spec:
  steps:
    - name: lint
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Running linter..."
        echo "All checks passed!"
EOF
```

```bash
cat <<'EOF' > /root/task-test.yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: test
spec:
  steps:
    - name: test
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Running tests..."
        echo "3/3 tests passed!"
EOF
```

Push both Tasks into a single bundle:

```bash
tkn bundle push localhost:5000/multi-bundle:v1 -f /root/task-lint.yaml -f /root/task-test.yaml
```

## Inspect the multi-resource bundle

```bash
tkn bundle list localhost:5000/multi-bundle:v1
```

You should see both `lint` and `test` Tasks listed.

## Use both Tasks from the multi-resource bundle

Create a Pipeline that references both Tasks from the same bundle:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: multi-bundle-pipeline
spec:
  tasks:
    - name: lint-step
      taskRef:
        resolver: bundles
        params:
          - name: bundle
            value: "localhost:5000/multi-bundle:v1"
          - name: name
            value: "lint"
          - name: kind
            value: task
    - name: test-step
      taskRef:
        resolver: bundles
        params:
          - name: bundle
            value: "localhost:5000/multi-bundle:v1"
          - name: name
            value: "test"
          - name: kind
            value: task
      runAfter:
        - lint-step
EOF
```

Run it:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: multi-bundle-run-
spec:
  pipelineRef:
    name: multi-bundle-pipeline
EOF
```

```bash
kubectl wait --for=condition=Succeeded pipelinerun -l tekton.dev/pipeline=multi-bundle-pipeline --timeout=120s
```

```bash
tkn pipelinerun logs --last -f
```

You should see output from both the `lint` and `test` Tasks, both loaded
from the same bundle.

## Version comparison

Finally, let's verify that the v1 and v2 bundles contain different versions
of the same Task:

```bash
echo "=== Bundle v1 contents ==="
tkn bundle list localhost:5000/my-task-bundle:v1
echo ""
echo "=== Bundle v2 contents ==="
tkn bundle list localhost:5000/my-task-bundle:v2
echo ""
echo "=== Multi-bundle contents ==="
tkn bundle list localhost:5000/multi-bundle:v1
```

With OCI tags, you can pin PipelineRuns to specific versions, roll back to
previous versions, and manage Task distribution the same way you manage
container images.
