# Verify signatures signed by Vault

Verification uses the **public key** exported from Vault. The private key stays
in Vault, but the public key can be freely distributed to anyone who needs to
verify signatures.

## Export the public key from Vault

```bash
kubectl exec -n vault vault-0 -- vault read -field=public_key \
  transit/keys/tekton-chains > /tmp/vault-public-key.pem

echo "=== Vault Public Key ==="
cat /tmp/vault-public-key.pem
echo ""
echo "This key can verify any signature created by the Vault Transit key."
```

## Understand Vault-based verification

```bash
echo "=== Verification Flow ==="
echo ""
echo "1. Export public key from Vault (or use Vault's verify API)"
echo "2. Extract signature from TaskRun annotation"
echo "3. Extract payload from TaskRun annotation"
echo "4. Verify: does the signature match the payload using the public key?"
echo ""
echo "Two verification methods:"
echo "  a) Local: Use cosign/openssl with exported public key"
echo "  b) Vault API: Use 'vault write transit/verify/tekton-chains'"
```

## Verify using Vault's Transit API directly

Vault can also verify signatures server-side:

```bash
# Create a test payload
echo -n "test-payload" | base64 > /tmp/test-input.b64
TEST_INPUT=$(cat /tmp/test-input.b64)

# Sign with Vault
SIGNATURE=$(kubectl exec -n vault vault-0 -- vault write -field=signature \
  transit/sign/tekton-chains \
  input="$TEST_INPUT" 2>/dev/null)

echo "Signature: $SIGNATURE"

# Verify with Vault
if [ -n "$SIGNATURE" ]; then
  VALID=$(kubectl exec -n vault vault-0 -- vault write -field=valid \
    transit/verify/tekton-chains \
    input="$TEST_INPUT" \
    signature="$SIGNATURE" 2>/dev/null)
  echo "Vault verification result: $VALID"
else
  echo "Note: Sign/verify demo requires transit engine access"
fi
```

## Production considerations

```bash
echo "=== Production Setup ==="
echo ""
echo "1. Access Control:"
echo "   - Create a Vault policy that only allows transit/sign"
echo "   - Use Kubernetes auth method instead of root token"
echo "   - Example policy:"
echo "     path \"transit/sign/tekton-chains\" { capabilities = [\"update\"] }"
echo ""
echo "2. Key Rotation:"
echo "   - vault write transit/keys/tekton-chains/rotate"
echo "   - Old signatures remain valid (Vault keeps key versions)"
echo "   - New signatures use the latest key version"
echo ""
echo "3. Audit:"
echo "   - Enable Vault audit logging: vault audit enable file file_path=/var/log/vault-audit.log"
echo "   - Every signing operation is logged with timestamp and identity"
echo ""
echo "4. HA Setup:"
echo "   - Use Vault in HA mode with auto-unseal"
echo "   - Configure Chains with retry on Vault unavailability"
```

## Verify

Confirm the Vault Transit key and Chains KMS configuration are working:

```bash
# Check Vault key exists
kubectl exec -n vault vault-0 -- vault read transit/keys/tekton-chains -format=json \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('Key type:', d['data']['type'])" 2>/dev/null

# Check Chains config
KMS_REF=$(kubectl get configmap chains-config -n tekton-chains \
  -o jsonpath='{.data.signers\.kms\.kmsref}' 2>/dev/null)
echo "Chains KMS ref: $KMS_REF"
```
