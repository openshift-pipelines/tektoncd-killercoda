# Production patterns: rotation and least privilege

In the previous steps, we used static secrets stored in Vault's KV store.
This is already a significant improvement over Kubernetes Secrets. But Vault
offers even more powerful patterns for production use.

## Pattern 1: Secret rotation

In production, secrets should be rotated regularly. With Vault, you update
the secret in one place and every new pipeline run automatically gets the
new credentials. Let's simulate a credential rotation:

Check the current database password:

```bash
kubectl exec -n vault vault-0 -- vault kv get -field=password secret/pipeline/db
```

Rotate the password:

```bash
kubectl exec -n vault vault-0 -- vault kv put secret/pipeline/db \
  username=admin \
  password=rotated-$(date +%s) \
  host=postgres.production.svc.cluster.local \
  port=5432 \
  database=myapp
```

Verify the new password:

```bash
kubectl exec -n vault vault-0 -- vault kv get -field=password secret/pipeline/db
```

Now run a new TaskRun - it automatically gets the rotated credentials:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: vault-rotation-test
spec:
  serviceAccountName: pipeline-sa
  taskRef:
    name: vault-secret-task
  podTemplate:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-status: "update"
        vault.hashicorp.com/role: "pipeline-role"
        vault.hashicorp.com/agent-inject-secret-db: "secret/data/pipeline/db"
        vault.hashicorp.com/agent-inject-template-db: |
          {{- with secret "secret/data/pipeline/db" -}}
          username {{ .Data.data.username }}
          password {{ .Data.data.password }}
          host {{ .Data.data.host }}
          port {{ .Data.data.port }}
          database {{ .Data.data.database }}
          {{- end }}
EOF
```

```bash
kubectl wait --for=condition=Succeeded taskrun/vault-rotation-test --timeout=180s
tkn taskrun logs vault-rotation-test
```

Notice the password in the logs is the rotated value. No Kubernetes Secrets
needed updating, no redeployments required. The new credentials are picked up
automatically.

## Pattern 2: Least-privilege access

Different pipeline stages need different secrets. A build task should not have
access to production database credentials. Create scoped policies:

```bash
kubectl exec -n vault vault-0 -- vault policy write pipeline-build-only - <<EOF
path "secret/data/pipeline/api" {
  capabilities = ["read"]
}
EOF
```

```bash
kubectl exec -n vault vault-0 -- vault policy write pipeline-deploy-only - <<EOF
path "secret/data/pipeline/db" {
  capabilities = ["read"]
}
EOF
```

Create separate ServiceAccounts and Vault roles:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-sa
  namespace: default
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: deploy-sa
  namespace: default
EOF
```

```bash
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/build-role \
  bound_service_account_names=build-sa \
  bound_service_account_namespaces=default \
  policies=pipeline-build-only \
  ttl=1h

kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/deploy-role \
  bound_service_account_names=deploy-sa \
  bound_service_account_namespaces=default \
  policies=pipeline-deploy-only \
  ttl=1h
```

## Test least privilege: build-sa can only read API secrets

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: privilege-test-task
spec:
  steps:
    - name: check-secrets
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== Checking available secrets ==="
        echo ""
        if [ -f /vault/secrets/api ]; then
          echo "[FOUND] API secret is available:"
          cat /vault/secrets/api
        else
          echo "[NOT FOUND] API secret is not available"
        fi
        echo ""
        echo "Least-privilege access confirmed!"
EOF
```

Run with the build-sa (should only get API secrets):

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: build-privilege-test
spec:
  serviceAccountName: build-sa
  taskRef:
    name: privilege-test-task
  podTemplate:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/agent-inject-status: "update"
        vault.hashicorp.com/role: "build-role"
        vault.hashicorp.com/agent-inject-secret-api: "secret/data/pipeline/api"
        vault.hashicorp.com/agent-inject-template-api: |
          {{- with secret "secret/data/pipeline/api" -}}
          api_key {{ .Data.data.api_key }}
          api_url {{ .Data.data.api_url }}
          {{- end }}
EOF
```

```bash
kubectl wait --for=condition=Succeeded taskrun/build-privilege-test --timeout=180s
tkn taskrun logs build-privilege-test
```

The build ServiceAccount can access the API key but not the database
credentials. Each pipeline stage only has access to the secrets it needs.

## Pattern 3: Audit trail

Vault logs every secret access. Check the audit of what has been accessed:

```bash
kubectl exec -n vault vault-0 -- vault kv metadata get secret/pipeline/db
```

This shows version history and access metadata. In production with audit
logging enabled, every read and write operation is recorded with the
identity that performed it. This gives you:

- **Who** accessed which secret
- **When** the access occurred
- **What** was the source (which ServiceAccount, which namespace)

## Summary of production patterns

| Pattern | Benefit |
|---------|---------|
| **Central secrets** | One place to manage all pipeline credentials |
| **Rotation** | Update once in Vault, all new runs get fresh credentials |
| **Least privilege** | Each pipeline stage only accesses the secrets it needs |
| **Audit trail** | Full record of who accessed what and when |
| **No K8s Secrets** | Credentials never stored in etcd - only in Vault |
| **Short-lived tokens** | Vault tokens expire, limiting the blast radius |
