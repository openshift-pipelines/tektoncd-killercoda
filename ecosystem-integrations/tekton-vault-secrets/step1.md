# Set up Vault with Pipeline secrets

## Verify the installation

First, confirm that Vault is running in dev mode:

```bash
kubectl get pods -n vault
```

You should see the Vault server pod and the Vault Agent Injector pod, both in
`Running` state.

## Store secrets in Vault

In dev mode, Vault is unsealed and ready to use with the root token `root`.
Let's store some pipeline secrets. We will exec into the Vault pod to run
vault commands:

```bash
kubectl exec -n vault vault-0 -- vault kv put secret/pipeline/db \
  username=admin \
  password=secret123 \
  host=postgres.production.svc.cluster.local \
  port=5432 \
  database=myapp
```

Store an API key for an external service:

```bash
kubectl exec -n vault vault-0 -- vault kv put secret/pipeline/api \
  api_key=sk-prod-abc123def456 \
  api_url=https://api.example.com/v2 \
  api_timeout=30
```

Verify the secrets were stored:

```bash
kubectl exec -n vault vault-0 -- vault kv get secret/pipeline/db
```

```bash
kubectl exec -n vault vault-0 -- vault kv get secret/pipeline/api
```

## Enable Kubernetes authentication

For Tekton TaskRun pods to authenticate with Vault, we need to enable
Vault's Kubernetes auth method. This allows pods to prove their identity
using their ServiceAccount token:

```bash
kubectl exec -n vault vault-0 -- vault auth enable kubernetes
```

Configure the Kubernetes auth method to communicate with the Kubernetes API:

```bash
kubectl exec -n vault vault-0 -- sh -c '
  vault write auth/kubernetes/config \
    kubernetes_host="https://${KUBERNETES_PORT_443_TCP_ADDR}:443"
'
```

## Create a Vault policy for pipeline access

Create a policy that grants read access to the pipeline secrets path:

```bash
kubectl exec -n vault vault-0 -- vault policy write pipeline-readonly - <<EOF
path "secret/data/pipeline/*" {
  capabilities = ["read"]
}
EOF
```

Verify the policy was created:

```bash
kubectl exec -n vault vault-0 -- vault policy read pipeline-readonly
```

## Create a Kubernetes auth role

Create a Vault role that maps a Kubernetes ServiceAccount to the pipeline
policy. This role allows any pod running as the `pipeline-sa` ServiceAccount
in the `default` namespace to authenticate and read pipeline secrets:

```bash
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/pipeline-role \
  bound_service_account_names=pipeline-sa \
  bound_service_account_namespaces=default \
  policies=pipeline-readonly \
  ttl=1h
```

## Create the ServiceAccount in Kubernetes

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pipeline-sa
  namespace: default
EOF
```

Verify the configuration:

```bash
echo "=== Vault auth methods ==="
kubectl exec -n vault vault-0 -- vault auth list

echo ""
echo "=== Pipeline role configuration ==="
kubectl exec -n vault vault-0 -- vault read auth/kubernetes/role/pipeline-role
```

The Vault setup is complete. Pods running as `pipeline-sa` in the `default`
namespace can now authenticate to Vault and read secrets from
`secret/pipeline/*`.
