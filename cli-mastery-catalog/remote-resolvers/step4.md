# Compare resolver types and choose the right one

Now that you have used three resolver types, let's compare them side by side and
build a Pipeline that mixes different resolvers for different tasks.

## Resolver comparison

| Resolver | Source | Best For | Requires |
|----------|--------|----------|----------|
| Hub | Artifact Hub | Community/catalog tasks | Internet access |
| Git | Git repository | Internal/private tasks | Git repo access |
| Cluster | In-cluster namespace | Shared org tasks | Task in target namespace |
| Bundle | OCI registry | Versioned task packages | OCI registry |

## Create a Pipeline that mixes resolvers

One of the most powerful aspects of resolvers is that you can mix and match them
within a single Pipeline. Each task reference can use a different resolver.

First, create a local Task that will be referenced directly (the traditional
way):

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: local-summary
  labels:
    tutorial: remote-resolvers
spec:
  params:
    - name: cluster-result
      type: string
  results:
    - name: summary
      description: Summary of the mixed-resolver pipeline
  steps:
    - name: summarize
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        echo "========================================="
        echo "  Mixed-Resolver Pipeline Summary"
        echo "========================================="
        echo "  Cluster task said: \$(params.cluster-result)"
        echo "  All resolver types worked successfully!"
        echo "========================================="
        echo -n "all-resolvers-passed" > \$(results.summary.path)
EOF
```

Now create the Pipeline that mixes a Cluster Resolver reference with a local
Task reference:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: mixed-resolvers
  labels:
    tutorial: remote-resolvers
spec:
  tasks:
    - name: cluster-task
      taskRef:
        resolver: cluster
        params:
          - name: kind
            value: task
          - name: name
            value: shared-task
          - name: namespace
            value: shared-tasks
      params:
        - name: message
          value: "Running from mixed-resolvers Pipeline"
    - name: summarize
      runAfter:
        - cluster-task
      taskRef:
        name: local-summary
      params:
        - name: cluster-result
          value: "completed"
EOF
```

This Pipeline demonstrates two different resolution strategies in one Pipeline:

1. **`cluster-task`** uses the **Cluster Resolver** to fetch `shared-task` from
   the `shared-tasks` namespace.
2. **`summarize`** uses a **local taskRef** (the traditional approach) to
   reference the `local-summary` Task in the current namespace.

## Run the mixed-resolver Pipeline

```bash
tkn pipeline start mixed-resolvers --showlog
```

Watch the output: each task is resolved from a different source, but they all
execute seamlessly within the same PipelineRun.

## Check the PipelineRun status

After the run completes, inspect the PipelineRun to see how each task was
resolved:

<!-- e2e-skip -->
```bash
tkn pipelinerun describe --last
```

You can also check the resolver status in the PipelineRun conditions:

<!-- e2e-skip -->
```bash
kubectl get pipelinerun --sort-by=.metadata.creationTimestamp \
  -o jsonpath='{.items[-1].status.conditions[0]}' | python3 -m json.tool
```

The condition should show `"type": "Succeeded"` with `"status": "True"`,
confirming that all resolver types worked correctly within the Pipeline.

## Choosing the right resolver

Use this decision guide when picking a resolver:

1. **Is the Task in the Tekton community catalog?** Use the **Hub Resolver**.
   It is the simplest option - just specify the task name and version.

2. **Is the Task in a Git repository (private or public)?** Use the **Git
   Resolver**. This gives you full control over the source revision and works
   with any Git hosting provider.

3. **Is the Task maintained by another team in your cluster?** Use the **Cluster
   Resolver**. This is the recommended replacement for ClusterTask and keeps
   tasks namespace-scoped with proper RBAC.

4. **Do you need versioned, immutable task packages?** Use the **Bundle
   Resolver**. OCI bundles provide container-registry-based distribution with
   image tags and digests for immutability.

5. **Is the Task specific to this Pipeline?** Use a **local taskRef** with the
   Task in the same namespace. Not everything needs a resolver.
