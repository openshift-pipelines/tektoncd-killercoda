# Verify Chains signed the image

After the TaskRun completed, Chains detected the image results and automatically
signed the image in the registry. Let's verify this.

## Wait for Chains to sign

Chains signs images asynchronously after the TaskRun completes. Poll until
the signing annotation appears:

```bash
# Wait for Tekton Chains to sign the image (up to 120s)
for i in $(seq 1 24); do
  SIGNED=$(kubectl get taskrun --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[-1].metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null || echo "")
  if [[ "$SIGNED" == "true" ]]; then
    echo "Image signed by Chains (attempt $i/24)"
    break
  fi
  echo "Waiting for Chains to sign... (signed=$SIGNED, attempt $i/24)"
  sleep 5
done
```

## Check the signing annotation

Chains marks the TaskRun with `chains.tekton.dev/signed=true` once it has signed
the image:

```bash
kubectl get taskrun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].metadata.annotations.chains\.tekton\.dev/signed}'
```

You should see `true`.

## Verify the image signature with cosign

Now use cosign to verify that the image in the registry has a valid signature:

```bash
cosign verify --key cosign.pub localhost:5000/test-image:latest \
  --insecure-ignore-tlog --allow-insecure-registry 2>&1
```

> **Note:** We use `--insecure-ignore-tlog` because this tutorial uses a local
> key pair without uploading to Rekor (the Sigstore transparency log). In
> production, you would use keyless signing with Rekor for full transparency.
> We also use `--allow-insecure-registry` because our local registry uses HTTP.

If verification succeeds, cosign prints the verified signature payload. This
confirms:

1. Chains detected the image from the TaskRun results
2. Chains signed the image with the private key from `signing-secrets`
3. The signature was pushed to the registry alongside the image
4. cosign verified the signature matches the public key

## Inspect what Chains pushed to the registry

The signature is stored as a separate tag in the registry. List all tags to see
it:

```bash
curl -s http://localhost:5000/v2/test-image/tags/list
```

You should see both the `latest` tag and a `sha256-*.sig` tag. The `.sig` tag
contains the signature that cosign just verified.
