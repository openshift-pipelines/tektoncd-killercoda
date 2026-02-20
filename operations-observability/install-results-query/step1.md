# Understand what Results provides

## The problem: etcd is not a database

Tekton stores every PipelineRun and TaskRun as a Kubernetes custom resource.
Under the hood, Kubernetes keeps these objects in **etcd**, a key-value store
designed for cluster state -- not for long-term data retention.

As your cluster runs hundreds or thousands of pipelines, the etcd database
grows. Cluster administrators solve this by **pruning** old runs, but once
pruned, that data is gone forever. You cannot answer questions like "What was
the success rate of our build pipeline last month?"

## How Results solves it

Tekton Results consists of three main components:

1. **Watcher** -- monitors the Kubernetes API for completed PipelineRuns and
   TaskRuns and sends their data to the API server
2. **API Server** -- a gRPC/REST service that stores and serves result data
3. **PostgreSQL** -- the backing database for long-term storage

The watcher runs in the background and automatically captures every completed
run. No changes to your existing Pipelines or Tasks are needed.

## Verify the installation

Let's confirm that all the Tekton Results components are running. Check the
pods in the `tekton-pipelines` namespace:

```bash
kubectl get pods -n tekton-pipelines
```

You should see the standard Tekton Pipelines controller and webhook pods,
plus the Results watcher and API server pods:

```bash
kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-results
```

Verify both the watcher and the API server are in the `Running` state:

```bash
kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-results -o wide
```

You can also confirm the Results API service is registered:

```bash
kubectl get svc -n tekton-pipelines | grep results
```

You should see `tekton-results-api-service` in the output. This is the
endpoint that both the watcher and API clients use.
