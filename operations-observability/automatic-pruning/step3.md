# Verify pruning works

The pruner is now configured to run every minute and keep only the 3 most recent
TaskRuns. Let us verify it works.

## Check current TaskRun count

Before the pruner runs, check how many TaskRuns exist:

```bash
echo "TaskRuns before pruning:"
kubectl get taskrun --no-headers | wc -l
tkn taskrun list
```

## Wait for the pruner to run

The pruner CronJob runs every minute. Wait for it to execute:

```bash
echo "Waiting for pruner to execute (should take about 1-2 minutes)..."
for i in $(seq 1 30); do
  CURRENT_COUNT=$(kubectl get taskrun --no-headers 2>/dev/null | wc -l)
  if [ "$CURRENT_COUNT" -le 3 ]; then
    echo "Pruning complete! TaskRun count is now: $CURRENT_COUNT"
    break
  fi
  if [ $((i % 6)) -eq 0 ]; then
    echo "  Still waiting... current count: $CURRENT_COUNT (attempt $i/30)"
  fi
  sleep 5
done
```

## Verify the result

After the pruner runs, check the TaskRun count:

```bash
echo "TaskRuns after pruning:"
kubectl get taskrun --no-headers | wc -l
tkn taskrun list
```

You should see only 3 (or fewer) TaskRuns remaining -- the most recent ones.
The older runs have been automatically cleaned up.

## Generate more runs to test ongoing pruning

Create a few more TaskRuns to confirm the pruner continues to work:

```bash
for i in $(seq 1 5); do
  kubectl create -f - <<EOF
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: new-run-
spec:
  taskRef:
    name: sample-task
EOF
  sleep 1
done
echo "Created 5 new TaskRuns."
kubectl get taskrun --no-headers | wc -l
```

After the next pruner cycle, the count will go back down to 3.

## Production recommendations

When configuring pruning for production, consider these guidelines:

**Schedule recommendations:**

| Environment | Schedule | Keep |
|-------------|----------|------|
| Development | `*/30 * * * *` (every 30 min) | 5-10 |
| Staging | `0 * * * *` (hourly) | 10-20 |
| Production | `0 0 * * *` (daily) | 50-100 |

**Best practices:**

- Always configure pruning when using the Tekton Operator in production
- Use Tekton Results to archive run data before it is pruned -- this gives you
  long-term history without the etcd storage cost
- Monitor etcd storage usage and adjust the `keep` value if needed
- Consider using `keep-since` instead of `keep` if your pipeline frequency
  varies significantly
- Test your pruning configuration in a non-production environment first

## Verify the pruner configuration one more time

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pruner}' | python3 -m json.tool
```

The pruner will continue running on the configured schedule, keeping your
cluster clean and performant.
