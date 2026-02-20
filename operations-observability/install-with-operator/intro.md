# Install Tekton with the Operator

The [Tekton Operator](https://tekton.dev/docs/operator/) provides a declarative
way to install, manage, and configure all Tekton components on your Kubernetes
cluster. Instead of applying individual release YAML files for Pipelines,
Triggers, Dashboard, and Chains, the Operator manages everything through a
single custom resource called **TektonConfig**.

The Operator approach has several advantages:

- **One resource controls everything** - TektonConfig is the single source of
  truth for your Tekton installation
- **Version management** - The Operator handles component lifecycle and upgrades
- **Profiles** - Choose which components to install (all, lite, basic)
- **Configuration** - Feature flags and settings are managed declaratively

In this tutorial, you will learn:

- How to explore the **TektonConfig** resource created by the Operator
- How to switch between **profiles** to control which components are installed
- How to **configure Tekton features** through TektonConfig

While the environment loads, the Tekton Operator and `tkn` CLI are being
installed in the background. This may take a few minutes.
