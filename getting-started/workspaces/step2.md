# Create a Task that reads from a Workspace

Now let's create a second Task that reads from the same Workspace. This
demonstrates how data written by one Task can be consumed by another.

## Create the read-message Task

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: read-message
spec:
  workspaces:
    - name: shared-data
      description: A workspace to read the message from
  steps:
    - name: read
      image: ubuntu
      script: |
        #!/usr/bin/env bash
        echo "Reading message from workspace:"
        cat \$(workspaces.shared-data.path)/message.txt
EOF
```

This Task declares the same Workspace name `shared-data`. When both Tasks are
used in a Pipeline, they can be wired to the same underlying volume.

## Verify both Tasks exist

```bash
tkn task list
```

You should see both `write-message` and `read-message` Tasks listed.
