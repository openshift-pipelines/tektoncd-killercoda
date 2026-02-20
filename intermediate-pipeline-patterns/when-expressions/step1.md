# Skip a Task with When Expressions

A When Expression is specified in the `when` field of a Pipeline Task. It
evaluates an `input` against a list of `values` using an `operator` (`in` or
`notin`). If the condition is not met, the Task is **skipped** -- it does not
run, but the Pipeline continues.

## Create helper Tasks

First, create two simple Tasks:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-app
spec:
  steps:
    - name: build
      image: alpine
      script: |
        #!/usr/bin/env sh
        echo "Building the application..."
        sleep 2
        echo "Build complete!"
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: deploy-app
spec:
  params:
    - name: target
      type: string
      default: "production"
  steps:
    - name: deploy
      image: alpine
      script: |
        #!/usr/bin/env sh
        echo "Deploying to \$(params.target)..."
        sleep 1
        echo "Deployment complete!"
EOF
```

## Create a Pipeline with a When Expression

Now create a Pipeline where the `deploy-app` Task only runs when the `deploy`
parameter is `"true"`:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: conditional-demo
spec:
  params:
    - name: deploy
      type: string
      default: "false"
      description: Set to "true" to enable deployment
  tasks:
    - name: build
      taskRef:
        name: build-app
    - name: deploy
      runAfter:
        - build
      taskRef:
        name: deploy-app
      when:
        - input: "\$(params.deploy)"
          operator: in
          values: ["true"]
EOF
```

The `when` block on the `deploy` Task means: "Only run this Task if the
`deploy` parameter is `in` the list `["true"]`."

## Run with deployment disabled

```bash
tkn pipeline start conditional-demo -p deploy="false" --showlog
```

Notice that the `deploy` Task is **skipped** -- only the `build` Task runs. The
Pipeline still completes successfully because a skipped Task is not a failure.

## Run with deployment enabled

```bash
tkn pipeline start conditional-demo -p deploy="true" --showlog
```

This time both Tasks run: `build` followed by `deploy`. The When Expression
evaluated to true, so the gate was opened.
