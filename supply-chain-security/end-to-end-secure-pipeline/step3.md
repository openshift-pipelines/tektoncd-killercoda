# Run the secure pipeline end-to-end

Now run the Pipeline and watch Tekton Chains automatically sign the built
container image and attach SLSA provenance.

## Run the Pipeline

```bash
cat <<'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: secure-build-run-
spec:
  pipelineRef:
    name: secure-build-pipeline
  params:
    - name: source-dir
      value: /root/source-repo
    - name: image-reference
      value: localhost:5000/secure-app:v1
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF
```

## Watch the Pipeline execute

```bash
PR_NAME=$(kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
tkn pipelinerun logs "$PR_NAME" -f
```

Wait for the PipelineRun to complete successfully:

```bash
PR_NAME=$(kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
kubectl wait --for=condition=Succeeded pipelinerun "$PR_NAME" --timeout=300s
```

## Verify the image is in the registry

```bash
curl -s http://localhost:5000/v2/_catalog | python3 -m json.tool
```

You should see `secure-app` in the registry catalog.

## Wait for Chains to sign the image

Chains signs asynchronously after the TaskRun completes. Wait for the signing
annotation to appear on the build TaskRun:

```bash
echo "Waiting for Chains to sign the image..."
PR_NAME=$(kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
for i in $(seq 1 30); do
  SIGNED=$(kubectl get pipelinerun "$PR_NAME" -o jsonpath='{.metadata.annotations.chains\.tekton\.dev/signed}' 2>/dev/null)
  if [ "$SIGNED" = "true" ]; then
    echo "Image signed by Chains!"
    break
  fi
  echo "  Waiting... ($i/30)"
  sleep 5
done
```

## Verify the Chains signing annotation

```bash
PR_NAME=$(kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
kubectl get pipelinerun "$PR_NAME" -o jsonpath='{.metadata.annotations}' | python3 -m json.tool
```

Look for `chains.tekton.dev/signed: "true"` -- this confirms Chains has signed
the image.

## Verify the image signature with cosign

Now verify the signature using the public key that cosign generated in Step 1:

```bash
cosign verify --key cosign.pub --insecure-ignore-tlog=true \
  --allow-insecure-registry localhost:5000/secure-app:v1 2>&1 || \
  echo "Note: If verification fails, Chains may still be processing. Wait 10s and retry."
```

## Inspect the SLSA provenance attestation

Check the provenance attestation that Chains attached to the image:

```bash
cosign verify-attestation --key cosign.pub --insecure-ignore-tlog=true \
  --allow-insecure-registry --type slsaprovenance \
  localhost:5000/secure-app:v1 2>&1 | head -50 || \
  echo "Note: Attestation may take a moment to appear."
```

The image is now signed and attested with SLSA provenance. In the next step,
you will simulate a consumer verifying the supply chain.
