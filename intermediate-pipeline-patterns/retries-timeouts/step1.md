# Configure Task-level retries

In CI/CD, some tasks are inherently flaky -- a test might fail due to a
transient network issue, or a deployment might fail because a pod took too long
to start. Tekton lets you add **retries** to a PipelineTask so it will
automatically re-run when it fails.

## Create a flaky Task

First, create a Task that randomly fails about 50% of the time. This simulates
a flaky test or an unreliable external call:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: flaky-task
spec:
  steps:
    - name: maybe-fail
      image: alpine:3.19
      script: |
        #!/bin/sh
        RAND=\$((RANDOM % 2))
        echo "Random value: \$RAND"
        if [ "\$RAND" -eq 0 ]; then
          echo "FAIL: The task failed this time!"
          exit 1
        fi
        echo "SUCCESS: The task passed this time!"
EOF
```

## Create a Pipeline with retries

Now create a Pipeline that uses this flaky Task with `retries: 3`. Tekton will
automatically re-run the Task up to 3 additional times if it fails:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: retry-demo
spec:
  tasks:
    - name: flaky-test
      taskRef:
        name: flaky-task
      retries: 3
EOF
```

The key line is `retries: 3` -- this tells Tekton: "If this Task fails, retry
it up to 3 more times before marking the Pipeline as failed."

## Run the Pipeline

Start the Pipeline and follow the logs:

```bash
tkn pipeline start retry-demo --showlog
```

Depending on the random result, you may see the Task succeed on the first
attempt or after one or more retries.

## Inspect retry behavior

Use `tkn pipelinerun describe` to see the retry details:

```bash
tkn pipelinerun describe --last
```

In the output, look at the **TaskRuns** section. If the Task was retried, you
will see a `Retries` count and the status of each attempt.

You can also see retry details in the raw Kubernetes object:

```bash
kubectl get pipelinerun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].status.childReferences}' | python3 -m json.tool
```

## Understanding retry behavior

Key things to understand about retries:

- **Retries create new TaskRun pods** -- each retry is a fresh execution
- **All Steps re-run** -- there is no partial retry; the entire Task re-runs
- **Retries only happen on failure** -- if a Task succeeds, no retry occurs
- **The Pipeline succeeds if any retry succeeds** -- even if the first 3
  attempts fail, if the 4th succeeds, the Pipeline continues normally

Run the Pipeline a second time to observe potentially different retry behavior:

```bash
tkn pipeline start retry-demo --showlog
```
