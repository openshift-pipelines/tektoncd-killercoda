# Set up Buildpacks Task from catalog

Let's install the Buildpacks Task and verify the local registry.

## Verify the local registry

```bash
kubectl get svc registry
kubectl get pod -l app=registry
```

## Install the Buildpacks Task

Create a Task that uses the Buildpacks lifecycle:

```bash
cat <<TASKEOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: buildpacks
spec:
  params:
    - name: APP_IMAGE
      type: string
      description: The image to build
    - name: SOURCE_SUBPATH
      type: string
      default: ""
    - name: BUILDER_IMAGE
      type: string
      default: "paketobuildpacks/builder-jammy-tiny:latest"
  workspaces:
    - name: source
  steps:
    - name: build
      image: \$(params.BUILDER_IMAGE)
      command: ["/cnb/lifecycle/creator"]
      args:
        - "-app=\$(workspaces.source.path)/\$(params.SOURCE_SUBPATH)"
        - "-cache-dir=/tmp/buildpacks-cache"
        - "\$(params.APP_IMAGE)"
      securityContext:
        runAsUser: 0
      env:
        - name: CNB_PLATFORM_API
          value: "0.12"
TASKEOF

echo "Buildpacks Task installed!"
kubectl get task buildpacks
```

## Verify

```bash
kubectl get task buildpacks &>/dev/null
```
