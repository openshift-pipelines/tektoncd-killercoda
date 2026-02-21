# Understand the PAC workflow

Let's explore the full PAC workflow and see how it works in production.

## The production workflow

```bash
echo "=== Production PAC Workflow ==="
echo ""
echo "1. Setup (one-time):"
echo "   - Install PAC controller in the cluster"
echo "   - Create a GitHub/GitLab App or webhook"
echo "   - Configure PAC Repository CRD"
echo ""
echo "2. Development cycle:"
echo "   - Developer creates/updates .tekton/*.yaml"
echo "   - Developer pushes to Git"
echo "   - PAC receives webhook event"
echo "   - PAC creates PipelineRun from .tekton/"
echo "   - Pipeline results appear as Git status checks"
echo ""
echo "3. PR workflow:"
echo "   - Developer opens a Pull Request"
echo "   - PAC runs the on-event: [pull_request] Pipeline"
echo "   - Results posted as PR checks"
echo "   - Merge triggers on-event: [push] Pipeline"
```

## Create a pull request Pipeline

```bash
cat > /tmp/my-app/.tekton/pull-request.yaml << 'YAMLEOF'
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: my-app-pr
  annotations:
    pipelinesascode.tekton.dev/on-event: "[pull_request]"
    pipelinesascode.tekton.dev/on-target-branch: "[main]"
spec:
  pipelineSpec:
    tasks:
      - name: lint
        taskSpec:
          steps:
            - name: lint
              image: alpine:3.19
              script: |
                #!/usr/bin/env sh
                echo "Linting PR changes..."
                echo "Lint passed!"
      - name: test
        taskSpec:
          steps:
            - name: test
              image: alpine:3.19
              script: |
                #!/usr/bin/env sh
                echo "Running PR tests..."
                echo "All tests passed!"
YAMLEOF

echo "Created .tekton/pull-request.yaml"
echo ""
echo "=== .tekton/ directory ==="
ls -la /tmp/my-app/.tekton/
```

## Verify

```bash
[ -f /tmp/my-app/.tekton/pull-request.yaml ]
```
