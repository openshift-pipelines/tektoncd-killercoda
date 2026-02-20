# Install catalog Tasks via Remote Resolvers

So far, you have been pre-installing Tasks with `kubectl apply`. Tekton also
supports **Remote Resolvers** that fetch Tasks at runtime without needing to
install them first. This is the modern approach for production Pipelines.

## Compare the two approaches

**Pre-install approach** (what you did in Steps 1 and 2):

```
kubectl apply -f <task-url>   # Install first
taskRef:
  name: git-clone             # Reference by name
```

**Resolver approach** (what you will do now):

```
taskRef:
  resolver: hub               # Fetch at runtime
  params:
    - name: catalog
      value: tekton-catalog-tasks
    - name: type
      value: artifact
    - name: kind
      value: task
    - name: name
      value: git-clone
    - name: version
      value: "0.9"
```

No `kubectl apply` needed - Tekton fetches the Task from Artifact Hub when the
PipelineRun starts.

## Create a Pipeline using the Hub Resolver

Create a Pipeline that uses the Hub resolver to fetch `git-clone` at runtime:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: resolver-demo
spec:
  params:
    - name: repo-url
      type: string
      description: The Git repository URL to clone
  workspaces:
    - name: shared-workspace
      description: Workspace for cloned source
  tasks:
    - name: fetch-source
      taskRef:
        resolver: hub
        params:
          - name: catalog
            value: tekton-catalog-tasks
          - name: type
            value: artifact
          - name: kind
            value: task
          - name: name
            value: git-clone
          - name: version
            value: "0.9"
      workspaces:
        - name: output
          workspace: shared-workspace
      params:
        - name: url
          value: $(params.repo-url)
EOF
```

## Run the resolver-based Pipeline

Now run the Pipeline. The Hub resolver will fetch `git-clone` from Artifact Hub
at runtime:

```bash
cat <<'EOF' | kubectl create -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: resolver-demo-run-
spec:
  pipelineRef:
    name: resolver-demo
  params:
    - name: repo-url
      value: https://github.com/tektoncd/pipeline
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF
```

## Watch the PipelineRun

```bash
tkn pipelinerun list
```

Watch the logs (use the most recent PipelineRun):

```bash
PR_NAME=$(kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
tkn pipelinerun logs "$PR_NAME" -f
```

## Verify the resolver worked

Check that the PipelineRun resolved and ran the Task successfully:

```bash
PR_NAME=$(kubectl get pipelinerun --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
kubectl get pipelinerun "$PR_NAME" -o jsonpath='{.status.conditions[0].reason}'
echo ""
```

The key advantage of resolvers is that your cluster does not need pre-installed
Tasks. This reduces maintenance burden, avoids version drift between teams, and
ensures every PipelineRun gets exactly the Task version it specifies.
