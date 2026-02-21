# Access the Import feature

Let's open the Dashboard and find the Import page.

## Port-forward the Dashboard

```bash
kubectl port-forward svc/tekton-dashboard -n tekton-pipelines 9097:9097 &>/dev/null &
echo "Dashboard available at: http://localhost:9097"
echo "On Killercoda, use the Traffic/Ports tab to access port 9097"
```

## Navigate to the Import page

```bash
echo "=== Accessing the Import Feature ==="
echo ""
echo "1. Open the Dashboard UI (port 9097)"
echo "2. Click the '+' icon in the sidebar or navigate to 'Import Tekton resources'"
echo "3. You will see a form with fields for:"
echo "   - Repository URL (Git URL)"
echo "   - Repository path (subdirectory within the repo)"
echo "   - Target namespace"
echo "   - Service Account"
echo ""
echo "The Import feature creates a PipelineRun that:"
echo "  1. Clones the Git repository"
echo "  2. Finds YAML files at the specified path"
echo "  3. Applies them to the target namespace"
```

## Verify

Confirm the Dashboard is accessible:

```bash
kubectl get svc tekton-dashboard -n tekton-pipelines &>/dev/null
```
