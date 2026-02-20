# Set up a GitOps repository

In GitOps, a Git repository holds the desired state of your application. ArgoCD
watches this repository and automatically deploys any changes to your Kubernetes
cluster. This means deployments are auditable, repeatable, and versioned.

## Get the Git server URL

A bare Git repository and a git daemon were set up during installation. The git
daemon makes the repository accessible over the network so that pods (ArgoCD,
Tekton) can reach it. Get the URL:

```bash
NODE_IP=$(cat /tmp/node-ip)
echo "Git repo URL for pods: git://${NODE_IP}/gitops-repo.git"
```

## Clone the repository

Clone the bare Git repository to a working directory:

```bash
git clone /opt/gitops-repo.git /root/gitops-repo
cd /root/gitops-repo
git config user.email "demo@example.com"
git config user.name "Demo User"
```

## Add Kubernetes manifests

Create a Deployment and Service for a simple demo application:

```bash
mkdir -p /root/gitops-repo/manifests
```

Create the Deployment manifest:

```bash
cat <<EOF > /root/gitops-repo/manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
  labels:
    app: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-app
  template:
    metadata:
      labels:
        app: demo-app
    spec:
      containers:
        - name: demo-app
          image: nginx:1.24
          ports:
            - containerPort: 80
EOF
```

Create the Service manifest:

```bash
cat <<EOF > /root/gitops-repo/manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-app
spec:
  selector:
    app: demo-app
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
EOF
```

## Push to the GitOps repository

```bash
cd /root/gitops-repo
git add .
git commit -m "Initial deployment manifests"
git push origin master
```

## Create the ArgoCD Application

Now tell ArgoCD to watch this Git repository and deploy its contents. The
Application uses the `git://` protocol URL so the ArgoCD repo-server pod can
access the repository over the network:

```bash
NODE_IP=$(cat /tmp/node-ip)
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: git://${NODE_IP}/gitops-repo.git
    targetRevision: HEAD
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
EOF
```

Verify the Application was created:

```bash
kubectl get application -n argocd
```

You should see `demo-app` listed. At this point, ArgoCD knows about the
repository but has not yet synced (deployed) the application. The application
status will show `OutOfSync` - this is expected because we have not triggered a
sync yet.

## Understanding the GitOps flow

The key concept here is that the Git repository is the **single source of
truth**. Rather than running `kubectl apply` directly, all changes go through
Git. ArgoCD then reconciles the cluster state to match the repository. This
provides:

- **Audit trail** - every change is a Git commit
- **Rollback** - revert a Git commit to roll back a deployment
- **Consistency** - the cluster always matches what is in Git
