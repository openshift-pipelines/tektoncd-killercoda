# Tekton + ArgoCD: GitOps CI/CD Pipeline

In modern Kubernetes-native CI/CD, there is a clean separation of concerns:

- **Tekton** handles Continuous Integration (CI) - building, testing, and
  producing artifacts.
- **ArgoCD** handles Continuous Deployment (CD) - deploying applications to
  Kubernetes using the GitOps pattern.

This is the industry-standard approach. Tekton runs pipelines that update
manifests in a Git repository. ArgoCD watches that repository and ensures the
cluster state always matches what is declared in Git. The Git repository becomes
the single source of truth for your deployed applications.

In this tutorial, you will learn:

- How to set up a **GitOps repository** with Kubernetes manifests
- How to create a **Tekton CI Pipeline** that builds and updates manifests
- How to connect Tekton to ArgoCD so that **CI automatically triggers CD**
- How to enable **auto-sync and health checks** for production workflows

While the environment loads, Tekton Pipelines, ArgoCD (core install), and the
`tkn` and `argocd` CLIs are being installed in the background. This may take a
few minutes.
