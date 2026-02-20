# Congratulations!

You have successfully configured role-based access control for the Tekton
Dashboard.

In this tutorial, you learned:

- **Dashboard deployment modes** - read-only (`release.yaml`) vs read-write
  (`release-full.yaml`) for coarse-grained control
- **Kubernetes RBAC** - how to create ClusterRoles with different permission
  levels for Tekton resources
- **ServiceAccount-based access** - binding admin and viewer roles to
  ServiceAccounts for fine-grained control
- **Namespace isolation** - using RoleBindings (not ClusterRoleBindings) to
  restrict access to specific namespaces

## Production considerations

- Use **ClusterRoleBindings** instead of RoleBindings if a user needs access
  across all namespaces
- Integrate with your identity provider (OIDC, LDAP) using a Kubernetes
  authentication proxy in front of the Dashboard
- Combine read-only Dashboard mode with viewer RBAC for maximum security
- Consider using [Kubernetes NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
  to restrict which pods can reach the Dashboard service

## Next steps

- [Tekton Dashboard documentation](https://tekton.dev/docs/dashboard/) --
  full reference for Dashboard configuration
- [Kubernetes RBAC documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) --
  complete RBAC reference
- [Dashboard with Results](https://tekton.dev/docs/dashboard/) - integrate
  the Dashboard with Tekton Results for historical log viewing
