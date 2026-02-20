# Congratulations!

You have successfully built a complete GitOps CI/CD pipeline using Tekton and
ArgoCD.

In this tutorial, you learned:

- How to set up a **GitOps repository** as the single source of truth
- How to create a **Tekton CI Pipeline** that runs tests, builds images, and
  updates manifests
- How to connect **Tekton (CI) to ArgoCD (CD)** for end-to-end automation
- How to enable **auto-sync and health checks** for production workflows

This pattern -- Tekton for CI, ArgoCD for CD -- is widely used in production
Kubernetes environments. It provides a clean separation of concerns, an audit
trail through Git, and reliable automated deployments.

To learn more, explore these resources:

- [Tekton documentation](https://tekton.dev/docs/) - Full Tekton reference
- [ArgoCD documentation](https://argo-cd.readthedocs.io/) - Full ArgoCD reference
- [GitOps principles](https://opengitops.dev/) - The OpenGitOps project
