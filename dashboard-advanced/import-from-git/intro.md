# Import Tekton Resources from Git

The Tekton Dashboard has a built-in **Import** feature that lets you pull Tekton
YAML directly from a Git repository and apply it to your cluster. Instead of
manually downloading YAML files and running `kubectl apply`, you point the
Dashboard at a Git URL and it handles the rest.

This is useful for:

- Importing shared Tasks from team repositories
- Deploying Pipeline definitions from a GitOps repository
- Bootstrapping a new namespace with standard Tekton resources

In this tutorial, you will learn:

- How to access the Dashboard **Import** feature
- How to **import Tasks** from a public Git repository
- How to **import Pipelines** and manage imported resources

**Prerequisites:** Familiarity with the Tekton Dashboard basics.

While the environment loads, Tekton Pipelines and Dashboard are being installed.
This may take a minute or two.
