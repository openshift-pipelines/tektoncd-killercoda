# Use authenticated ServiceAccounts in Pipelines

Let's test authentication end-to-end by deploying a Gitea instance (a
lightweight self-hosted Git server) inside the cluster, creating a private
repository, and cloning it using Tekton with authenticated credentials.

## Deploy Gitea in the cluster

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gitea
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gitea
  template:
    metadata:
      labels:
        app: gitea
    spec:
      containers:
        - name: gitea
          image: gitea/gitea:latest
          ports:
            - containerPort: 3000
          env:
            - name: GITEA__security__INSTALL_LOCK
              value: "true"
---
apiVersion: v1
kind: Service
metadata:
  name: gitea
spec:
  selector:
    app: gitea
  ports:
    - port: 3000
      targetPort: 3000
EOF
```

Wait for Gitea to be ready:

```bash
kubectl wait --for=condition=ready pod -l app=gitea --timeout=120s
```

## Create a Gitea user and private repository

```bash
# Create a user via Gitea API
kubectl exec deployment/gitea -- gitea admin user create \
  --username tekton-user \
  --password tekton-pass \
  --email tekton@example.com \
  --must-change-password=false
```

```bash
# Create a private repository with a file
curl -s -X POST "http://$(kubectl get svc gitea -o jsonpath='{.spec.clusterIP}'):3000/api/v1/user/repos" \
  -u tekton-user:tekton-pass \
  -H "Content-Type: application/json" \
  -d '{"name": "private-repo", "private": true, "auto_init": true}'
```

```bash
# Add a file to the repo
curl -s -X POST "http://$(kubectl get svc gitea -o jsonpath='{.spec.clusterIP}'):3000/api/v1/repos/tekton-user/private-repo/contents/hello.txt" \
  -u tekton-user:tekton-pass \
  -H "Content-Type: application/json" \
  -d '{"content": "'$(echo -n "Hello from a private repo!" | base64)'", "message": "Add hello.txt"}'
```

## Create Tekton credentials for the Gitea instance

Now create a Secret and ServiceAccount that Tekton will use to access our
private Gitea repository:

```bash
GITEA_HOST="http://gitea.default.svc.cluster.local:3000"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: gitea-credentials
  annotations:
    tekton.dev/git-0: ${GITEA_HOST}
type: kubernetes.io/basic-auth
stringData:
  username: tekton-user
  password: tekton-pass
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitea-bot
secrets:
  - name: gitea-credentials
EOF
```

## Install git-clone and create the Pipeline

```bash
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: show-file
spec:
  workspaces:
    - name: source
  steps:
    - name: show
      image: ubuntu
      script: |
        #!/usr/bin/env bash
        echo "=== Files in the cloned repository ==="
        ls -la \$(workspaces.source.path)/
        echo ""
        echo "=== Contents of hello.txt ==="
        cat \$(workspaces.source.path)/hello.txt
---
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
    - name: show
      runAfter:
        - clone
      taskRef:
        name: show-file
      workspaces:
        - name: source
          workspace: shared-workspace
EOF
```

## Run the Pipeline with authenticated credentials

```bash
GITEA_IP=$(kubectl get svc gitea -o jsonpath='{.spec.clusterIP}')

cat <<EOF | kubectl create -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: authenticated-clone-run-
spec:
  pipelineRef:
    name: authenticated-clone
  serviceAccountName: gitea-bot
  params:
    - name: repo-url
      value: http://gitea.default.svc.cluster.local:3000/tekton-user/private-repo.git
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

## Check the logs

```bash
tkn pipelinerun logs --last -f
```

You should see:

```
[clone : clone] ... Cloning into '/workspace/output'...
[show : show] === Files in the cloned repository ===
[show : show] ...
[show : show] === Contents of hello.txt ===
[show : show] Hello from a private repo!
```

Tekton successfully:
1. Read the `gitea-credentials` Secret from the `gitea-bot` ServiceAccount
2. Matched the `tekton.dev/git-0` annotation to the Gitea server URL
3. Injected `~/.gitconfig` and `~/.git-credentials` into the git-clone Step
4. Cloned the **private** repository without any credentials in the Pipeline YAML
