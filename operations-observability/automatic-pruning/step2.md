# Configure automatic pruning via TektonConfig

The Tekton Operator includes a built-in pruner that is configured through the
TektonConfig resource. The pruner runs as a CronJob managed by the Operator.

## Check the current pruner configuration

First, see if any pruner configuration exists:

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pruner}' 2>/dev/null
echo ""
```

If this is empty, no pruning is configured - which means runs will accumulate
indefinitely.

## Configure the pruner

Set up the pruner to keep only the 3 most recent runs of each type, running
every minute (for this tutorial; production environments use longer intervals).
Apply this configuration:

```bash
kubectl patch tektonconfig config --type merge -p '{
  "spec": {
    "pruner": {
      "resources": ["taskrun", "pipelinerun"],
      "keep": 3,
      "schedule": "*/1 * * * *"
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
| `schedule` | Cron expression for when pruning runs | `*/1 * * * *` |

The `schedule` field uses standard cron syntax:

- `*/1 * * * *` - Every minute (tutorial/testing)
- `0 * * * *` - Every hour
- `0 0 * * *` - Daily at midnight
- `0 0 * * 0` - Weekly on Sunday

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

- **keep-since** - Instead of keeping a fixed count, keep runs newer than a
  specified number of minutes (e.g., `1440` keeps runs from the last 24 hours).
  Note: `keep` and `keep-since` are mutually exclusive.
- **prune-per-resource** - Prune per pipeline/task name instead of globally
- **disabled** - Set to `true` to temporarily disable pruning

Verify the `keep` value is set:

```bash
kubectl get tektonconfig config -o jsonpath='{.spec.pruner.keep}'
echo ""
```

In the next step, you will wait for the pruner to run and verify that old runs
are cleaned up.
