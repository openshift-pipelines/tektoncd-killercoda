# Congratulations!

You have successfully integrated HashiCorp Vault with Tekton Pipelines for
secure secrets management.

In this tutorial, you learned:

- **Vault setup** -- how to configure Vault's dev server, store secrets, and
  enable Kubernetes authentication
- **Vault Agent Injector** -- how annotations on TaskRun pods trigger
  automatic secret injection via sidecar containers
- **Pipeline integration** -- using Vault secrets across multiple Tasks in a
  Pipeline without Kubernetes Secrets
- **Production patterns** -- secret rotation, least-privilege access with
  scoped policies, and audit trails

## Why Vault over Kubernetes Secrets

| Feature | Kubernetes Secrets | Vault |
|---------|-------------------|-------|
| Encryption | Base64 only (at rest optional) | Encrypted at rest and in transit |
| Rotation | Manual, requires redeployment | Automatic, transparent to pipelines |
| Access control | RBAC (coarse) | Fine-grained policies per path |
| Audit | Limited | Full audit logging |
| Dynamic secrets | Not supported | Generate on-demand credentials |
| Central management | Per-cluster | Cross-cluster, cross-environment |

## Next steps

- [Vault documentation](https://developer.hashicorp.com/vault/docs) -- full
  Vault reference
- [Vault Agent Injector](https://developer.hashicorp.com/vault/docs/platform/k8s/injector) --
  complete injector annotation reference
- [Vault dynamic secrets](https://developer.hashicorp.com/vault/docs/secrets/databases) --
  generate database credentials on demand
- [Tekton Pipelines documentation](https://tekton.dev/docs/) -- full Tekton
  reference
