# Build and Deploy an Application with Tekton

In this tutorial, you'll build a realistic CI/CD pipeline that:

1. **Clones** source code from a Git repository
2. **Builds** a container image from the source
3. **Deploys** the application to Kubernetes

This combines the concepts from the previous tutorials — Tasks, Pipelines,
Workspaces, and Parameters — into a practical workflow.

You will use:

- The **git-clone** Task from the [Tekton Catalog](https://artifacthub.io/packages/search?org=tektoncd&sort=relevance&page=1)
  to clone source code
- A custom **build-and-push** Task using
  [Kaniko](https://github.com/GoogleContainerTools/kaniko) to build container
  images without requiring Docker
- A custom **deploy** Task to deploy the application to Kubernetes

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
