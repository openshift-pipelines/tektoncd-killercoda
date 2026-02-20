# Browse stored logs

In this final step, you will explore what Results stored in MinIO and
understand the persistence value this brings to your CI/CD operations.

## Browse MinIO contents

The MinIO client (`mc`) was installed during setup. Let's see what Results
stored in the `tekton-logs` bucket:

```bash
mc ls local/tekton-logs/ --recursive
```

You should see objects stored by Results. Each log entry corresponds to a
TaskRun's step output.

## Check the bucket size

```bash
mc du local/tekton-logs/
```

Even a few pipeline runs generate meaningful log data. In a production
environment, this bucket would grow over time as pipelines run continuously.

## Run more Pipelines and watch logs accumulate

Let's run the pipeline a few more times to see how logs accumulate:

```bash
for i in 2 3; do
  cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: build-and-test-run-${i}
spec:
  pipelineRef:
    name: build-and-test
EOF
  sleep 2
done
```

Wait for them to complete:

```bash
sleep 30
kubectl wait --for=condition=Succeeded pipelinerun/build-and-test-run-2 --timeout=120s
kubectl wait --for=condition=Succeeded pipelinerun/build-and-test-run-3 --timeout=120s
```

Give the Results watcher time to upload:

```bash
sleep 15
```

Now check MinIO again -- you should see more objects:

```bash
mc ls local/tekton-logs/ --recursive
```

## Query the Results API for all runs

```bash
curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('results', [])
print(f'Total results stored: {len(results)}')
for r in results:
    print(f'  - {r[\"name\"]} (created: {r[\"createTime\"]})')
"
```

## Delete all pods and verify persistence

Now let's do the ultimate test -- delete all TaskRun pods and show that
everything is still accessible:

```bash
kubectl delete pod -l tekton.dev/pipelineRun=build-and-test-run-2
kubectl delete pod -l tekton.dev/pipelineRun=build-and-test-run-3
```

Confirm pods are gone:

```bash
kubectl get pods -l tekton.dev/pipeline=build-and-test
```

But the data persists in Results:

```bash
curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('results', [])
print(f'Results still available: {len(results)}')
print('Log storage in MinIO is independent of pod lifecycle!')
"
```

And the logs are still in MinIO:

```bash
echo "Objects in MinIO after pod deletion:"
mc ls local/tekton-logs/ --recursive | wc -l
echo "files still stored"
```

## The persistence value

Here is why this matters in production:

1. **Prune aggressively** -- you can configure short TTLs for PipelineRuns
   and TaskRuns to keep etcd small, knowing that all data is preserved in
   Results and MinIO
2. **Debug historical failures** -- when a build fails on Friday, you can
   still read the full step logs on Monday, even if the pod was long gone
3. **Compliance and audit** -- S3 storage supports lifecycle policies,
   versioning, and retention rules that meet enterprise compliance requirements
4. **Cost-effective** -- MinIO or S3 storage is significantly cheaper than
   keeping thousands of completed pods in Kubernetes
