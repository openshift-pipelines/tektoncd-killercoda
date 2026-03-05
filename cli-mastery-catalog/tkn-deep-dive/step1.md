# Create resources and explore tkn list/describe

Before we can explore `tkn` commands, we need some Tekton resources to work with.
In this step, you will create a parameterized Task, a Pipeline, and then use
`tkn` to list and describe them.

## Create an echo-greeting Task

This Task accepts two parameters - `greeting` and `name` - and prints a
customized message:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: echo-greeting
spec:
  params:
    - name: greeting
      type: string
      default: "Hello"
      description: The greeting word to use
    - name: name
      type: string
      default: "World"
      description: The name to greet
  steps:
    - name: greet
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "\$(params.greeting), \$(params.name)!"
        echo "Timestamp: \$(date)"
EOF
```

## Create a greeting Pipeline

Now create a Pipeline that runs the `echo-greeting` Task with Pipeline-level
parameters:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: greeting-pipeline
spec:
  params:
    - name: greeting
      type: string
      default: "Hello"
    - name: name
      type: string
      default: "Tekton"
  tasks:
    - name: greet
      taskRef:
        name: echo-greeting
      params:
        - name: greeting
          value: "\$(params.greeting)"
        - name: name
          value: "\$(params.name)"
EOF
```

## List resources with tkn

Use `tkn` to see the Tasks and Pipelines you just created:

<!-- e2e-skip -->
```bash
tkn task list
```

<!-- e2e-skip -->
```bash
tkn pipeline list
```

Notice how `tkn` gives you a clean, human-readable table with the resource name,
creation time, and other useful information - much more focused than a raw
`kubectl get` output.

## Describe resources with tkn

The `describe` command provides detailed information about a specific resource.
Let's inspect the Task:

<!-- e2e-skip -->
```bash
tkn task describe echo-greeting
```

This shows the Task's parameters (with defaults), steps, and workspaces. Now
describe the Pipeline:

<!-- e2e-skip -->
```bash
tkn pipeline describe greeting-pipeline
```

The Pipeline description shows you the full structure: parameters, tasks, and how
they connect. This is invaluable when working with complex Pipelines.

## Run the Task

Now run the Task to create a TaskRun:

<!-- e2e-skip -->
```bash
tkn task start echo-greeting --showlog
```

The `--showlog` flag tells `tkn` to stream the logs in real time as the TaskRun
executes. Without it, `tkn` would print the TaskRun name and return immediately.

After the run completes, describe the latest TaskRun:

<!-- e2e-skip -->
```bash
tkn taskrun describe --last
```

This shows the TaskRun status, parameters used, and timing information. The
`--last` flag is a convenient shortcut that always targets the most recently
created run.
