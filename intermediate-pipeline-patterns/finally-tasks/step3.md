# Access Pipeline status in Finally Tasks

Finally Tasks can access information about the Pipeline's execution using
**context variables**. The most useful are:

- **`$(context.pipelineRun.name)`** -- the name of the current PipelineRun
- **`$(tasks.status)`** -- the aggregate status of all non-finally Tasks:
  `Succeeded`, `Failed`, `Completed` (mix of successes and failures), or `None`
  (no regular Tasks or all skipped)

This lets you build a status reporter that knows whether the Pipeline succeeded
or failed.

## Create a status reporter Task

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: report-status
spec:
  params:
    - name: pipeline-run-name
      type: string
    - name: pipeline-status
      type: string
  steps:
    - name: report
      image: alpine
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Pipeline Status Report"
        echo "-----------------------------------------"
        echo "  PipelineRun: \$(params.pipeline-run-name)"
        echo "  Status:      \$(params.pipeline-status)"
        echo "-----------------------------------------"
        if [ "\$(params.pipeline-status)" = "Succeeded" ]; then
          echo "  Result: ALL TASKS PASSED"
        elif [ "\$(params.pipeline-status)" = "Failed" ]; then
          echo "  Result: ONE OR MORE TASKS FAILED"
        elif [ "\$(params.pipeline-status)" = "Completed" ]; then
          echo "  Result: MIXED (some succeeded, some failed)"
        else
          echo "  Result: NO REGULAR TASKS RAN"
        fi
        echo "========================================="
EOF
```

## Create a Pipeline using context variables

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: status-report-demo
spec:
  tasks:
    - name: build
      taskRef:
        name: fetch-source
    - name: test
      runAfter:
        - build
      taskRef:
        name: run-tests
  finally:
    - name: report-status
      taskRef:
        name: report-status
      params:
        - name: pipeline-run-name
          value: "\$(context.pipelineRun.name)"
        - name: pipeline-status
          value: "\$(tasks.status)"
    - name: cleanup
      taskRef:
        name: cleanup
EOF
```

The `report-status` Finally Task receives the PipelineRun name and the aggregate
Task status as parameters. It can use these to send meaningful notifications.

## Test with a successful Pipeline

```bash
tkn pipeline start status-report-demo --showlog
```

The status report should show `Status: Succeeded` and `ALL TASKS PASSED`.

## Test with a failing Pipeline

Create a variant that includes a failing Task:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: status-report-fail-demo
spec:
  tasks:
    - name: build
      taskRef:
        name: fetch-source
    - name: failing-step
      runAfter:
        - build
      taskRef:
        name: failing-task
  finally:
    - name: report-status
      taskRef:
        name: report-status
      params:
        - name: pipeline-run-name
          value: "\$(context.pipelineRun.name)"
        - name: pipeline-status
          value: "\$(tasks.status)"
EOF
```

```bash
tkn pipeline start status-report-fail-demo --showlog
```

This time the status report shows `Status: Failed` and
`ONE OR MORE TASKS FAILED`. The Finally Task still ran and reported the correct
status, even though the Pipeline itself failed.
