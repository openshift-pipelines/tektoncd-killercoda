# Create a Task that writes to a Workspace

## Understanding Workspaces

A **Workspace** is declared in a Task's `spec.workspaces` field. Each Workspace
has a name and is mounted as a directory inside the Task's Steps. By default,
a Workspace named `my-workspace` is available at `/workspace/my-workspace`.

## Create the write-message Task

Let's create a Task that writes a message to a file in a Workspace:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: write-message
spec:
  workspaces:
    - name: shared-data
      description: A workspace to write the message to
  params:
    - name: message
      type: string
      description: The message to write
      default: "Hello from the first Task!"
  steps:
    - name: write
      image: ubuntu:22.04
      script: |
        #!/usr/bin/env bash
        echo "\$(params.message)" > \$(workspaces.shared-data.path)/message.txt
        echo "Wrote message to workspace:"
        cat \$(workspaces.shared-data.path)/message.txt
EOF
```

Notice the key elements:
- `spec.workspaces` declares a Workspace named `shared-data`
- `$(workspaces.shared-data.path)` gives the mount path of the Workspace
- `spec.params` defines a configurable `message` parameter

## Run the Task

Run the Task with an `emptyDir` volume as the Workspace:

```bash
tkn task start write-message \
  --workspace name=shared-data,emptyDir="" \
  --param message="Hello from Tekton Workspaces!" \
  --showlog
```

You should see the message written to the Workspace:

```
[write] Wrote message to workspace:
[write] Hello from Tekton Workspaces!
```
