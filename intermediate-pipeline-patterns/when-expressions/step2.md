# Use Results in When Expressions

When Expressions become even more powerful when combined with Task Results. You
can make a Task's execution depend on the output of a previous Task, enabling
truly dynamic Pipelines.

## Create a branch-checking Task

Create a Task that checks whether a branch name is `main` and emits a Result:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: check-branch
spec:
  params:
    - name: branch
      type: string
  results:
    - name: is-main
      description: "true" if the branch is main, "false" otherwise
  steps:
    - name: check
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        if [ "\$(params.branch)" = "main" ]; then
          echo -n "true" > \$(results.is-main.path)
          echo "Branch is main -- deployment will proceed"
        else
          echo -n "false" > \$(results.is-main.path)
          echo "Branch is \$(params.branch) -- deployment will be skipped"
        fi
EOF
```

## Create a Pipeline with Result-based When Expressions

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: results-when-demo
spec:
  params:
    - name: branch
      type: string
      default: "main"
  tasks:
    - name: check-branch
      taskRef:
        name: check-branch
      params:
        - name: branch
          value: "\$(params.branch)"
    - name: build
      runAfter:
        - check-branch
      taskRef:
        name: build-app
    - name: deploy
      runAfter:
        - build
      taskRef:
        name: deploy-app
      when:
        - input: "\$(tasks.check-branch.results.is-main)"
          operator: in
          values: ["true"]
EOF
```

The `deploy` Task now depends on the `check-branch` Result. If `is-main` is
`"true"`, deployment proceeds; otherwise it is skipped.

## Test with branch=main

```bash
tkn pipeline start results-when-demo -p branch="main" --showlog
```

All three Tasks run: check-branch, build, and deploy.

## Test with branch=feature

```bash
tkn pipeline start results-when-demo -p branch="feature/login" --showlog
```

This time, check-branch and build run, but deploy is **skipped** because
`is-main` was `"false"`.

## Verify both PipelineRuns exist

```bash
tkn pipelinerun list
```

You should see two PipelineRuns for the `results-when-demo` Pipeline -- one
where deploy ran and one where it was skipped.
