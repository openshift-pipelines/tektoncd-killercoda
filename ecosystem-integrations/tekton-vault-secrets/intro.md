# Tekton + Vault: Pipeline Secrets Management

CI/CD pipelines need secrets: database credentials, API keys, registry
passwords, cloud provider tokens. The typical approach is to store these in
Kubernetes Secrets and mount them into pods. This works, but has significant
limitations:

- Kubernetes Secrets are **base64-encoded, not encrypted** - anyone with
  RBAC access can read them
- Secrets are **static** - there is no automatic rotation
- **No audit trail** - you cannot track who accessed which secret and when
- Secrets are **scattered** across namespaces with no central management

**HashiCorp Vault** provides a purpose-built secrets management solution.
When integrated with Tekton, Vault offers:

- **Centralized secrets** - one place to manage all pipeline credentials
- **Dynamic secrets** - generate fresh, short-lived credentials per pipeline
  run
- **Audit logging** - every secret access is logged
- **Kubernetes authentication** - pods authenticate to Vault using their
  ServiceAccount identity
- **Vault Agent Injector** - automatically inject secrets into pods via
  annotations, with no changes to your Task definitions

In this tutorial, you will learn:

- How to configure Vault's dev server and store pipeline secrets
- How to use the Vault Agent Injector to inject secrets into Tekton TaskRun
  pods
- How to implement production patterns like dynamic secrets and least-privilege
  access

While the environment loads, Tekton Pipelines v1.9.0, HashiCorp Vault (dev
mode), and the `tkn` CLI are being installed in the background. This may take
a few minutes.
