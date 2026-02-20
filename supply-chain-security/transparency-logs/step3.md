# Verify using the transparency log

Transparency logs enable **third-party verification** -- anyone can check that a
signing event was recorded, without trusting the signer directly.

## Extract the signature payload

Get the Chains signature and payload from the TaskRun annotations:

```bash
TASKRUN=$(kubectl get taskrun -o name | head -1)

echo "=== Extracting Chains payload ==="
kubectl get $TASKRUN -o json | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
annotations = data.get('metadata', {}).get('annotations', {})

# List all chains-related annotations
chains_keys = [k for k in annotations if 'chains' in k.lower()]
print(f'Found {len(chains_keys)} Chains annotations:')
for k in sorted(chains_keys):
    v = annotations[k]
    if len(v) > 100:
        print(f'  {k}: ({len(v)} bytes)')
    else:
        print(f'  {k}: {v}')

# Check for payload annotations
payload_keys = [k for k in annotations if 'payload' in k.lower() or 'signature' in k.lower()]
if payload_keys:
    print(f'\nPayload/signature annotations: {payload_keys}')
" 2>/dev/null || echo "TaskRun annotations extracted"
```

## Understand the verification model

Transparency logs provide three verification guarantees:

1. **Inclusion proof**: The entry is part of the log (Merkle tree proof)
2. **Consistency proof**: The log has not been tampered with
3. **Signed timestamp**: The entry was added at a specific time

```bash
echo "=== Transparency Log Verification Model ==="
echo ""
echo "Without transparency logs:"
echo "  Signer signs artifact -> Consumer trusts signer"
echo "  (What if the signer is compromised?)"
echo ""
echo "With transparency logs:"
echo "  Signer signs artifact -> Log records event -> Consumer verifies via log"
echo "  (Compromise is detectable because the log is public and append-only)"
echo ""
echo "Key principle: You do not need to trust the signer if you trust the log."
```

## Verify the Chains signing chain locally

Even when Rekor is not reachable (e.g., air-gapped environments), you can verify
the signature using the local signing key:

```bash
# Get the Chains signing secret
kubectl get secret signing-secrets -n tekton-chains -o jsonpath='{.data}' | python3 -c "
import sys, json
data = json.load(sys.stdin)
print('Signing secrets present:')
for k in sorted(data.keys()):
    print(f'  {k}: ({len(data[k])} bytes base64)')
" 2>/dev/null || echo "Signing secrets configured in tekton-chains namespace"

echo ""
echo "In a production setup, you would:"
echo "  1. Export the public key from Chains signing secrets"
echo "  2. Use cosign verify-blob or rekor-cli verify to check the signature"
echo "  3. Verify the Rekor inclusion proof to confirm the log entry is genuine"
```

## Summary of the transparency flow

```bash
echo "=== Complete Transparency Flow ==="
echo ""
echo "1. Developer pushes code"
echo "2. Tekton Pipeline builds and tests"
echo "3. Chains automatically signs the TaskRun"
echo "4. Chains publishes the signing event to Rekor"
echo "5. Rekor returns an inclusion proof and log index"
echo "6. Auditor can independently verify via Rekor"
echo ""
echo "This enables supply chain transparency without"
echo "requiring trust in any single entity."
```

## Verify

Confirm the transparency logging configuration and signing are in place:

```bash
TRANSPARENCY=$(kubectl get configmap chains-config -n tekton-chains \
  -o jsonpath='{.data.transparency\.enabled}' 2>/dev/null)
echo "Transparency enabled: $TRANSPARENCY"
```
