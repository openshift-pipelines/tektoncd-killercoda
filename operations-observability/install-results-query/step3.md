# Query Results with the API

Tekton Results exposes a REST API (v1alpha2) that lets you query pipeline
history programmatically. This is how dashboards, CLI tools, and automation
systems retrieve historical data.

## Set up API access

The Results API server listens on port 8080 inside the cluster. Since we
used a self-signed TLS certificate, we need to use `-k` (insecure) with
curl. First, let's port-forward the API service:

```bash
kubectl port-forward -n tekton-pipelines svc/tekton-results-api-service 8080:8080 &
```

Give it a moment to establish:

```bash
sleep 3
```

## List all Results in the default namespace

Query the Results API to list all results in the `default` namespace:

```bash
curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results | python3 -m json.tool
```

The response contains a `results` array. Each entry has:

- **name** - a unique identifier in the format `namespace/result-uid`
- **uid** - the result UUID
- **createTime** and **updateTime** - timestamps
- **annotations** and **summary** - metadata about the run

## List Records within a Result

Each Result contains **Records** - the actual PipelineRun and TaskRun data.
Let's list the records. First, grab the name of the first result:

```bash
RESULT_NAME=$(curl -sk https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data.get('results'):
    print(data['results'][0]['name'])
")
echo "Result: ${RESULT_NAME}"
```

Now list the records for that result:

```bash
curl -sk "https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/${RESULT_NAME}/records" | python3 -m json.tool
```

## Filter results

The Results API supports filtering with Common Expression Language (CEL).
For example, to find all results with a summary status of `SUCCESS`:

```bash
curl -sk "https://localhost:8080/apis/results.tekton.dev/v1alpha2/parents/default/results?filter=summary.status==SUCCESS" | python3 -m json.tool
```

## Generate more data

Let's run the pipeline a few more times to build up some history:

```bash
for i in 1 2 3; do
  cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: greeting-pipeline-run-
spec:
  pipelineRef:
    name: greeting-pipeline
EOF
  sleep 2
done
```

Wait for all runs to complete:

```bash
sleep 30
kubectl wait --for=condition=Succeeded pipelinerun -l tekton.dev/pipeline=greeting-pipeline --timeout=120s
```

Now query again to see the accumulated history:

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

This demonstrates the power of Results: even after you prune old
PipelineRuns from the cluster, this data remains in the database.
