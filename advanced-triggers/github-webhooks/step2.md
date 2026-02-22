# Simulate a GitHub webhook with HMAC signature

When GitHub delivers a webhook, it sends three important headers:

- **`X-GitHub-Event`** - the event type (e.g., `push`, `pull_request`)
- **`X-Hub-Signature-256`** - the HMAC-SHA256 signature of the payload body
- **`Content-Type: application/json`** - the payload format

In this step you will compute an HMAC signature locally, send a simulated
GitHub push event to the EventListener, and observe the GitHub interceptor
validating the signature and creating a PipelineRun.

## Port-forward the EventListener

```bash
kubectl port-forward service/el-github-listener 8080:8080 > /dev/null 2>&1 &
```

Wait for the port forward to establish:

```bash
sleep 3
```

## Prepare the payload

Define the JSON payload that mimics a real GitHub push event. A real GitHub
push payload has many fields, but the key ones are `repository.full_name`,
`head_commit.id`, and `ref`:

```bash
PAYLOAD='{
  "ref": "refs/heads/main",
  "head_commit": {
    "id": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2",
    "message": "Update README",
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

## Compute the HMAC-SHA256 signature

GitHub signs the raw payload body using the shared secret. Compute the
signature locally using `openssl`:

```bash
SIGNATURE=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac 'my-secret-token' | awk '{print $2}')
echo "Computed HMAC signature: sha256=$SIGNATURE"
```

This is the same algorithm GitHub uses. The result is a hex string prefixed with
`sha256=`.

## Send the webhook request

Now send the payload with the proper GitHub headers:

```bash
curl -s -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: sha256=$SIGNATURE" \
  -d "$PAYLOAD"
```

You should see a response with an `eventID`, confirming the EventListener
accepted the event. If the signature were wrong, the GitHub interceptor would
reject the request with a `403` status.

## Wait for the PipelineRun to start

```bash
sleep 8
```

## Verify the PipelineRun was created

```bash
tkn pipelinerun list
```

You should see a PipelineRun named `github-webhook-run-*` created from the
webhook.

View the logs to confirm the GitHub payload fields were extracted correctly:

<!-- e2e-skip -->
```bash
tkn pipelinerun logs --last -f
```

You should see:
- **Repository: octocat/hello-world**
- **Commit: a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2**
- **Ref: refs/heads/main**

## Test with an invalid signature

To prove the GitHub interceptor is actually validating signatures, send a
request with a bad signature:

```bash
curl -s -o /dev/null -w "HTTP status: %{http_code}\n" \
  -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: sha256=0000000000000000000000000000000000000000000000000000000000000000" \
  -d "$PAYLOAD"
```

The response should be a non-200 status, confirming the interceptor rejected the
request because the signature did not match.

Check that no new PipelineRun was created:

```bash
sleep 3
tkn pipelinerun list
```

You should still see only **one** PipelineRun. The GitHub interceptor protects
your Pipelines from unauthorized webhook deliveries.
