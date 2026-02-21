# Tekton Multi-Tenant Setup

In a shared Kubernetes cluster, multiple teams need to use Tekton Pipelines
without interfering with each other. A **multi-tenant setup** provides:

- **Namespace isolation**: Each team has their own namespace for PipelineRuns
- **RBAC**: Teams can only see and manage their own resources
- **Shared components**: Common Tasks available to all teams
- **Resource quotas**: Fair resource allocation per team

In this tutorial, you will learn:

- How to create **isolated namespaces** for multiple teams
- How to configure **RBAC** so teams cannot see each other's PipelineRuns
- How to share **common Tasks** across teams using cluster-scoped objects

**Prerequisites:** Familiarity with Tekton Pipelines and Kubernetes RBAC basics.

While the environment loads, Tekton Pipelines and the tkn CLI are being
installed. This may take a minute or two.
