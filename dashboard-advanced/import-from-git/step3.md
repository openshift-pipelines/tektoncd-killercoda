# Import Pipelines and manage imported resources

Let's import a Pipeline and see how to manage imported resources in the Dashboard.

## Create and import a Pipeline

```bash
cat <<EOF > /tmp/tekton-repo/pipeline.yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: imported-pipeline
  labels:
    source: git-import
spec:
  tasks:
    - name: greet
      taskRef:
        name: greeting
      params:
        - name: name
          value: "Tekton User"
    - name: stamp
      runAfter: [greet]
      taskRef:
        name: timestamp
EOF

kubectl apply -f /tmp/tekton-repo/pipeline.yaml
echo "Pipeline imported!"
```

## Run the imported Pipeline

```bash
tkn pipeline start imported-pipeline --showlog
```

## Manage imported resources in Dashboard

```bash
echo "=== Managing Imported Resources ==="
echo ""
echo "In the Dashboard UI, you can:"
echo "1. View imported Tasks under 'Tasks' in the sidebar"
echo "2. View imported Pipeline under 'Pipelines'"
echo "3. See PipelineRuns from running imported Pipelines"
echo "4. Delete or update resources through the Dashboard"
echo ""
echo "All imported resources have the label 'source: git-import'"
echo "which makes them easy to find and manage."
echo ""
echo "=== Imported Resources ==="
kubectl get task,pipeline -l source=git-import
```

## Verify

Confirm the imported Pipeline exists:

```bash
kubectl get pipeline imported-pipeline &>/dev/null
```
