# Congratulations!

You have learned how to **migrate from Jenkins to Tekton** by converting a
Jenkinsfile to Tekton Pipeline resources.

## What you learned

- **Concept mapping**: Jenkins stages -> Tasks, agents -> images, plugins -> catalog
- **Converting a Jenkinsfile**: Build -> Test (parallel) -> Deploy -> Cleanup
- **Migration patterns**: workspaces, secrets, parallel stages, finally tasks

## Key points to remember

- Jenkins stages map to PipelineTasks
- Parallel stages become Tasks without shared `runAfter` dependencies
- `post { always }` becomes `finally` tasks
- Stash/unstash becomes shared workspaces
- Jenkins credentials become Kubernetes Secrets
- No Jenkins server needed -- Tekton runs natively on Kubernetes

## What's next

- [Tekton + ArgoCD](https://killercoda.com/tekton/course/ecosystem-integrations/tekton-argocd-gitops) - GitOps deployment pattern
- [Pipelines as Code](https://killercoda.com/tekton/course/cli-mastery-catalog/pipelines-as-code) - Pipeline definitions in Git
- [Migration documentation](https://tekton.dev/docs/) - Full Tekton reference
