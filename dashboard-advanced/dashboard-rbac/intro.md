# Dashboard RBAC: Access Control

The Tekton Dashboard provides a web-based UI for viewing and managing Tekton
resources. By default, whoever can access the Dashboard service can see and
modify everything. In a multi-team or production environment, this is a
security concern.

The Dashboard supports two deployment modes:

- **Read-write mode** (`release-full.yaml`) - users can create, modify, and
  delete Tekton resources from the UI
- **Read-only mode** (`release.yaml`) - users can only view resources, all
  create/edit/delete operations are disabled

Beyond the deployment mode, you can use standard Kubernetes **RBAC**
(Role-Based Access Control) to control who can access the Dashboard and what
they can do. This gives you fine-grained control:

- **Admin users** - full read-write access to all Tekton resources
- **Viewer users** - read-only access, suitable for developers who need to
  monitor pipeline status without making changes
- **Namespace isolation** - restrict users to only see pipelines in their team
  namespaces

In this tutorial, you will learn:

- The difference between read-only and read-write Dashboard deployment modes
- How to create ServiceAccounts, ClusterRoles, and ClusterRoleBindings for
  Dashboard access control
- How to test that admin and viewer roles behave differently

While the environment loads, Tekton Pipelines v1.9.0, the Tekton Dashboard
(read-write mode), and the `tkn` CLI are being installed in the background.
This may take a few minutes.
