# Create a GitHub-aware EventListener

In this step you will set up the complete Tekton Triggers infrastructure for
receiving GitHub webhooks: RBAC, a TriggerBinding that extracts GitHub payload
fields, a TriggerTemplate that creates PipelineRuns, and an EventListener with
the GitHub interceptor.

## Create RBAC resources

The EventListener needs permissions to create PipelineRuns and read secrets:

```bash
kubectl create serviceaccount tekton-triggers-sa
```

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tekton-triggers-binding
subjects:
  - kind: ServiceAccount
    name: tekton-triggers-sa
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-roles
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tekton-triggers-clusterbinding
subjects:
  - kind: ServiceAccount
    name: tekton-triggers-sa
    namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-clusterroles
EOF
```

## Create the webhook secret

GitHub webhooks use a shared secret to compute HMAC signatures. Create a
Kubernetes Secret that the GitHub interceptor will use to validate incoming
payloads:

```bash
kubectl create secret generic github-secret --from-literal=secretToken=my-secret-token
```

## Create a Pipeline to trigger

This Pipeline logs the details extracted from the GitHub webhook payload:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: github-handler
spec:
  params:
    - name: repo-full-name
      type: string
    - name: commit-sha
      type: string
    - name: git-ref
      type: string
  steps:
    - name: log
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "======================================="
        echo "  GitHub Webhook Received!"
        echo "======================================="
        echo "Repository: $(params.repo-full-name)"
        echo "Commit:     $(params.commit-sha)"
        echo "Ref:        $(params.git-ref)"
        echo "======================================="
---
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: github-webhook-pipeline
spec:
  params:
    - name: repo-full-name
      type: string
    - name: commit-sha
      type: string
    - name: git-ref
      type: string
  tasks:
    - name: github-handler
      taskRef:
        name: github-handler
      params:
        - name: repo-full-name
          value: $(params.repo-full-name)
        - name: commit-sha
          value: $(params.commit-sha)
        - name: git-ref
          value: $(params.git-ref)
EOF
```

## Create TriggerBinding and TriggerTemplate

The TriggerBinding extracts three key fields from a standard GitHub push event
payload:

- **`body.repository.full_name`** - the owner/repo string (e.g., `octocat/hello-world`)
- **`body.head_commit.id`** - the full SHA of the latest commit
- **`body.ref`** - the Git ref that was pushed (e.g., `refs/heads/main`)

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: github-push-binding
spec:
  params:
    - name: repo-full-name
      value: $(body.repository.full_name)
    - name: commit-sha
      value: $(body.head_commit.id)
    - name: git-ref
      value: $(body.ref)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: github-push-template
spec:
  params:
    - name: repo-full-name
    - name: commit-sha
    - name: git-ref
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: github-webhook-run-
      spec:
        pipelineRef:
          name: github-webhook-pipeline
        params:
          - name: repo-full-name
            value: $(tt.params.repo-full-name)
          - name: commit-sha
            value: $(tt.params.commit-sha)
          - name: git-ref
            value: $(tt.params.git-ref)
EOF
```

## Create the EventListener with the GitHub interceptor

The GitHub interceptor validates the webhook signature and filters by event type.
Here it is configured for **push** events:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: github-listener
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: github-push-trigger
      interceptors:
        - ref:
            name: "github"
          params:
            - name: "secretRef"
              value:
                secretName: github-secret
                secretKey: secretToken
            - name: "eventTypes"
              value:
                - "push"
      bindings:
        - ref: github-push-binding
      template:
        ref: github-push-template
EOF
```

Key points about the GitHub interceptor configuration:

- **`secretRef`** - references the Kubernetes Secret containing the shared token.
  The interceptor uses this to compute the expected HMAC-SHA256 signature and
  compares it against the `X-Hub-Signature-256` header sent by GitHub.
- **`eventTypes`** - an allowlist of GitHub event types. Only events whose
  `X-GitHub-Event` header matches one of these values pass through.

## Wait for the EventListener to be ready

```bash
kubectl wait --for=condition=ready eventlistener github-listener --timeout=60s
```

Verify the EventListener pod and Service were created:

```bash
kubectl get pods -l eventlistener=github-listener
```

```bash
kubectl get service el-github-listener
```

The EventListener is now running and ready to receive GitHub push events with
HMAC signature validation.
