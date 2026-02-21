# Create a PipelineRun definition in .tekton/

PAC looks for PipelineRun YAML files in the `.tekton/` directory.

## Create a push Pipeline

```bash
cat > /tmp/my-app/.tekton/push.yaml << 'YAMLEOF'
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: my-app-push
  annotations:
    pipelinesascode.tekton.dev/on-event: "[push]"
    pipelinesascode.tekton.dev/on-target-branch: "[main]"
    pipelinesascode.tekton.dev/max-keep-runs: "3"
spec:
  pipelineSpec:
    tasks:
      - name: build
        taskSpec:
          steps:
            - name: build
              image: alpine:3.19
              script: |
                #!/usr/bin/env sh
                echo "Building my-app..."
                echo "Commit: $(git rev-parse HEAD 2>/dev/null || echo 'unknown')"
                echo "Build complete!"
      - name: test
        runAfter: [build]
        taskSpec:
          steps:
            - name: test
              image: alpine:3.19
              script: |
                #!/usr/bin/env sh
                echo "Running tests..."
                echo "All tests passed!"
YAMLEOF

echo "Created .tekton/push.yaml"
echo ""
echo "Key PAC annotations:"
echo "  on-event: [push]       - Trigger on push events"
echo "  on-target-branch: [main] - Only for the main branch"
echo "  max-keep-runs: 3       - Keep only 3 most recent runs"
```

## Test locally with tkn pac resolve

```bash
cd /tmp/my-app
tkn pac resolve -f .tekton/push.yaml 2>/dev/null || \
  echo "tkn-pac resolve not available; applying PipelineRun directly"

# Apply the PipelineRun directly for testing
kubectl apply -f .tekton/push.yaml 2>/dev/null || \
  cat .tekton/push.yaml | kubectl create -f - 2>/dev/null || true
```

## Verify

```bash
[ -f /tmp/my-app/.tekton/push.yaml ]
```
