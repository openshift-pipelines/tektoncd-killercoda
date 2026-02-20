# Tekton Bundles -- Package and Share Tasks as OCI Artifacts

In a typical Tekton setup, Tasks and Pipelines are applied directly to your
cluster with `kubectl apply`. This works for small teams, but as your
organization grows, you need a way to **version, share, and distribute**
Tekton resources across clusters and teams.

**Tekton Bundles** solve this by packaging Tasks and Pipelines as **OCI
artifacts** -- the same format used by container images. You can push
bundles to any OCI-compliant registry (Docker Hub, GitHub Container
Registry, Quay.io, or a private registry) and reference them directly in
PipelineRuns using the **Bundle resolver**.

In this tutorial, you will learn:

- How to create a Tekton Bundle from Task YAML files using `tkn bundle push`
- How to reference a Bundle in a PipelineRun using the Bundle resolver
- How to version bundles and package multiple resources into a single bundle

While the environment loads, Tekton Pipelines v1.9.0, the `tkn` CLI, and a
local OCI registry are being installed in the background. This may take a
minute or two.
