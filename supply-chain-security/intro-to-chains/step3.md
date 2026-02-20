# Verify the signature and inspect the payload

The real value of signing is **verification** - anyone with the public key can
confirm that a TaskRun was signed by your CI/CD system and has not been
tampered with.

## Extract the signature and payload

First, get the TaskRun name and extract the signature and payload annotations:

```bash
TASKRUN_NAME=$(kubectl get taskrun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
echo "Verifying TaskRun: $TASKRUN_NAME"
```

Extract the base64-encoded signature:

```bash
kubectl get taskrun "$TASKRUN_NAME" \
  -o jsonpath="{.metadata.annotations.chains\.tekton\.dev/signature-taskrun-$TASKRUN_NAME}" \
  > /tmp/signature.base64
echo "Signature extracted ($(wc -c < /tmp/signature.base64) bytes)"
```

## Extract and inspect the SLSA provenance payload

The payload is the SLSA provenance attestation that Chains generated. Extract
it:

```bash
kubectl get taskrun "$TASKRUN_NAME" \
  -o jsonpath="{.metadata.annotations.chains\.tekton\.dev/payload-taskrun-$TASKRUN_NAME}" \
  | base64 -d | python3 -m json.tool > /tmp/payload.json
```

Now inspect the provenance:

```bash
cat /tmp/payload.json
```

You should see a JSON document in the **SLSA provenance** format containing:

- **`_type`**: `https://in-toto.io/Statement/v0.1` - the in-toto attestation format
- **`predicateType`**: `https://slsa.dev/provenance/v0.2` - SLSA provenance
- **`subject`**: what was built (the TaskRun)
- **`predicate.buildType`**: `tekton.dev/v1beta1/TaskRun`
- **`predicate.invocation`**: parameters and configuration used

## Verify with cosign

Use cosign to verify the signature against the public key we generated in
Step 1:

```bash
kubectl get taskrun "$TASKRUN_NAME" \
  -o jsonpath="{.metadata.annotations.chains\.tekton\.dev/signature-taskrun-$TASKRUN_NAME}" \
  | base64 -d > /tmp/signature.raw

kubectl get taskrun "$TASKRUN_NAME" \
  -o jsonpath="{.metadata.annotations.chains\.tekton\.dev/payload-taskrun-$TASKRUN_NAME}" \
  | base64 -d > /tmp/payload.raw

cosign verify-blob --key cosign.pub --signature /tmp/signature.raw --insecure-ignore-tlog /tmp/payload.raw
```

If verification succeeds, you will see `Verified OK`. This confirms:

1. The signature was created with the private key matching `cosign.pub`
2. The payload has not been modified since signing
3. You can trust this TaskRun provenance

## The full chain of trust

You have now completed the full signing and verification cycle:

```
Task created --> TaskRun executed --> Chains signed --> Provenance generated --> We verified
```

This is the foundation of software supply chain security with Tekton. In a
production environment, your verification step would happen in a separate
system (e.g., an admission controller) that checks signatures before allowing
deployments.
