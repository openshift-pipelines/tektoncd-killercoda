# Set up the secure pipeline infrastructure

Before building the Pipeline, you need to configure the signing infrastructure:
Chains configuration, cosign keys, and a source repository with a Dockerfile.

## Configure Chains for production signing

Configure Chains to use **x509 signing**, store signatures in **OCI registries**,
and generate **SLSA/v1 provenance** format:

```bash
kubectl patch configmap chains-config -n tekton-chains -p='{"data":{
  "artifacts.oci.format": "simplesigning",
  "artifacts.oci.storage": "oci",
  "artifacts.oci.signer": "x509",
  "artifacts.taskrun.format": "slsa/v1",
  "artifacts.taskrun.storage": "oci",
  "artifacts.taskrun.signer": "x509",
  "artifacts.pipelinerun.format": "slsa/v1",
  "artifacts.pipelinerun.storage": "oci",
  "artifacts.pipelinerun.signer": "x509"
}}'
```

## Verify the Chains configuration

```bash
kubectl get configmap chains-config -n tekton-chains -o jsonpath='{.data}' | python3 -m json.tool
```

You should see all the signing, storage, and format settings applied.

## Generate cosign signing keys

Generate a cosign key pair and store it as a Kubernetes Secret in the
`tekton-chains` namespace. Press Enter when prompted for a password:

```bash
COSIGN_PASSWORD="" cosign generate-key-pair k8s://tekton-chains/signing-secrets
```

This creates:

- A **private key** in the `signing-secrets` Secret (Chains uses this to sign)
- A **public key** saved as `cosign.pub` in your current directory (used to
  verify)

## Verify the signing secret

```bash
kubectl get secret signing-secrets -n tekton-chains
```

## Restart Chains to pick up the new configuration

```bash
kubectl delete pod -l app.kubernetes.io/part-of=tekton-chains -n tekton-chains
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-chains \
  -n tekton-chains --timeout=60s
```

## Create a source repository with a Dockerfile

Create a local Git repository with a simple application and Dockerfile:

```bash
mkdir -p /root/source-repo && cd /root/source-repo
git init
```

Create the application:

```bash
cat > /root/source-repo/app.sh << 'SCRIPT'
#!/bin/sh
echo "Hello from a securely-built container!"
echo "This image was signed by Tekton Chains."
SCRIPT
chmod +x /root/source-repo/app.sh
```

Create a Dockerfile:

```bash
cat > /root/source-repo/Dockerfile << 'DOCKERFILE'
FROM alpine:3.19
COPY app.sh /app.sh
ENTRYPOINT ["/app.sh"]
DOCKERFILE
```

Commit the source code:

```bash
cd /root/source-repo
git add -A
git commit -m "Initial commit: secure app"
```

The infrastructure is now ready: Chains is configured for signing, cosign keys
are generated, and you have a source repository to build from.
