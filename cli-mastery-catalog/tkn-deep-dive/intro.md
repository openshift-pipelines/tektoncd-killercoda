# tkn CLI Deep Dive -- Mastering Tekton from the Command Line

The `tkn` CLI is the official command-line tool for interacting with Tekton
resources. While `kubectl` can manage any Kubernetes resource, `tkn` provides
Tekton-specific commands that make it faster and easier to create, run, inspect,
and debug your CI/CD pipelines.

In this tutorial, you will learn:

- How to **list and describe** Tasks, Pipelines, and their runs with `tkn`
- How to **follow logs** and manage runs (list, delete, keep)
- How to **format output** as JSON, YAML, and pipe it to `jq` for processing
- How to **start runs** with parameters, dry-run mode, and re-run with `--last`

**Prerequisites:** You should be familiar with creating Tasks and Pipelines
(covered in the Basic Pipeline tutorial).

While the environment loads, Tekton Pipelines, the `tkn` CLI, and `jq` are being
installed in the background. This may take a minute or two.
