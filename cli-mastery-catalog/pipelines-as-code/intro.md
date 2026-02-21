# Pipelines as Code with tkn-pac

**Pipelines as Code** (PAC) is a Tekton component that lets you define your
CI/CD Pipelines alongside your source code in a `.tekton/` directory. When code
is pushed to a Git repository, PAC automatically detects the Pipeline definitions
and creates PipelineRuns.

This is the "pipeline-as-code" pattern: your CI/CD configuration lives in the
same repository as your application code, versioned together, reviewed together.

In this tutorial, you will learn:

- How to **install and configure** Pipelines as Code
- How to **create PipelineRun definitions** in a `.tekton/` directory
- How to **test locally** with `tkn pac resolve` without webhooks

**Prerequisites:** Familiarity with Tekton Pipelines and PipelineRuns.

**Note:** Full PAC webhook integration requires a Git provider (GitHub, GitLab).
This tutorial uses `tkn pac resolve` for local testing.

While the environment loads, Tekton Pipelines and the tkn CLI are being
installed. This may take a minute or two.
