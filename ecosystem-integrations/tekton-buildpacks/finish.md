# Congratulations!

You have learned how to use **Cloud Native Buildpacks** with Tekton to build
container images without Dockerfiles.

## What you learned

- Setting up the **Buildpacks Task** for Tekton
- Building applications **without a Dockerfile** (auto-detection)
- Creating a **Pipeline** with clone, build (Buildpacks), and push stages

## Key points to remember

- Buildpacks auto-detect language and framework (Go, Node.js, Python, Java, etc.)
- The builder image contains all detection and compilation logic
- Memory-intensive: allocate at least 2GB for the build step
- Images are pushed to the specified registry automatically

## What's next

- [Tekton + ArgoCD](https://killercoda.com/tekton/course/ecosystem-integrations/tekton-argocd-gitops) - Deploy built images with GitOps
- [Tekton Bundles](https://killercoda.com/tekton/course/cli-mastery-catalog/tekton-bundles) - Package Tasks as OCI artifacts
- [Buildpacks documentation](https://buildpacks.io/) - Full reference
