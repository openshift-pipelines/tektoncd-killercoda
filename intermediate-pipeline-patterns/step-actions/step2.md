# Parameterize StepActions for reuse

The real power of StepActions comes when you parameterize them so a single
definition can serve multiple use cases. In this step, you will create a
StepAction with multiple parameters and then build two different Tasks that
reference it with different values.

## Create a flexible StepAction

Create a `format-output` StepAction that can format data in either JSON or plain
text, with a configurable prefix:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: StepAction
metadata:
  name: format-output
spec:
  params:
    - name: format
      type: string
      description: "Output format: json or text"
      default: "text"
    - name: data
      type: string
      description: The data to format
    - name: prefix
      type: string
      description: A prefix label for the output
      default: "OUTPUT"
  image: alpine:3.19
  script: |
    #!/usr/bin/env sh
    if [ "\$(params.format)" = "json" ]; then
      echo "{\"prefix\": \"\$(params.prefix)\", \"data\": \"\$(params.data)\"}"
    else
      echo "[\$(params.prefix)] \$(params.data)"
    fi
EOF
```

This single StepAction can produce two different output formats depending on the
parameters it receives.

## Create a Task that uses JSON format

Create a Task that references `format-output` with JSON formatting:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: json-reporter
  labels:
    tutorial: step-actions
spec:
  params:
    - name: report-data
      type: string
      default: "build-succeeded"
  steps:
    - name: format-as-json
      ref:
        name: format-output
      params:
        - name: format
          value: "json"
        - name: data
          value: "\$(params.report-data)"
        - name: prefix
          value: "BUILD_STATUS"
EOF
```

## Create a Task that uses plain text format

Create a second Task that references the same StepAction but with plain text
formatting:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: text-reporter
  labels:
    tutorial: step-actions
spec:
  params:
    - name: report-data
      type: string
      default: "all-tests-passed"
  steps:
    - name: format-as-text
      ref:
        name: format-output
      params:
        - name: format
          value: "text"
        - name: data
          value: "\$(params.report-data)"
        - name: prefix
          value: "TEST_RESULT"
EOF
```

## Run both Tasks

Run the JSON reporter:

```bash
tkn task start json-reporter --showlog
```

You should see JSON-formatted output like
`{"prefix": "BUILD_STATUS", "data": "build-succeeded"}`.

Run the plain text reporter:

```bash
tkn task start text-reporter --showlog
```

You should see plain text output like `[TEST_RESULT] all-tests-passed`.

## Key observations

1. **One StepAction, two Tasks** -- the `format-output` StepAction is defined
   once but used by both `json-reporter` and `text-reporter`.
2. **Different behavior from different params** -- each Task passes different
   values to the same StepAction, producing different output formats.
3. **Labels for organization** -- both Tasks have the label
   `tutorial: step-actions`, which makes it easy to query them as a group.

Verify that both Tasks exist:

```bash
kubectl get task -l tutorial=step-actions
```
