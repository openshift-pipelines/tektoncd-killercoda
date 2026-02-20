# Production patterns: auto-sync and health checks

In production, you do not want to manually trigger ArgoCD syncs after every CI
pipeline run. ArgoCD supports **automated sync** -- it will automatically detect
changes in the Git repository and apply them to the cluster.

## Enable auto-sync

Update the ArgoCD Application to enable automatic synchronization with self-heal
and pruning:

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
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
```

The key additions are under `syncPolicy.automated`:

- **prune: true** -- ArgoCD will delete resources that are no longer in the Git
  repo
- **selfHeal: true** -- If someone manually changes a resource in the cluster,
  ArgoCD will revert it to match Git

Verify the sync policy was updated:

```bash
kubectl get application demo-app -n argocd \
  -o jsonpath='{.spec.syncPolicy.automated}' | python3 -m json.tool
```

## Test the automated loop

Now simulate another CI run that updates the image tag. This time ArgoCD should
automatically detect and deploy the change without a manual sync.

Update the GitOps repository directly (simulating what Tekton would do):

```bash
cd /root/gitops-repo
sed -i 's|image: nginx:.*|image: nginx:1.26|' manifests/deployment.yaml
git add .
git commit -m "Update image to nginx:1.26"
git push origin master
```

ArgoCD polls the Git repository periodically (default: every 3 minutes). To
speed things up, you can force a refresh:

```bash
kubectl patch application demo-app -n argocd --type merge \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'
```

Wait for ArgoCD to detect and sync the change:

```bash
sleep 30
kubectl get deployment demo-app -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""
```

## Verify health checks

ArgoCD also tracks the health of your application. Check the health status:

```bash
kubectl get application demo-app -n argocd \
  -o jsonpath='{.status.health.status}'
echo ""
```

A healthy application reports `Healthy`. If pods fail to start or readiness
probes fail, ArgoCD reports `Degraded` or `Progressing`.

## Verify the deployment is running

```bash
kubectl get deployment demo-app
kubectl get pods -l app=demo-app
```

## Production recommendations

When running this pattern in production, consider:

- **Separate repositories** -- Keep application source code and GitOps manifests
  in separate repos. Tekton works on the source repo, and pushes manifest
  changes to the GitOps repo.
- **Image registry** -- Use a real container registry (e.g., Docker Hub, Harbor,
  Quay) instead of simulated builds. Tekton Tasks like `kaniko` or `buildah`
  can build and push real images.
- **Branch strategy** -- Use branches in the GitOps repo for staging vs.
  production. ArgoCD can watch different branches for different environments.
- **Notifications** -- Configure ArgoCD notifications to alert on sync failures,
  and Tekton Pipelines to send results to Slack or other systems.
- **RBAC** -- Restrict who can push to the GitOps repo and who can modify
  ArgoCD Applications.
