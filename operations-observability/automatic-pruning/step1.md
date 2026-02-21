# See the problem: accumulated runs

The background setup created a sample Task and ran it 10 times, simulating a
pipeline that runs regularly over time. Let us see the impact.

## Count the accumulated TaskRuns

List all TaskRuns in the default namespace:

<!-- e2e-skip -->
```bash
tkn taskrun list
```

You should see around 10 TaskRuns listed. In a real production cluster, this
number could be in the thousands after weeks of operation.

## Check the count with kubectl

```bash
kubectl get taskrun --no-headers | wc -l
```

## Examine the storage impact

Each TaskRun object is stored in etcd. View the size of a single TaskRun:

```bash
kubectl get taskrun -o json | python3 -c "
import json, sys
data = json.load(sys.stdin)
items = data.get('items', [])
total_chars = len(json.dumps(data))
print(f'Total TaskRuns: {len(items)}')
print(f'Total JSON size: {total_chars:,} characters')
if items:
    avg = total_chars // len(items)
    print(f'Average per TaskRun: {avg:,} characters')
    print(f'Projected at 1000 runs: {avg * 1000:,} characters')
"
```

Even with simple Tasks, each TaskRun stores metadata, spec, status, and
conditions. At scale, this adds up quickly.

## The real-world scenario

Consider a CI/CD pipeline that runs 20 times per day. In one month, that is
approximately 600 PipelineRuns, each with multiple child TaskRuns. Without
pruning:

- After 1 month: ~600 PipelineRuns + ~1800 TaskRuns
- After 6 months: ~3600 PipelineRuns + ~10800 TaskRuns
- After 1 year: ~7200 PipelineRuns + ~21600 TaskRuns

This is why automatic pruning is essential for any production Tekton
installation. In the next step, you will configure the Operator's built-in
pruner to handle this automatically.
