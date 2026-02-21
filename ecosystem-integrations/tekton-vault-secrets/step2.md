# Inject secrets into Pipeline Tasks

The Vault Agent Injector works by watching for pods with specific annotations.
When it finds matching pods, it injects a Vault Agent sidecar that
authenticates to Vault and writes secrets to a shared volume at
`/vault/secrets/`. Your Task steps then read the secrets from this path.

## Create a Task that reads Vault secrets

Create a Task that expects secrets to be available at `/vault/secrets/`:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: vault-secret-task
spec:
  steps:
    - name: read-db-secret
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== Reading database credentials from Vault ==="
        echo ""
        if [ -f /vault/secrets/db ]; then
          echo "Vault secrets file found at /vault/secrets/db"
          echo "Contents:"
          cat /vault/secrets/db
          echo ""
          echo "[SUCCESS] Database credentials retrieved from Vault!"
        else
          echo "[ERROR] No Vault secrets found at /vault/secrets/db"
          echo "This means the Vault Agent Injector did not inject secrets."
          exit 1
        fi
    - name: use-db-secret
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== Using database credentials ==="
        echo ""
        if [ -f /vault/secrets/db ]; then
          DB_USER=$(grep username /vault/secrets/db | awk '{print $2}')
          DB_PASS=$(grep password /vault/secrets/db | awk '{print $2}')
          DB_HOST=$(grep host /vault/secrets/db | awk '{print $2}')
          echo "Connecting to database:"
          echo "  Host: ${DB_HOST}"
          echo "  User: ${DB_USER}"
          echo "  Password: [REDACTED]"
          echo ""
          echo "[SUCCESS] Would connect to ${DB_HOST} as ${DB_USER}"
        else
          echo "[ERROR] Secrets not available"
          exit 1
        fi
EOF
```

## Run the Task with Vault annotations

The magic happens in the TaskRun. We add Vault Agent Injector annotations to
the pod template, which tells the injector what secrets to fetch and where to
put them:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: vault-secret-taskrun
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

Let's break down the annotations:

- `agent-inject: "true"` - tells the injector to add the Vault Agent sidecar
- `role: "pipeline-role"` - the Vault auth role to use for authentication
- `agent-inject-secret-db` - the Vault path to fetch secrets from
- `agent-inject-template-db` - a Go template that formats the secret data
  into the file at `/vault/secrets/db`

## Wait for the TaskRun to complete

```bash
kubectl wait --for=condition=Succeeded taskrun/vault-secret-taskrun --timeout=180s
```

## Check the logs

<!-- e2e-skip -->
```bash
tkn taskrun logs vault-secret-taskrun
```

You should see:
- The database credentials were successfully read from `/vault/secrets/db`
- The Task step was able to parse and use the credentials
- No secrets were stored in Kubernetes Secrets - they came directly from Vault

## Verify the pod had the Vault sidecar

Check that the Vault Agent was injected into the pod:

```bash
kubectl get pod -l tekton.dev/taskRun=vault-secret-taskrun -o jsonpath='{.items[0].spec.containers[*].name}' 2>/dev/null || \
  echo "Pod already cleaned up (expected if completed)"
```

If the pod is still running, you would see additional containers for the
Vault Agent alongside the Tekton step containers.

## Create a Pipeline that uses Vault secrets

Now let's use this pattern in a full Pipeline:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: vault-api-task
spec:
  steps:
    - name: call-api
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== Calling external API with Vault credentials ==="
        if [ -f /vault/secrets/api ]; then
          API_KEY=$(grep api_key /vault/secrets/api | awk '{print $2}')
          API_URL=$(grep api_url /vault/secrets/api | awk '{print $2}')
          echo "API URL: ${API_URL}"
          echo "API Key: ${API_KEY:0:10}... (truncated)"
          echo "[SUCCESS] API call would use credentials from Vault"
        else
          echo "[ERROR] API secrets not found"
          exit 1
        fi
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: vault-pipeline
spec:
  tasks:
    - name: db-access
      taskRef:
        name: vault-secret-task
    - name: api-access
      taskRef:
        name: vault-api-task
      runAfter:
        - db-access
EOF
```

Run the Pipeline with Vault annotations for both secret paths:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: vault-pipeline-run
spec:
  pipelineRef:
    name: vault-pipeline
  taskRunTemplate:
    serviceAccountName: pipeline-sa
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
          vault.hashicorp.com/agent-inject-secret-api: "secret/data/pipeline/api"
          vault.hashicorp.com/agent-inject-template-api: |
            {{- with secret "secret/data/pipeline/api" -}}
            api_key {{ .Data.data.api_key }}
            api_url {{ .Data.data.api_url }}
            api_timeout {{ .Data.data.api_timeout }}
            {{- end }}
EOF
```

```bash
kubectl wait --for=condition=Succeeded pipelinerun/vault-pipeline-run --timeout=180s
```

View the Pipeline logs:

<!-- e2e-skip -->
```bash
tkn pipelinerun logs vault-pipeline-run
```

Both Tasks received their secrets from Vault without any Kubernetes Secrets
being created. The secrets were injected at runtime by the Vault Agent.
