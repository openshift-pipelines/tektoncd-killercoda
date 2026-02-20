# Congratulations!

You have built a complete CI/CD pipeline with Tekton that builds and deploys
an application to Kubernetes!

## What you learned

- How to install and use Tasks from the **Tekton Catalog** (git-clone)
- How to build container images in Kubernetes using **Kaniko**
- How to deploy applications using kubectl in a Task
- How to chain build and deploy Tasks into a **Pipeline** with shared Workspaces

## Real-world CI/CD with Tekton

The Pipeline you built follows the same pattern used in production:

1. **Clone** source code from Git (using the catalog git-clone Task)
2. **Build** a container image (using Kaniko, Buildah, or other tools)
3. **Push** the image to a container registry
4. **Deploy** to Kubernetes (using kubectl, Helm, or Kustomize)

To make this production-ready, you would:
- Push images to a real container registry (Docker Hub, quay.io, etc.)
- Add automated testing Tasks between build and deploy
- Use Tekton Triggers to automate the Pipeline on git push events
- Add security scanning Tasks for vulnerability detection

## Additional resources

- [Tekton Catalog on Artifact Hub](https://artifacthub.io/packages/search?org=tektoncd&sort=relevance&page=1) - Reusable Tasks for common operations
- [Build and push with Kaniko](https://tekton.dev/docs/how-to-guides/kaniko-build-push/)
- [Clone a Git repository](https://tekton.dev/docs/how-to-guides/clone-repository/)
- [Tekton Chains](https://tekton.dev/docs/chains/) - Supply chain security for your pipelines
