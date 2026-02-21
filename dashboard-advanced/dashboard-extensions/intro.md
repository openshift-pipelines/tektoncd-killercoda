# Dashboard Extensions: Custom Resource Views

The Tekton Dashboard displays Tekton resources (PipelineRuns, TaskRuns, Pipelines,
Tasks) by default. But your cluster likely has other resources that are part of
your CI/CD workflow -- ConfigMaps, custom CRDs, or third-party resources.

**Dashboard Extensions** let you add custom resource types to the Dashboard UI.
When configured, the Dashboard will list, display details, and let you manage
these custom resources alongside your Tekton resources.

In this tutorial, you will learn:

- How Dashboard **extensions** work (alpha feature)
- How to **register a custom resource type** in the Dashboard
- How to **view and manage** custom resources through the Dashboard UI

**Prerequisites:** Familiarity with the Tekton Dashboard basics.

While the environment loads, Tekton Pipelines and Dashboard are being installed.
This may take a minute or two.
