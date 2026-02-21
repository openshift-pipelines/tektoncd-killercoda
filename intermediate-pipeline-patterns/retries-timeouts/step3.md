# Combine retries, timeouts, and finally for robust pipelines

Now let's build a production-style Pipeline that combines all three error
handling mechanisms: retries for flaky tasks, timeouts for hanging tasks, and
finally Tasks for guaranteed status reporting.

## Create the component Tasks

Create a deploy Task that always succeeds:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: deploy-task
spec:
  steps:
    - name: deploy
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "Deploying application..."
        sleep 5
        echo "Deployment complete!"
EOF
```

Create a status reporter Task that uses the Pipeline's aggregate status:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: report-status
spec:
  params:
    - name: pipeline-status
      type: string
  steps:
    - name: report
      image: alpine:3.19
      script: |
        #!/bin/sh
        STATUS="\$(params.pipeline-status)"
        echo "=============================="
        echo "  PIPELINE STATUS REPORT"
        echo "=============================="
        echo "  Status: \$STATUS"
        echo "=============================="
        if [ "\$STATUS" = "Succeeded" ]; then
          echo "All tasks passed -- pipeline is healthy."
        else
          echo "WARNING: Pipeline had failures."
          echo "Check the PipelineRun for details."
        fi
EOF
```

## Build the robust Pipeline

Now create a Pipeline that ties everything together:

- `flaky-test` - retries up to 3 times on failure
- `deploy` - has a 60-second timeout, only runs after tests pass
- `report-status` - a **finally** Task that always runs and reports the outcome

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: robust-pipeline
spec:
  tasks:
    - name: flaky-test
      taskRef:
        name: flaky-task
      retries: 3
    - name: deploy
      taskRef:
        name: deploy-task
      timeout: "60s"
      runAfter:
        - flaky-test
  finally:
    - name: report-status
      taskRef:
        name: report-status
      params:
        - name: pipeline-status
          value: "\$(tasks.status)"
EOF
```

The key features:
- `retries: 3` on `flaky-test` handles intermittent failures
- `timeout: "60s"` on `deploy` prevents hanging
- `finally` section with `report-status` runs **regardless** of whether the
  Pipeline succeeded or failed
- `$(tasks.status)` is a special Tekton variable that evaluates to `Succeeded`,
  `Failed`, `Completed`, or `None`

## Run the robust Pipeline

Run the Pipeline and watch all three mechanisms in action:

```bash
tkn pipeline start robust-pipeline --showlog
```

You should see:
1. `flaky-test` runs (possibly with retries)
2. If `flaky-test` eventually succeeds, `deploy` runs
3. `report-status` runs at the end, reporting the final status

## Inspect the results

Check the full PipelineRun details:

<!-- e2e-skip -->
```bash
tkn pipelinerun describe --last
```

The output shows:
- Each Task's status and duration
- Retry count for `flaky-test`
- The finally Task execution and its status

## Run again to see different outcomes

Because `flaky-test` is random, running the Pipeline multiple times may produce
different scenarios. Try it again:

```bash
tkn pipeline start robust-pipeline --showlog
```

In some runs, the test may pass on the first try. In others, it may need
retries. In rare cases, all 4 attempts (1 original + 3 retries) may fail,
causing the Pipeline to fail - but `report-status` will still run and report
the failure.

## Production patterns

In production pipelines, you would typically use:

- **Retries** on Tasks that call external services (API calls, image pulls)
- **Timeouts** on Tasks that could hang (long builds, integration tests)
- **Finally Tasks** for notifications (Slack, email), cleanup (delete temp
  resources), and audit logging
