# Authentication in Tekton

In production CI/CD pipelines, you often need to:

- **Pull source code** from private Git repositories
- **Push container images** to authenticated container registries

Tekton uses standard Kubernetes **Secrets** and **ServiceAccounts** to handle
authentication. This approach integrates with Kubernetes' existing security
model rather than introducing a separate credential system.

In this tutorial, you will learn:

- How to create Kubernetes Secrets for Git and registry credentials
- How to annotate Secrets so Tekton knows which host they belong to
- How to create ServiceAccounts that bundle multiple Secrets
- How to use authenticated ServiceAccounts in TaskRuns and PipelineRuns

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
