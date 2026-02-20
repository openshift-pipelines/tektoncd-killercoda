# Test event filtering

Now let's prove that the CEL filter works by sending two events: one that matches
the filter (push) and one that does not (pull_request).

## Port-forward the EventListener

```bash
kubectl port-forward service/el-cel-demo 8080:8080 > /dev/null 2>&1 &
```

Wait for the port forward to establish:

```bash
sleep 3
```

## Send a push event (should trigger)

Send a simulated push event that matches the filter `body.action == "push"`:

```bash
curl -s -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "action": "push",
    "repository": {
      "name": "my-app",
      "url": "https://github.com/example/my-app"
    },
    "ref": "refs/heads/main",
    "after": "abc123def456789"
  }'
```

You should see a response with an `eventID`, indicating the EventListener
accepted the event.

## Wait for the PipelineRun to start

```bash
sleep 5
```

## Check that a PipelineRun was created

```bash
tkn pipelinerun list
```

You should see one PipelineRun (`cel-demo-run-*`) created from the push event.

View the logs:

```bash
tkn pipelinerun logs --last -f
```

You should see "Action: push" and "Repository: my-app" in the output.

## Send a pull_request event (should be filtered out)

Now send an event with `action: "pull_request"` - this does NOT match the filter:

```bash
curl -s -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "action": "pull_request",
    "repository": {
      "name": "my-app",
      "url": "https://github.com/example/my-app"
    },
    "pull_request": {
      "number": 42,
      "title": "Add feature"
    }
  }'
```

## Verify the filter worked

Wait a moment and check the PipelineRun count:

```bash
sleep 5
kubectl get pipelinerun -l triggers.tekton.dev/eventlistener=cel-demo --no-headers | wc -l
```

You should still see only **1** PipelineRun - the one from the push event. The
pull_request event was silently rejected by the CEL filter.

This is the power of CEL interceptors: your Pipelines only run when the right
events arrive, saving cluster resources and avoiding unnecessary builds.
