# Combine multiple When Expressions

When a Task has **multiple When Expressions**, they are **AND-ed** together --
all conditions must be true for the Task to run. If any condition is false, the
Task is skipped.

## Create an approval Task

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: check-approval
spec:
  params:
    - name: approved
      type: string
  results:
    - name: status
      description: The approval status
  steps:
    - name: check
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo -n "\$(params.approved)" > \$(results.status.path)
        echo "Approval status: \$(params.approved)"
EOF
```

## Create a Pipeline with combined When Expressions

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: combined-when-demo
spec:
  params:
    - name: environment
      type: string
      default: "staging"
    - name: approved
      type: string
      default: "false"
  tasks:
    - name: check-approval
      taskRef:
        name: check-approval
      params:
        - name: approved
          value: "\$(params.approved)"
    - name: build
      taskRef:
        name: build-app
    - name: deploy-to-prod
      runAfter:
        - build
        - check-approval
      taskRef:
        name: deploy-app
      params:
        - name: target
          value: "\$(params.environment)"
      when:
        - input: "\$(params.environment)"
          operator: in
          values: ["production"]
        - input: "\$(tasks.check-approval.results.status)"
          operator: in
          values: ["true"]
EOF
```

The `deploy-to-prod` Task has **two** When Expressions:
1. The `environment` must be `"production"`
2. The `approval status` must be `"true"`

Both must be true (AND logic) for deployment to proceed.

## Test: staging environment (skipped)

```bash
tkn pipeline start combined-when-demo \
  -p environment="staging" -p approved="true" --showlog
```

Even though approval is `"true"`, the environment is `"staging"`, not
`"production"` -- so the deploy Task is skipped.

## Test: production with approval (runs)

```bash
tkn pipeline start combined-when-demo \
  -p environment="production" -p approved="true" --showlog
```

Both conditions are met, so the deploy Task runs.

## Important: Skipped Tasks are not failures

Notice that in all cases where a Task was skipped, the overall Pipeline still
**Succeeded**. A skipped Task (due to When Expression) is not a failure -- it
simply did not execute. This is different from a Task that runs and fails.

Verify the latest PipelineRun succeeded:

```bash
tkn pipelinerun describe --last
```

Look at the **Status** section -- skipped Tasks are listed separately from
failed Tasks.
