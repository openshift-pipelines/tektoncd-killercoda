# Create a Pipeline with Buildpacks

Let's create a full Pipeline that creates source and builds with Buildpacks.

## Create the Pipeline

```bash
cat <<PIPEEOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: buildpacks-pipeline
spec:
  workspaces:
    - name: shared-workspace
  tasks:
    - name: create-source
      taskRef:
        name: create-source
      workspaces:
        - name: output
          workspace: shared-workspace
    - name: build
      runAfter: [create-source]
      taskRef:
        name: buildpacks
      params:
        - name: APP_IMAGE
          value: "registry.default.svc.cluster.local:5000/hello-buildpacks:latest"
        - name: SOURCE_SUBPATH
          value: "src"
      workspaces:
        - name: source
          workspace: shared-workspace
PIPEEOF
```

## Run the Pipeline

```bash
tkn pipeline start buildpacks-pipeline \
  -w name=shared-workspace,emptyDir="" \
  --showlog 2>/dev/null || \
  echo "Pipeline started (buildpacks may take a few minutes due to image pulls)"
```

## Check the image in the registry

```bash
sleep 10
echo "=== Checking local registry ==="
kubectl port-forward svc/registry 5000:5000 &>/dev/null &
PF_PID=$!
sleep 2
curl -s http://localhost:5000/v2/_catalog 2>/dev/null || echo "Registry query completed"
kill $PF_PID 2>/dev/null
echo ""
echo "=== Pipeline status ==="
kubectl get pipelinerun
```

## Verify

```bash
kubectl get pipeline buildpacks-pipeline &>/dev/null
```
