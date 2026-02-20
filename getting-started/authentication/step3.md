# Use authenticated ServiceAccounts in Pipelines

Now let's put it all together by creating a Pipeline that uses an authenticated
ServiceAccount to clone a repository and process its contents.

## Create the Pipeline

This Pipeline clones a Git repository using the authenticated ServiceAccount
and then lists the repository contents:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: list-repo-contents
spec:
  workspaces:
    - name: source
  steps:
    - name: list
      image: ubuntu
      script: |
        #!/usr/bin/env bash
        echo "=== Repository contents ==="
        ls -la \$(workspaces.source.path)/
        echo ""
        echo "=== File count ==="
        find \$(workspaces.source.path) -type f | wc -l
        echo "files found"
EOF
```

Install the git-clone Task:

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml
```

Create the Pipeline:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: authenticated-clone
spec:
  workspaces:
    - name: shared-workspace
  params:
    - name: repo-url
      type: string
    - name: revision
      type: string
      default: main
  tasks:
    - name: clone
      taskRef:
        name: git-clone
      params:
        - name: url
          value: \$(params.repo-url)
        - name: revision
          value: \$(params.revision)
        - name: deleteExisting
          value: "true"
      workspaces:
        - name: output
          workspace: shared-workspace
    - name: list-contents
      runAfter:
        - clone
      taskRef:
        name: list-repo-contents
      workspaces:
        - name: source
          workspace: shared-workspace
EOF
```

## Run the Pipeline with the authenticated ServiceAccount

For this demo, we'll clone a public repository. In production, you would
point this at a private repository and the `build-bot` ServiceAccount's
credentials would handle authentication:

```bash
cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: authenticated-clone-run-
spec:
  pipelineRef:
    name: authenticated-clone
  serviceAccountName: build-bot
  params:
    - name: repo-url
      value: https://github.com/tektoncd/website
    - name: revision
      value: main
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

Notice the key line: `serviceAccountName: build-bot` — this tells Tekton to
use the `build-bot` ServiceAccount (with its attached Git and registry Secrets)
for all Tasks in this PipelineRun.

## Check the logs

```bash
tkn pipelinerun logs --last -f
```

You should see the repository being cloned and the file listing displayed.

## Summary: The authentication pattern

```
Secret (credentials)      ServiceAccount        PipelineRun
┌──────────────────┐     ┌──────────────┐     ┌────────────────┐
│ git-credentials  │────▶│              │     │                │
│ (basic-auth)     │     │   build-bot  │◀────│ serviceAccount │
│                  │     │              │     │  Name: build-  │
│ registry-creds   │────▶│              │     │  bot           │
│ (dockerconfig)   │     └──────────────┘     └────────────────┘
└──────────────────┘
```

1. **Secrets** hold the actual credentials
2. **Annotations** on Secrets tell Tekton which hosts they apply to
3. **ServiceAccounts** bundle Secrets together
4. **PipelineRuns** reference a ServiceAccount to get all its credentials
