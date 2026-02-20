# Set up Vault as a Chains signing backend

In this step, you will configure Vault's Transit secrets engine and create a
signing key that Chains will use.

## Verify Vault is running

The install script started Vault in dev mode. Let's confirm it's ready:

```bash
kubectl get pod -l app.kubernetes.io/name=vault -n vault
kubectl exec -n vault vault-0 -- vault status
```

## Enable the Transit secrets engine

The Transit engine provides cryptographic operations without exposing key
material:

```bash
kubectl exec -n vault vault-0 -- vault secrets enable transit
```

## Create a signing key for Chains

Create an ECDSA-P256 key (the standard for container image signing):

```bash
kubectl exec -n vault vault-0 -- vault write transit/keys/tekton-chains \
  type=ecdsa-p256
```

Verify the key exists:

```bash
kubectl exec -n vault vault-0 -- vault read transit/keys/tekton-chains
```

## Configure Chains to use Vault KMS

Now tell Chains to use Vault for signing instead of local keys:

```bash
VAULT_ADDR="http://vault.vault.svc.cluster.local:8200"

kubectl patch configmap chains-config -n tekton-chains -p "{\"data\":{
  \"signers.x509.kms.auth.address\": \"${VAULT_ADDR}\",
  \"signers.x509.kms.auth.token\": \"root\",
  \"artifacts.taskrun.format\": \"in-toto\",
  \"artifacts.taskrun.storage\": \"tekton\",
  \"artifacts.taskrun.signer\": \"kms\",
  \"artifacts.oci.signer\": \"kms\",
  \"signers.kms.kmsref\": \"hashivault://tekton-chains\"
}}"
```

**Important notes:**

- `signers.kms.kmsref: hashivault://tekton-chains` tells Chains to use the
  Vault Transit key named `tekton-chains`
- In production, use a Vault token with minimal permissions (only `transit/sign`
  and `transit/verify`) instead of the root token
- The `hashivault://` prefix is the KMS URI scheme that Chains recognizes

## Restart Chains to apply the configuration

```bash
kubectl delete pod -l app=tekton-chains-controller -n tekton-chains
kubectl wait --for=condition=ready pod -l app=tekton-chains-controller \
  -n tekton-chains --timeout=120s
```

## Verify

Confirm the Transit key exists in Vault:

```bash
kubectl exec -n vault vault-0 -- vault read -field=type transit/keys/tekton-chains
```
