# Build a Pipeline with shared Workspaces

Now let's create a Pipeline that passes the same Workspace to both Tasks, so
the `read-message` Task can read the file created by the `write-message` Task.

## Create the Pipeline

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: message-pipeline
spec:
  workspaces:
    - name: shared-workspace
      description: Workspace shared between tasks
  params:
    - name: message
      type: string
      default: "Hello from the Pipeline!"
  tasks:
    - name: write
      taskRef:
        name: write-message
      params:
        - name: message
          value: \$(params.message)
      workspaces:
        - name: shared-data
          workspace: shared-workspace
    - name: read
      runAfter:
        - write
      taskRef:
        name: read-message
      workspaces:
        - name: shared-data
          workspace: shared-workspace
EOF
```

Notice how Workspaces are wired:
- The Pipeline declares a Workspace named `shared-workspace`
- Each Task maps its own Workspace name (`shared-data`) to the Pipeline's
  Workspace (`shared-workspace`)
- Because both Tasks use the same Pipeline Workspace, they share the same volume

## Run the Pipeline

Run the Pipeline using a PersistentVolumeClaim so data persists between Tasks:

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: message-pipeline-run-
spec:
  pipelineRef:
    name: message-pipeline
  params:
    - name: message
      value: "Workspaces are working!"
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF
```

## Check the logs

```bash
tkn pipelinerun logs --last -f
```

You should see:

```
[write : write] Wrote message to workspace:
[write : write] Workspaces are working!

[read : read] Reading message from workspace:
[read : read] Workspaces are working!
```

The `read` Task successfully read the message that the `write` Task wrote to
the shared Workspace. This is the foundation for real CI/CD workflows where
Tasks share source code, build artifacts, and other data.
