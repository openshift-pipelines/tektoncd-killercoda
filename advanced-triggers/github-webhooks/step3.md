# Filter events by branch and action

In production you often want to trigger Pipelines only for pushes to a specific
branch, such as `main`. The GitHub interceptor validates the signature and
filters by event type, but it does not filter by branch. For that, you chain a
**CEL interceptor** after the GitHub interceptor.

This creates an **interceptor chain**:

1. **GitHub interceptor** - validates the HMAC signature and checks `X-GitHub-Event`
2. **CEL interceptor** - filters by branch using `body.ref == 'refs/heads/main'`

Only events that pass both interceptors trigger a PipelineRun.

## Delete the old EventListener

```bash
kubectl delete eventlistener github-listener
```

## Create a new EventListener with the interceptor chain

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: github-listener
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: github-main-branch-trigger
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
        - ref:
            name: "cel"
          params:
            - name: "filter"
              value: "body.ref == 'refs/heads/main'"
      bindings:
        - ref: github-push-binding
      template:
        ref: github-push-template
EOF
```

Notice the `interceptors` list now has **two entries**. Tekton evaluates them
in order: first `github`, then `cel`. If the GitHub interceptor rejects the
event (bad signature or wrong event type), the CEL interceptor is never reached.
If the GitHub interceptor passes but the CEL filter evaluates to `false`, the
event is silently dropped.

## Wait for the EventListener to be ready

```bash
kubectl wait --for=condition=ready eventlistener github-listener --timeout=60s
sleep 2
```

Set up port forwarding to the new EventListener:

```bash
pkill -f "port-forward.*el-github-listener" 2>/dev/null || true
kubectl port-forward service/el-github-listener 8080:8080 > /dev/null 2>&1 &
sleep 3
```

## Test 1: Push to main (should trigger)

Prepare a payload for a push to the `main` branch:

```bash
MAIN_PAYLOAD='{
  "ref": "refs/heads/main",
  "head_commit": {
    "id": "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1",
    "message": "Merge feature branch",
    "author": {
      "name": "octocat",
      "email": "octocat@github.com"
    }
  },
  "repository": {
    "full_name": "octocat/hello-world",
    "html_url": "https://github.com/octocat/hello-world"
  },
  "pusher": {
    "name": "octocat"
  }
}'
```

Compute the HMAC signature and send the request:

```bash
MAIN_SIG=$(echo -n "$MAIN_PAYLOAD" | openssl dgst -sha256 -hmac 'my-secret-token' | awk '{print $2}')
curl -s -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: sha256=$MAIN_SIG" \
  -d "$MAIN_PAYLOAD"
```

Wait and check for the PipelineRun:

```bash
sleep 8
tkn pipelinerun list
```

You should see a new PipelineRun created. View the logs:

```bash
tkn pipelinerun logs --last -f
```

You should see **Ref: refs/heads/main** confirming the main branch push was
accepted by both interceptors.

## Test 2: Push to a feature branch (should be filtered)

Now send a push event for a feature branch. The GitHub interceptor will pass
it (the signature and event type are valid), but the CEL filter should reject
it because `body.ref` does not match `refs/heads/main`:

```bash
FEATURE_PAYLOAD='{
  "ref": "refs/heads/feature/add-login",
  "head_commit": {
    "id": "c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2",
    "message": "Add login page",
    "author": {
      "name": "octocat",
      "email": "octocat@github.com"
    }
  },
  "repository": {
    "full_name": "octocat/hello-world",
    "html_url": "https://github.com/octocat/hello-world"
  },
  "pusher": {
    "name": "octocat"
  }
}'
```

```bash
FEATURE_SIG=$(echo -n "$FEATURE_PAYLOAD" | openssl dgst -sha256 -hmac 'my-secret-token' | awk '{print $2}')
curl -s -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: sha256=$FEATURE_SIG" \
  -d "$FEATURE_PAYLOAD"
```

## Verify only the main branch push triggered

Wait a moment and count the PipelineRuns created by this EventListener:

```bash
sleep 5
kubectl get pipelinerun -l triggers.tekton.dev/eventlistener=github-listener --no-headers | wc -l
```

You should see the count reflects only the PipelineRuns triggered by `main`
branch pushes. The feature branch push passed the GitHub interceptor (valid
signature) but was rejected by the CEL filter.

## Understand the interceptor chain

The diagram below shows the flow:

```
  GitHub Webhook
       |
       v
  +-------------------+
  | GitHub Interceptor |  <-- Validates HMAC signature
  | (secretRef)       |      Checks X-GitHub-Event
  +-------------------+
       |
       | (signature valid, event type matches)
       v
  +-------------------+
  | CEL Interceptor   |  <-- Filters by branch
  | (filter)          |      body.ref == 'refs/heads/main'
  +-------------------+
       |
       | (branch matches)
       v
  +-------------------+
  | TriggerBinding    |  <-- Extracts fields
  | TriggerTemplate   |      Creates PipelineRun
  +-------------------+
```

This pattern is common in production: the GitHub interceptor handles security
(signature validation), and the CEL interceptor handles business logic
(branch filtering, action matching, etc.).
