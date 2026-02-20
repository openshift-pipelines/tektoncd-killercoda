# Inspect fan-out TaskRuns

When a Matrix fans out a PipelineTask, Tekton creates individual TaskRuns for
each parameter combination. In this step, you will inspect these TaskRuns to
understand how Matrix distributes work.

## Describe the PipelineRun

Start by describing the latest PipelineRun:

```bash
tkn pipelinerun describe --last
```

The output shows the PipelineRun status and lists all child TaskRuns. Notice that
the `test` PipelineTask produced multiple TaskRuns - one for each matrix
combination.

## List the fan-out TaskRuns

Use `kubectl` to list all TaskRuns created by the Matrix fan-out. Each TaskRun
is labeled with the PipelineTask name:

```bash
kubectl get taskrun -l tekton.dev/pipelineTask=test --no-headers
```

You should see 6 TaskRuns listed. Each one corresponds to a unique combination of
`platform` and `version`.

## Inspect individual TaskRun parameters

To see what parameters each TaskRun received, examine them with `kubectl`:

```bash
kubectl get taskrun -l tekton.dev/pipelineTask=test \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.params[*].value}{"\n"}{end}'
```

This shows each TaskRun name alongside the parameter values it received. You can
see how Tekton distributed the Cartesian product - every combination of
(linux, mac, windows) x (1.20, 1.21) is represented.

## Check individual logs

You can view logs for a specific TaskRun by name. First, get the list of TaskRun
names:

```bash
kubectl get taskrun -l tekton.dev/pipelineTask=test --no-headers -o custom-columns=NAME:.metadata.name
```

Then view logs for any specific TaskRun (replace the name with one from your
output):

```bash
tkn taskrun logs --last
```

## Verify all TaskRuns succeeded

Check that every fan-out TaskRun completed successfully:

```bash
kubectl get taskrun -l tekton.dev/pipelineTask=test \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[0].status}{"\n"}{end}'
```

All TaskRuns should show `True` in the status column, confirming that every
platform/version combination was tested successfully.
