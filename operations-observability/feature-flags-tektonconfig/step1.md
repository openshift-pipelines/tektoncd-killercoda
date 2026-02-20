# Explore available feature flags

Let's explore the feature flags that control Tekton Pipeline behavior.

## View the TektonConfig resource

The Operator creates a TektonConfig when installed:

```bash
kubectl get tektonconfig config -o yaml 2>/dev/null || \
  echo "TektonConfig not found (Operator may still be initializing)"
```

If the Operator is not yet ready, let's look at the feature-flags ConfigMap
directly (which the Operator manages):

```bash
echo "=== Waiting for Tekton Pipelines ==="
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-pipelines \
  -n tekton-pipelines --timeout=180s 2>/dev/null || true

kubectl get configmap feature-flags -n tekton-pipelines -o yaml
```

## Key feature flags explained

```bash
echo "=== Tekton Feature Flags ==="
echo ""
echo "enable-api-fields (default: stable)"
echo "  stable  - Only GA features"
echo "  beta    - Enable beta features (Matrix, PiP)"
echo "  alpha   - Enable alpha features (Breakpoints, CustomRuns)"
echo ""
echo "send-cloudevents-for-runs (default: false)"
echo "  Emit CloudEvents when PipelineRuns/TaskRuns change state"
echo ""
echo "require-git-ssh-secret-known-hosts (default: false)"
echo "  Require SSH secrets to include known_hosts file"
echo ""
echo "enforce-nonfalsifiability (default: none)"
echo "  none            - No enforcement"
echo "  spire           - Use SPIRE for non-falsifiable provenance"
echo ""
echo "results-from (default: termination-message)"
echo "  termination-message - Results via container termination message (4KB limit)"
echo "  sidecar-logs        - Results via sidecar (no size limit)"
echo ""
echo "max-result-size (default: 4096)"
echo "  Maximum size in bytes for a single result"
echo ""
echo "set-security-context (default: false)"
echo "  Automatically add security context to step containers"
echo ""
echo "keep-pod-on-cancel (default: false)"
echo "  Keep TaskRun pods when PipelineRun is cancelled (for debugging)"
```

## Check current values

```bash
echo "=== Current Feature Flag Values ==="
kubectl get configmap feature-flags -n tekton-pipelines -o json | \
  python3 -c "
import sys, json
data = json.load(sys.stdin).get('data', {})
for k, v in sorted(data.items()):
    print(f'  {k}: {v}')
" 2>/dev/null || kubectl get configmap feature-flags -n tekton-pipelines -o jsonpath='{.data}'
echo ""
```

## Verify

Confirm the feature-flags ConfigMap (or TektonConfig) exists:

```bash
kubectl get configmap feature-flags -n tekton-pipelines &>/dev/null || \
  kubectl get tektonconfig config &>/dev/null
```
