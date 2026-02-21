# Use StepActions in a Pipeline

Now let's bring everything together by building a Pipeline that uses Tasks which
internally reference shared StepActions. This demonstrates two levels of reuse
working together: **Task-level reuse** (referencing Tasks from a Pipeline via
`taskRef`) and **Step-level reuse** (referencing StepActions from Tasks via
`ref`).

## Create the Pipeline Tasks

First, create a Task that generates some data. This Task uses an inline step
(no StepAction) since it has unique logic:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: generate-data
spec:
  results:
    - name: payload
      description: The generated data payload
  steps:
    - name: generate
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        TIMESTAMP=\$(date +%Y-%m-%dT%H:%M:%S)
        PAYLOAD="deployment-\${TIMESTAMP}"
        echo "Generated payload: \$PAYLOAD"
        echo -n "\$PAYLOAD" > \$(results.payload.path)
EOF
```

Next, create a Task that processes data using the `format-output` StepAction
from the previous step:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: process-data
spec:
  params:
    - name: input-data
      type: string
  results:
    - name: processed
      description: The processed data
  steps:
    - name: format-data
      ref:
        name: format-output
      params:
        - name: format
          value: "json"
        - name: data
          value: "\$(params.input-data)"
        - name: prefix
          value: "PROCESSED"
    - name: save-result
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo -n "processed-\$(params.input-data)" > \$(results.processed.path)
EOF
```

Finally, create a Task that logs the final result using the `log-message`
StepAction from step 1:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: report-result
spec:
  params:
    - name: final-data
      type: string
  steps:
    - name: log-result
      ref:
        name: log-message
      params:
        - name: message
          value: "Pipeline complete -- result: \$(params.final-data)"
EOF
```

## Create the Pipeline

Now wire the three Tasks together in a Pipeline:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: stepaction-pipeline
spec:
  tasks:
    - name: generate
      taskRef:
        name: generate-data
    - name: process
      runAfter:
        - generate
      taskRef:
        name: process-data
      params:
        - name: input-data
          value: "\$(tasks.generate.results.payload)"
    - name: report
      runAfter:
        - process
      taskRef:
        name: report-result
      params:
        - name: final-data
          value: "\$(tasks.process.results.processed)"
EOF
```

## Run the Pipeline

```bash
tkn pipeline start stepaction-pipeline --showlog
```

Watch the output as each Task runs in sequence:

1. **generate** - produces a timestamped payload using an inline step
2. **process** - formats the payload using the `format-output` StepAction, then
   saves a processed result
3. **report** - logs the final result using the `log-message` StepAction

## Inspect the PipelineRun

After the run completes, review the full PipelineRun details:

<!-- e2e-skip -->
```bash
tkn pipelinerun describe --last
```

You can also check the logs for the most recent PipelineRun:

<!-- e2e-skip -->
```bash
tkn pipelinerun logs --last
```

## Understanding the two levels of reuse

This Pipeline demonstrates how Tekton's reuse model works at two levels:

1. **Pipeline to Task** (`taskRef`) - the Pipeline references `generate-data`,
   `process-data`, and `report-result` as reusable Tasks. Any Pipeline can
   reference these same Tasks.
2. **Task to StepAction** (`ref`) - inside `process-data` and `report-result`,
   individual steps reference the shared `format-output` and `log-message`
   StepActions. Any Task can reference these same StepActions.

This two-level composition means you can share logic at the granularity that
makes sense: whole Tasks for coarse-grained reuse, or individual steps for
fine-grained reuse via StepActions.
