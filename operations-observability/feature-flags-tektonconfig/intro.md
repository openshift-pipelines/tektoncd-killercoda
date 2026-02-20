# Configure Feature Flags via TektonConfig

Tekton Pipelines has many configurable behaviors controlled by **feature flags**.
These flags enable/disable beta features, control results formats, set default
behaviors, and fine-tune the Pipeline controller's operation.

When using the **Tekton Operator**, all feature flags are managed through the
**TektonConfig** custom resource. The Operator reconciles TektonConfig changes
into the underlying ConfigMaps, providing a single point of configuration.

Without the Operator, you configure these directly in the `feature-flags`
ConfigMap in the `tekton-pipelines` namespace.

In this tutorial, you will learn:

- What **feature flags** are available and what they control
- How to **enable beta features** like Matrix and Pipelines-in-Pipelines
- How to configure **operational settings** like result formats and resource limits

**Prerequisites:** Familiarity with Tekton Pipelines basics.

While the environment loads, the Tekton Operator is being installed. This may
take a minute or two.
