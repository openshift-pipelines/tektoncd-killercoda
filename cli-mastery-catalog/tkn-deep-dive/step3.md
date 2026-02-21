# Output formatting: JSON, YAML, and jq integration

The `tkn` CLI supports structured output formats that integrate well with other
tools. In this step, you will learn how to extract machine-readable data from
Tekton resources using JSON, YAML, and `jq`.

## List resources as JSON

Use the `-o json` flag to get structured output:

<!-- e2e-skip -->
```bash
tkn task list -o json | jq '.'
```

This pipes the JSON output through `jq` for pretty-printing. You can extract
specific fields. For example, to get just the Task names:

<!-- e2e-skip -->
```bash
tkn task list -o json | jq '.items[].metadata.name'
```

## Describe a run as JSON

The `describe` command also supports JSON output. Describe the latest PipelineRun
as JSON and extract the status conditions:

<!-- e2e-skip -->
```bash
tkn pipelinerun describe --last -o json | jq '.status.conditions'
```

This returns the Kubernetes condition array, which tells you whether the run
succeeded, failed, or is still running. You can check the status with:

<!-- e2e-skip -->
```bash
tkn pipelinerun describe --last -o json | jq '.status.conditions[0].status'
```

## Extract run timing information

Use `jq` to extract the start and completion times:

<!-- e2e-skip -->
```bash
tkn pipelinerun describe --last -o json | jq '{
  name: .metadata.name,
  status: .status.conditions[0].status,
  reason: .status.conditions[0].reason,
  startTime: .status.startTime,
  completionTime: .status.completionTime
}'
```

This pattern is useful for building dashboards or feeding data into monitoring
systems.

## Dry-run mode for YAML generation

The `--dry-run` flag generates the resource YAML without actually creating
anything on the cluster. This is useful for generating templates or reviewing
what `tkn` would create:

```bash
tkn task start echo-greeting --dry-run -o yaml
```

This prints the TaskRun YAML that would be submitted to the cluster. You can
redirect this to a file for version control or modify it before applying:

```bash
tkn task start echo-greeting \
  -p greeting="Hey" \
  -p name="Developer" \
  --dry-run -o yaml
```

Notice how the generated YAML includes the parameter values you specified. This
is a great way to understand what `tkn start` does under the hood.

## Combine JSON output with kubectl

You can also mix `tkn` and `kubectl` for advanced queries. For example, list all
PipelineRuns and their statuses:

<!-- e2e-skip -->
```bash
kubectl get pipelinerun -o json | jq '.items[] | {name: .metadata.name, succeeded: .status.conditions[0].status}'
```

The combination of `tkn`, `kubectl`, and `jq` gives you a powerful toolkit for
operational management of Tekton resources.
