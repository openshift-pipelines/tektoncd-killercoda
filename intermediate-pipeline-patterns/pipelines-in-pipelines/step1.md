# Create a child Pipeline

In the PiP pattern, the **child Pipeline** is a regular Pipeline that can run
independently or be referenced from a parent. Let's create one that simulates
a build-and-test workflow.

## Create the build Task

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: compile
spec:
  params:
    - name: component
      type: string
  results:
    - name: artifact
      type: string
  steps:
    - name: compile
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Compiling component: \$(params.component)"
        ARTIFACT="\$(params.component)-build-\$(date +%s)"
        echo "Produced artifact: \$ARTIFACT"
        echo -n "\$ARTIFACT" > \$(results.artifact.path)
EOF
```

## Create the test Task

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: run-tests
spec:
  params:
    - name: component
      type: string
  results:
    - name: status
      type: string
  steps:
    - name: test
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Running tests for: \$(params.component)"
        echo "All tests passed!"
        echo -n "passed" > \$(results.status.path)
EOF
```

## Create the child Pipeline

This Pipeline takes a `component` parameter and runs compile then test:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: build-pipeline
spec:
  params:
    - name: component
      type: string
  results:
    - name: artifact
      value: "\$(tasks.compile.results.artifact)"
    - name: test-status
      value: "\$(tasks.test.results.status)"
  tasks:
    - name: compile
      taskRef:
        name: compile
      params:
        - name: component
          value: "\$(params.component)"
    - name: test
      runAfter:
        - compile
      taskRef:
        name: run-tests
      params:
        - name: component
          value: "\$(params.component)"
EOF
```

This child Pipeline is a complete, self-contained workflow. It accepts a
`component` parameter and exposes `artifact` and `test-status` as Pipeline
results.

## Verify

Confirm the child Pipeline exists:

```bash
kubectl get pipeline build-pipeline
```
