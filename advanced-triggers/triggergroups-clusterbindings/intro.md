# TriggerGroups and ClusterTriggerBindings

As your Tekton deployment grows, you will have multiple teams with their own
namespaces, each needing similar trigger configurations. Duplicating
TriggerBindings across namespaces leads to configuration drift.

Tekton Triggers provides two features for scaling:

- **ClusterTriggerBindings**: Cluster-scoped bindings shared across all namespaces
- **TriggerGroups**: Organize multiple triggers in an EventListener by team,
  purpose, or event source

Together, these features let you create a centralized trigger configuration that
multiple teams share while maintaining namespace isolation for PipelineRuns.

In this tutorial, you will learn:

- How to create **ClusterTriggerBindings** for common event fields
- How to use **TriggerGroups** to organize triggers in an EventListener
- How to **share triggers** across multiple namespaces for multi-team setups

**Prerequisites:** Familiarity with TriggerBindings, TriggerTemplates, and
EventListeners (covered in the CEL Interceptor tutorial).

While the environment loads, Tekton Pipelines and Triggers are being installed.
This may take a minute or two.
