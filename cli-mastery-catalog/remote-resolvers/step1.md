# Use the Hub Resolver to fetch from Artifact Hub

The **Hub Resolver** fetches Task and Pipeline definitions from
[Artifact Hub](https://artifacthub.io/), the community catalog for Tekton
resources. Instead of downloading a Task YAML and applying it to your cluster,
you simply reference it by name, version, and catalog -- the resolver does the
rest at runtime.

## Create a TaskRun with the Hub Resolver

Create a TaskRun that fetches the `git-clone` task from the Tekton catalog on
Artifact Hub:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: hub-resolver-demo
  labels:
    tutorial: remote-resolvers
spec:
  taskRef:
    resolver: hub
    params:
      - name: catalog
        value: tekton-catalog-tasks
      - name: kind
        value: task
      - name: name
        value: git-clone
      - name: version
        value: "0.9"
  workspaces:
    - name: output
      emptyDir: {}
  params:
    - name: url
      value: "https://github.com/tektoncd/pipeline.git"
EOF
```

There are four important things to notice here:

1. **`resolver: hub`** tells Tekton to use the Hub Resolver instead of looking
   for a locally installed Task.
2. **`catalog: tekton-catalog-tasks`** specifies which Artifact Hub catalog to
   search. This is the official Tekton community catalog.
3. **`name: git-clone`** and **`version: "0.9"`** identify the exact Task and
   version to fetch. Pinning the version ensures reproducible builds.
4. **`workspaces`** provides the `output` workspace that the `git-clone` task
   requires. We use `emptyDir` so the TaskRun can execute without needing a
   PersistentVolumeClaim.

Notice that we never ran `kubectl apply` on the `git-clone` Task itself. The
resolver fetches the Task definition directly from Artifact Hub when the
TaskRun is created.

## Watch the TaskRun

Wait for the TaskRun to start and then view the logs:

```bash
kubectl wait --for=condition=Succeeded=False --for=condition=Succeeded=True \
  taskrun/hub-resolver-demo --timeout=120s 2>/dev/null || true
```

```bash
tkn taskrun logs hub-resolver-demo
```

## Check the TaskRun status

Inspect the TaskRun to see the resolved Task reference:

```bash
tkn taskrun describe hub-resolver-demo
```

In the output, you can see that Tekton resolved the Task from Artifact Hub at
runtime. The `git-clone` task was never installed as a local resource -- it was
fetched, resolved, and executed entirely through the Hub Resolver.

## Verify the Task was not installed locally

Confirm that no `git-clone` Task exists in the default namespace:

```bash
kubectl get task git-clone 2>&1 || echo "As expected: git-clone Task is not installed locally"
```

This is the key benefit of resolvers -- your cluster stays clean while you
leverage the entire community catalog.
