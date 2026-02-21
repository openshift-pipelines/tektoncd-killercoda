# Jenkins to Tekton Migration Guide

Migrating from Jenkins to Tekton is a common journey for teams adopting
cloud-native CI/CD. While the paradigms differ (Jenkins uses a centralized
server; Tekton uses Kubernetes-native resources), the concepts map cleanly.

This is a **conceptual tutorial** -- no Jenkins installation is needed. You will
build Tekton equivalents of common Jenkins patterns by converting a real
Jenkinsfile step by step.

In this tutorial, you will learn:

- How to **map Jenkins concepts** to their Tekton equivalents
- How to **convert a Jenkinsfile** to a Tekton Pipeline
- Common **migration patterns and gotchas**

**Prerequisites:** Familiarity with Tekton Pipelines. Jenkins experience is
helpful but not required.

While the environment loads, Tekton Pipelines and the tkn CLI are being
installed. This may take a minute or two.
