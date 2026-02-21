# Chain GitHub and CEL interceptors

In production, you typically start the interceptor chain with a **GitHub
interceptor** for webhook signature validation (HMAC), followed by **CEL
interceptors** for filtering and transformation. This step demonstrates that
three-stage pattern.

## Create a webhook secret

GitHub webhooks use HMAC signatures to prove the event came from GitHub. Create
a secret with a shared webhook token:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: github-webhook-secret
type: Opaque
stringData:
  secretToken: "my-secret-webhook-token"
EOF
```

## Create a new Pipeline for this demo

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: github-chain-demo
spec:
  params:
    - name: git-repo-url
      type: string
    - name: git-branch
      type: string
    - name: git-commit
      type: string
  tasks:
    - name: log-push
      taskRef:
        name: print-event-info
      params:
        - name: event-type
          value: "push"
        - name: repo-name
          value: $(params.git-repo-url)
        - name: timestamp
          value: $(params.git-branch)
EOF
```

## Create TriggerBinding and TriggerTemplate

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: github-chain-binding
spec:
  params:
    - name: git-repo-url
      value: $(body.repository.clone_url)
    - name: git-branch
      value: $(body.branch_name)
    - name: git-commit
      value: $(body.head_commit.id)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: github-chain-template
spec:
  params:
    - name: git-repo-url
    - name: git-branch
    - name: git-commit
  resourcetemplates:
    - apiVersion: tekton.dev/v1
      kind: PipelineRun
      metadata:
        generateName: github-chain-run-
      spec:
        pipelineRef:
          name: github-chain-demo
        params:
          - name: git-repo-url
            value: $(tt.params.git-repo-url)
          - name: git-branch
            value: $(tt.params.git-branch)
          - name: git-commit
            value: $(tt.params.git-commit)
EOF
```

## Create the EventListener with 3 chained interceptors

The chain is: **GitHub** (validate HMAC) -> **CEL** (filter for main branch)
-> **CEL** (extract branch name into a top-level field):

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: github-chain
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: github-push-main
      interceptors:
        - ref:
            name: "github"
          params:
            - name: "secretRef"
              value:
                secretName: github-webhook-secret
                secretKey: secretToken
            - name: "eventTypes"
              value: ["push"]
        - ref:
            name: "cel"
          params:
            - name: "filter"
              value: "body.ref.endsWith('main')"
        - ref:
            name: "cel"
          params:
            - name: "overlays"
              value:
                - key: branch_name
                  expression: "body.ref.split('/')[2]"
      bindings:
        - ref: github-chain-binding
      template:
        ref: github-chain-template
EOF
```

## Wait for the EventListener

```bash
kubectl wait --for=condition=ready eventlistener github-chain --timeout=60s
kubectl get service el-github-chain
```

## Understand the interceptor chain

Let's examine what happens at each stage:

1. **GitHub interceptor**: Validates the `X-Hub-Signature-256` HMAC header.
   Events without a valid signature are rejected with 401 Unauthorized.
   Also filters for `push` event types only.

2. **CEL filter**: Checks that `body.ref` ends with `main`. Events pushed to
   other branches (like `develop` or `feature/x`) are silently dropped.

3. **CEL overlay**: Extracts just the branch name from `refs/heads/main` and
   adds it as `body.branch_name`. This makes it available to the TriggerBinding.

## Test with a properly signed push to main

Compute the HMAC signature and send a properly signed event:

```bash
PAYLOAD='{"ref":"refs/heads/main","head_commit":{"id":"abc123def456"},"repository":{"clone_url":"https://github.com/example/my-repo.git","name":"my-repo"}}'
SECRET="my-secret-webhook-token"
SIGNATURE="sha256=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac "$SECRET" | awk '{print $2}')"

curl -X POST http://$(kubectl get service el-github-chain -o jsonpath='{.spec.clusterIP}'):8080 \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: $SIGNATURE" \
  -d "$PAYLOAD"
```

<!-- e2e-skip -->
```bash
sleep 3
tkn pipelinerun list | grep github-chain
```

## Test with an unsigned event (should be rejected)

```bash
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" \
  -X POST http://$(kubectl get service el-github-chain -o jsonpath='{.spec.clusterIP}'):8080 \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -d '{"ref":"refs/heads/main","head_commit":{"id":"bad"},"repository":{"clone_url":"https://github.com/example/hack.git","name":"hack"}}'
```

The request should return a non-200 status code because the GitHub interceptor
rejected the unsigned event. The chain stopped at the first interceptor.
