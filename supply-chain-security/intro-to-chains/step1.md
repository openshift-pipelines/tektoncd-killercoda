# Generate signing keys and configure Chains

Before Chains can sign anything, it needs a cryptographic key pair. We will
use **cosign** to generate the keys and store them as a Kubernetes Secret that
Chains can access.

## Generate a cosign key pair

Cosign can generate a key pair and store it directly as a Kubernetes Secret in
the `tekton-chains` namespace. When prompted for a password, you can press
Enter for an empty password (suitable for this tutorial):

```bash
COSIGN_PASSWORD="" cosign generate-key-pair k8s://tekton-chains/signing-secrets
```

This creates:
- A **private key** stored in the `signing-secrets` Secret (used by Chains to sign)
- A **public key** saved as `cosign.pub` in your current directory (used to verify)

## Verify the secret exists

```bash
kubectl get secret signing-secrets -n tekton-chains
```

You should see the `signing-secrets` Secret listed.

## Configure Chains for SLSA provenance

By default, Chains signs TaskRuns but we want to configure the output format
and storage. Let's set it to use **SLSA v1 provenance** format and store
signatures as **Tekton annotations**:

```bash
kubectl patch configmap chains-config -n tekton-chains \
  -p='{"data":{"artifacts.taskrun.format":"slsa/v1","artifacts.taskrun.storage":"tekton"}}'
```

## Restart the Chains controller

After changing the configuration, restart the Chains controller to pick up the
new settings:

```bash
kubectl delete pod -l app.kubernetes.io/part-of=tekton-chains -n tekton-chains
```

Wait for the new pod to be ready:

```bash
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-chains \
  -n tekton-chains --timeout=60s
```

The signing infrastructure is now ready. Chains will automatically sign every
TaskRun that completes in your cluster.
