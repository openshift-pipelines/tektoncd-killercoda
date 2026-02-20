# Connect CI to CD: Tekton triggers ArgoCD sync

With the CI pipeline ready and the GitOps repo connected to ArgoCD, it is time
to run the full end-to-end flow: Tekton builds and updates the manifests, then
ArgoCD deploys them to the cluster.

## Run the CI Pipeline

Start the Tekton CI pipeline:

```bash
tkn pipeline start gitops-ci --use-param-defaults
```

Watch the pipeline execution:

```bash
tkn pipelinerun logs --last -f
```

You should see output from all three Tasks:

- `run-tests` prints test results
- `build-image` produces the new tag `1.25`
- `update-manifests` updates the GitOps repo and pushes the change

Wait for the PipelineRun to complete:

```bash
kubectl wait --for=condition=Succeeded pipelinerun \
  -l tekton.dev/pipeline=gitops-ci --timeout=120s
```

## Verify the GitOps repo was updated

Check that the GitOps repository now has the updated image tag:

```bash
cd /root/gitops-repo
git pull origin master
grep "image:" manifests/deployment.yaml
```

You should see `image: nginx:1.25` -- the tag was updated by Tekton.

## Trigger ArgoCD sync

Now that Tekton has updated the GitOps repository, tell ArgoCD to sync the
application. In a real production setup, this could be automated (which you will
configure in the next step). For now, trigger a manual sync:

```bash
argocd app sync demo-app --core
```

If the sync command has issues with authentication in the core install, you can
alternatively use kubectl to trigger a sync by refreshing the Application:

```bash
kubectl patch application demo-app -n argocd --type merge \
  -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD","syncStrategy":{"apply":{"force":false}}}}}'
```

Wait a moment, then check the application status:

```bash
kubectl get application demo-app -n argocd -o jsonpath='{.status.sync.status}'
echo ""
```

## Verify the deployment

Check that the deployment was updated in the cluster:

```bash
kubectl get deployment demo-app -o jsonpath='{.spec.template.spec.containers[0].image}'
echo ""
```

You should see `nginx:1.25`. The full CI/CD flow worked:

1. Tekton ran the CI pipeline (test, build, update manifests)
2. The GitOps repo was updated with the new image tag
3. ArgoCD synced the cluster to match the GitOps repo
4. The Deployment is now running the new image

This is the core of GitOps CI/CD: **Tekton pushes changes to Git, ArgoCD pulls
changes from Git to the cluster.**
