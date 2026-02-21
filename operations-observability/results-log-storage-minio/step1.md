# Configure Results for log storage

## The problem: logs disappear with pods

When a TaskRun completes, the step output lives in the pod's container logs.
Let's see this in action. First, verify that all components are running:

```bash
kubectl get pods -n tekton-pipelines
```

```bash
kubectl get pods -n minio
```

Now create a simple Task and run it:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: verbose-task
spec:
  steps:
    - name: generate-output
      image: alpine:3.19
      script: |
        #!/bin/sh
        echo "=== Build Log Output ==="
        echo "Step 1: Downloading dependencies..."
        echo "Step 2: Compiling source code..."
        echo "Step 3: Running unit tests... 42 passed, 0 failed"
        echo "Step 4: Packaging artifact..."
        echo "Build completed successfully at: $(date -u)"
        echo "========================"
EOF
```

Run the Task:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: verbose-task-run-demo
spec:
  taskRef:
    name: verbose-task
EOF
```

Wait for it to complete and check the logs:

```bash
kubectl wait --for=condition=Succeeded taskrun/verbose-task-run-demo --timeout=120s
tkn taskrun logs verbose-task-run-demo
```

The logs are visible because the pod still exists. Now delete the pod:

```bash
kubectl delete pod -l tekton.dev/taskRun=verbose-task-run-demo
```

Try to read the logs again:

```bash
tkn taskrun logs verbose-task-run-demo
```

The logs are gone. The TaskRun still exists, but its log data has been lost.
This is exactly the problem that Results log storage solves.

## Create the MinIO bucket for logs

Before configuring Results, we need a bucket in MinIO to store the logs.
Port-forward the MinIO service and create a bucket using the MinIO client:

<!-- e2e-skip -->
```bash
kubectl port-forward -n minio svc/minio 9000:9000 &
sleep 3
```

Configure the MinIO client and create a bucket:

```bash
mc alias set local http://localhost:9000 minioadmin minioadmin
mc mb local/tekton-logs
mc ls local/
```

You should see the `tekton-logs` bucket listed.

## Create a secret for MinIO S3 credentials

Results needs S3 credentials to write logs to MinIO. Create a secret in the
`tekton-pipelines` namespace:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: tekton-results-s3
  namespace: tekton-pipelines
type: Opaque
stringData:
  aws_access_key_id: minioadmin
  aws_secret_access_key: minioadmin
EOF
```

## Configure Results for S3 log storage

Now update the Results configuration to enable log storage with MinIO. The
Results ConfigMap controls where logs are stored. We need to patch it to point
at our MinIO instance:

```bash
MINIO_CLUSTER_IP=$(kubectl get svc minio -n minio -o jsonpath='{.spec.clusterIP}')

kubectl patch configmap tekton-results-config \
  -n tekton-pipelines \
  --type merge \
  -p "{
    \"data\": {
      \"logs_api\": \"true\",
      \"logs_type\": \"S3\",
      \"logs_path\": \"tekton-logs\",
      \"storage_emulator_host\": \"${MINIO_CLUSTER_IP}:9000\",
      \"s3_bucket_name\": \"tekton-logs\",
      \"s3_endpoint\": \"http://${MINIO_CLUSTER_IP}:9000\",
      \"s3_access_key_id\": \"minioadmin\",
      \"s3_secret_access_key\": \"minioadmin\",
      \"s3_region\": \"us-east-1\",
      \"s3_multi_part_size\": \"5242880\"
    }
  }"
```

Restart the Results pods so they pick up the new configuration:

```bash
kubectl rollout restart deployment tekton-results-watcher -n tekton-pipelines
kubectl rollout restart deployment tekton-results-api-service -n tekton-pipelines
sleep 5
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-results \
  -n tekton-pipelines --timeout=120s
```

Verify the configuration was applied:

```bash
kubectl get configmap tekton-results-config -n tekton-pipelines -o jsonpath='{.data.logs_api}'
```

This should print `true`, confirming that log storage is enabled.
