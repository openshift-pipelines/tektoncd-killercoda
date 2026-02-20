# Set timeouts at Task and Pipeline level

While retries handle intermittent failures, **timeouts** protect your Pipeline
from Tasks that hang indefinitely. You can set timeouts at multiple levels:

- **PipelineTask timeout** - limits how long a single Task can run
- **PipelineRun timeouts** - limits the overall Pipeline execution time

## Create a slow Task

First, create a Task that intentionally takes a long time:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: slow-task
spec:
  steps:
    - name: slow-work
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Starting slow operation..."
        sleep 60
        echo "Slow operation complete!"
EOF
```

Also create a fast Task for comparison:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: fast-task
spec:
  steps:
    - name: quick-work
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Quick task completed successfully!"
EOF
```

## Create a Pipeline with Task-level timeout

Create a Pipeline where the slow Task has a 30-second timeout. Since the Task
sleeps for 60 seconds, it will be killed before completing:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: timeout-demo
spec:
  tasks:
    - name: quick-step
      taskRef:
        name: fast-task
    - name: slow-step
      taskRef:
        name: slow-task
      timeout: "30s"
      runAfter:
        - quick-step
EOF
```

## Run and observe the Task-level timeout

```bash
tkn pipeline start timeout-demo --showlog
```

You will see the `quick-step` Task succeed, then `slow-step` will start but
be terminated after 30 seconds. The PipelineRun will fail because `slow-step`
timed out.

Check the result:

```bash
tkn pipelinerun describe --last
```

Look for the **Status** of `slow-step` - it should show as `Failed` with a
reason related to the timeout.

## Use PipelineRun-level timeouts

You can also set timeouts on the PipelineRun itself. This controls:
- `spec.timeouts.pipeline` - total time for the entire Pipeline
- `spec.timeouts.tasks` - total time allowed for all non-finally Tasks
- `spec.timeouts.finally` - total time allowed for finally Tasks

Create and run a PipelineRun with Pipeline-level timeouts:

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: timeout-run-
spec:
  pipelineRef:
    name: timeout-demo
  timeouts:
    pipeline: "2m"
    tasks: "1m"
EOF
```

Watch the PipelineRun:

```bash
sleep 5
tkn pipelinerun describe --last
```

Since `spec.timeouts.tasks` is set to `1m` and the slow Task sleeps for 60
seconds (but has a 30-second PipelineTask timeout), the Task-level timeout will
fire first.

## Timeout precedence

The effective timeout is the **minimum** of all applicable timeouts:

1. PipelineTask `timeout` field (30s in our example)
2. PipelineRun `spec.timeouts.tasks` (1m in our example)
3. PipelineRun `spec.timeouts.pipeline` (2m in our example)

The most restrictive timeout wins. In our case, the 30-second Task-level
timeout fires before the 1-minute tasks timeout.
