# Set up image signing keys

Before Chains can sign container images, it needs a cryptographic key pair. We
will use **cosign** to generate the keys and store them as a Kubernetes Secret.

## Generate a cosign key pair

Cosign can generate a key pair and store it directly as a Kubernetes Secret in
the `tekton-chains` namespace. When prompted for a password, press Enter for an
empty password (suitable for this tutorial):

```bash
COSIGN_PASSWORD="" cosign generate-key-pair k8s://tekton-chains/signing-secrets
```

This creates:
- A **private key** in the `signing-secrets` Secret (Chains uses this to sign images)
- A **public key** saved as `cosign.pub` in your current directory (used to verify)

## Verify the secret exists

```bash
kubectl get secret signing-secrets -n tekton-chains
```

You should see the `signing-secrets` Secret listed.

## Restart the Chains controller

The install script already configured Chains for OCI image signing. Restart the
controller to make sure it picks up both the signing keys and the configuration:

```bash
kubectl delete pod -l app.kubernetes.io/part-of=tekton-chains -n tekton-chains
```

Wait for the new pod to be ready:

```bash
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-chains \
  -n tekton-chains --timeout=60s
```

## Verify the configuration

Check that Chains is configured for OCI image signing:

```bash
kubectl get configmap chains-config -n tekton-chains -o jsonpath='{.data}' | python3 -m json.tool
```

You should see `artifacts.oci.format` set to `simplesigning` and
`artifacts.oci.storage` set to `oci`. This tells Chains to sign container images
and push the signatures to the same registry as the image.
