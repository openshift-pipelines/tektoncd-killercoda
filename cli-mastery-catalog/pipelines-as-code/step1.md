# Install and configure Pipelines as Code

Let's understand PAC and set up the environment.

## How PAC works

```bash
echo "=== Pipelines as Code Workflow ==="
echo ""
echo "1. Developer creates .tekton/*.yaml in their Git repo"
echo "2. Developer pushes code to Git"
echo "3. Git sends a webhook to the PAC controller"
echo "4. PAC reads .tekton/ files from the pushed branch"
echo "5. PAC creates PipelineRuns from those definitions"
echo "6. PAC reports status back to Git (checks, comments)"
echo ""
echo "In this tutorial, we use tkn pac resolve for local testing"
echo "since Killercoda cannot receive external webhooks."
```

## Install PAC controller

```bash
kubectl apply -f https://infra.tekton.dev/tekton-releases/pipelines-as-code/previous/v0.27.1/release.yaml 2>/dev/null || \
  echo "PAC release not available; using local simulation mode"

sleep 5
kubectl get pods -n pipelines-as-code 2>/dev/null || echo "PAC namespace not found (expected in simulation mode)"
```

## Create a sample application repository

```bash
mkdir -p /tmp/my-app/.tekton
cat > /tmp/my-app/main.go << 'GOEOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello from my-app!")
}
GOEOF

cd /tmp/my-app && git init && git add . && git commit -m "Initial commit" 2>/dev/null || true
echo "Sample app repository created at /tmp/my-app"
```

## Verify

```bash
[ -d /tmp/my-app/.tekton ]
```
