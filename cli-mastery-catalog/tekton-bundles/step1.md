# Create and push a Tekton Bundle

A Tekton Bundle is an OCI artifact that contains one or more Tekton
resources (Tasks, Pipelines). You create bundles using the `tkn bundle push`
command and store them in any OCI-compliant container registry.

## Create a Task

First, create a Task YAML file that we will package into a bundle:

```bash
cat <<'EOF' > /root/my-task.yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: my-task
  labels:
    app.kubernetes.io/version: "1.0"
spec:
  params:
    - name: message
      type: string
      default: "Hello from a Tekton Bundle!"
  steps:
    - name: print-message
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "$(params.message)"
        echo "This Task was loaded from an OCI bundle!"
EOF
```

Verify the file was created:

```bash
cat /root/my-task.yaml
```

## Push the Task as a Bundle

Use `tkn bundle push` to package the Task YAML and push it to the local
registry:

```bash
tkn bundle push localhost:5000/my-task-bundle:v1 -f /root/my-task.yaml
```

The command outputs the bundle digest, confirming it was pushed successfully.

## Verify the bundle is in the registry

Check that the bundle exists in the registry using the OCI distribution API:

```bash
curl -s http://localhost:5000/v2/_catalog | python3 -m json.tool
```

You should see `my-task-bundle` in the repositories list.

List the tags for the bundle:

```bash
curl -s http://localhost:5000/v2/my-task-bundle/tags/list | python3 -m json.tool
```

You should see the `v1` tag.

## Inspect the bundle contents

Use `tkn bundle list` to see what resources are inside the bundle:

```bash
tkn bundle list localhost:5000/my-task-bundle:v1
```

This shows the Task name and kind that were packaged into the bundle.
The bundle is now stored in the registry and can be referenced by any
PipelineRun in the cluster.
