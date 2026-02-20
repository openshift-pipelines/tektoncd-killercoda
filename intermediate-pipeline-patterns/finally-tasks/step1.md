# Add a Finally Task to a Pipeline

A Pipeline's `finally` section lists Tasks that run after all regular `tasks`
complete. Finally Tasks run in parallel with each other (they cannot have
`runAfter` dependencies), and they are guaranteed to execute regardless of the
outcome of the regular Tasks.

## Create helper Tasks

First, create two regular Tasks and a cleanup Task:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: fetch-source
spec:
  steps:
    - name: fetch
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "Fetching source code..."
        sleep 2
        echo "Source fetched successfully!"
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
        #!/usr/bin/env sh
        echo "Running test suite..."
        sleep 2
        echo "All tests passed!"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: cleanup
spec:
  steps:
    - name: cleanup
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Running cleanup..."
        echo "  Removing temporary files"
        echo "  Releasing resources"
        echo "  Cleanup complete!"
        echo "========================================="
EOF
```

## Create a Pipeline with a Finally Task

Now create a Pipeline that uses the `finally` section:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: finally-demo
spec:
  tasks:
    - name: fetch-source
      taskRef:
        name: fetch-source
    - name: run-tests
      runAfter:
        - fetch-source
      taskRef:
        name: run-tests
  finally:
    - name: cleanup
      taskRef:
        name: cleanup
EOF
```

The `finally` section is at the same level as `tasks`. The `cleanup` Task will
run after both `fetch-source` and `run-tests` complete, regardless of their
outcome.

## Run the Pipeline

```bash
tkn pipeline start finally-demo --showlog
```

Watch the output: `fetch-source` runs first, then `run-tests`, and finally
`cleanup` runs. All three succeed. The cleanup Task ran as the final step
because it was in the `finally` section.

## Verify

```bash
kubectl get pipeline finally-demo
```

You should see the `finally-demo` Pipeline listed. In the next step, you will
see how Finally Tasks run even when regular Tasks fail.
