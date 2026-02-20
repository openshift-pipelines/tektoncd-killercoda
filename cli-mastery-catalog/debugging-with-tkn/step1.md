# Create intentionally failing Tasks

To practice debugging, we need Pipelines that fail in realistic ways. We will
create Tasks that fail for two common reasons: a wrong container image and a
script error.

## Create a Task with a wrong image

This Task references an image that does not exist. Kubernetes will fail to pull
it, causing an `ImagePullBackOff` error:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: bad-image-task
spec:
  steps:
    - name: run
      image: noexist/this-image-does-not-exist:v999
      script: |
        #!/bin/sh
        echo "This will never run"
EOF
```

## Create a Task with a script error

This Task uses a valid image but the script exits with a non-zero status:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: script-error-task
spec:
  steps:
    - name: compile
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Compiling source code..."
        echo "ERROR: undefined variable 'foo'"
        exit 1
EOF
```

## Create a passing Task for contrast

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: lint-task
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

## Build a Pipeline with all three Tasks

Create a Pipeline that runs the lint Task first, then both failing Tasks:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: buggy-pipeline
spec:
  tasks:
    - name: lint
      taskRef:
        name: lint-task
    - name: build
      taskRef:
        name: script-error-task
      runAfter:
        - lint
    - name: deploy
      taskRef:
        name: bad-image-task
      runAfter:
        - lint
EOF
```

This Pipeline runs `lint` first, then `build` and `deploy` in parallel. Both
`build` and `deploy` will fail, but for different reasons.

## Run the buggy Pipeline

```bash
tkn pipeline start buggy-pipeline --showlog
```

The logs will show `lint` succeeding, then errors from the other Tasks. Do not
worry about the failures -- that is the point! We will debug them in the next
step.

## Quick overview with tkn pipelinerun describe

Get a high-level view of what happened:

```bash
tkn pipelinerun describe --last
```

In the output, look at the **Status** column for each Task. You should see:
- `lint` -- Succeeded
- `build` -- Failed
- `deploy` -- Failed

Note the **Reason** for each failure. This is your first clue about what went
wrong.
