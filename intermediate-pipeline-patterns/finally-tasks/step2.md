# Finally Tasks run on failure too

The real value of Finally Tasks is that they execute even when regular Tasks
**fail**. This guarantees your cleanup logic always runs - just like a
`try/finally` block in programming.

## Create a failing Task

Create a Task that intentionally fails:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: failing-task
spec:
  steps:
    - name: fail
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "This task will fail..."
        exit 1
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: notify
spec:
  steps:
    - name: notify
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Notification: Pipeline has finished"
        echo "  Sending alert to team channel..."
        echo "  Alert sent!"
        echo "========================================="
EOF
```

## Create a Pipeline where a Task fails

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: finally-failure-demo
spec:
  tasks:
    - name: fetch-source
      taskRef:
        name: fetch-source
    - name: failing-step
      runAfter:
        - fetch-source
      taskRef:
        name: failing-task
  finally:
    - name: cleanup
      taskRef:
        name: cleanup
    - name: notify
      taskRef:
        name: notify
EOF
```

This Pipeline has two regular Tasks (one will fail) and two Finally Tasks
(cleanup and notify). Both Finally Tasks run in parallel after the regular Tasks
complete.

## Run the Pipeline

```bash
tkn pipeline start finally-failure-demo --showlog
```

Watch carefully:
1. `fetch-source` runs and **succeeds**
2. `failing-step` runs and **fails** (exit 1)
3. Despite the failure, **both** Finally Tasks (`cleanup` and `notify`) still
   run and succeed

## Inspect the PipelineRun

<!-- e2e-skip -->
```bash
tkn pipelinerun describe --last
```

In the output, you will see:
- The overall PipelineRun status is **Failed** (because `failing-step` failed)
- The `failing-step` TaskRun shows as **Failed**
- The `cleanup` and `notify` TaskRuns both show as **Succeeded**

This confirms that Finally Tasks are guaranteed to run, providing a reliable
mechanism for cleanup and notifications regardless of Pipeline outcome.
