# Trigger the Pipeline with an event

Now let's simulate a GitHub push event by sending a JSON payload to the
EventListener. In a real setup, GitHub would send this automatically via
a webhook.

## Port-forward the EventListener

```bash
kubectl port-forward service/el-github-listener 8080:8080 > /dev/null 2>&1 &
```

Wait for the EventListener to accept connections:

```bash
for i in $(seq 1 30); do
  curl -s -o /dev/null -w '%{http_code}' http://localhost:8080 2>/dev/null && break
  sleep 2
done
```

## Send a simulated GitHub push event

```bash
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "repository": {
      "url": "https://github.com/tektoncd/pipeline"
    },
    "head_commit": {
      "id": "abc123def456",
      "message": "Add new feature"
    }
  }'
```

You should see a response indicating that the EventListener accepted the event.

## Check the PipelineRun

The EventListener should have created a new PipelineRun. Check for it:

<!-- e2e-skip -->
```bash
tkn pipelinerun list
```

You should see a PipelineRun with a name starting with `ci-pipeline-run-`.

## View the logs

<!-- e2e-skip -->
```bash
tkn pipelinerun logs --last -f
```

You should see output like:

```
[log-commit : log] =========================================
[log-commit : log] New commit detected!
[log-commit : log] =========================================
[log-commit : log] Repository: https://github.com/tektoncd/pipeline
[log-commit : log] Commit SHA: abc123def456
[log-commit : log] Message:    Add new feature
[log-commit : log] =========================================
```

The Trigger successfully:
1. Received the event via the EventListener
2. Extracted the repository URL, commit SHA, and message via the TriggerBinding
3. Created a PipelineRun via the TriggerTemplate
4. The Pipeline ran and logged the commit information

## Send another event

Try triggering the Pipeline again with different data:

```bash
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "repository": {
      "url": "https://github.com/tektoncd/triggers"
    },
    "head_commit": {
      "id": "789xyz000111",
      "message": "Fix bug in event processing"
    }
  }'
```

Check the logs again:

<!-- e2e-skip -->
```bash
tkn pipelinerun logs --last -f
```
