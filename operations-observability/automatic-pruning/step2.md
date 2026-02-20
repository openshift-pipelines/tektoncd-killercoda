# Configure automatic pruning via TektonConfig

The Tekton Operator includes a built-in pruner that is configured through the
TektonConfig resource. The pruner runs as a CronJob managed by the Operator.

## Check the current pruner configuration

First, see if any pruner configuration exists:

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pruner}' 2>/dev/null
echo ""
```

If this is empty, no pruning is configured -- which means runs will accumulate
indefinitely.

## Configure the pruner

Set up the pruner to keep only the 3 most recent runs of each type, running
every 5 minutes. Apply this configuration:

```bash
kubectl patch tektonconfig config --type merge -p '{
  "spec": {
    "pruner": {
      "resources": ["taskrun", "pipelinerun"],
      "keep": 3,
      "schedule": "*/5 * * * *"
    }
  }
}'
```

## Understand the pruner configuration

The pruner configuration fields are:

| Field | Description | Example |
|-------|-------------|---------|
| `resources` | Which resource types to prune | `["taskrun", "pipelinerun"]` |
| `keep` | Number of most recent runs to retain | `3` |
| `schedule` | Cron expression for when pruning runs | `*/5 * * * *` |

The `schedule` field uses standard cron syntax:

- `*/5 * * * *` -- Every 5 minutes
- `0 * * * *` -- Every hour
- `0 0 * * *` -- Daily at midnight
- `0 0 * * 0` -- Weekly on Sunday

## Verify the configuration was applied

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pruner}' | python3 -m json.tool
```

You should see the pruner configuration with `resources`, `keep`, and `schedule`
fields.

## Check that the Operator created the CronJob

The Operator translates the pruner configuration into a Kubernetes CronJob:

```bash
kubectl get cronjob -A 2>/dev/null | grep -i prun
```

The Operator manages this CronJob automatically. When you change the pruner
configuration in TektonConfig, the Operator updates the CronJob accordingly.

## Additional pruner options

The pruner supports additional configuration for more fine-grained control:

- **keep-since** -- Instead of keeping a fixed number, keep runs newer than a
  duration (e.g., `1440` for 24 hours in minutes)
- **per-resource** pruning -- You can specify different retention for TaskRuns
  and PipelineRuns

For example, to keep runs from the last 24 hours instead of a fixed count:

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pruner.keep}'
echo ""
```

This confirms the `keep` value is set. In the next step, you will wait for the
pruner to run and verify that old runs are cleaned up.
