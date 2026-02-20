# GitHub Webhook Integration

In production CI/CD systems, Pipelines are triggered by **real GitHub webhooks**
rather than manually. When you configure a webhook on a GitHub repository, GitHub
sends an HTTP POST with a JSON payload to your EventListener every time an event
occurs (push, pull request, tag, etc.).

To ensure that only **legitimate** requests trigger your Pipelines, GitHub signs
every webhook payload with an **HMAC-SHA256** signature using a shared secret. The
**GitHub interceptor** in Tekton Triggers validates this signature before the
event reaches your Pipeline.

## What you will learn

In this tutorial, you will:

- Set up RBAC and create an EventListener with the **GitHub interceptor**
- Create a **TriggerBinding** that extracts GitHub-specific fields (repository,
  commit SHA, branch ref)
- Generate an **HMAC signature** and simulate a GitHub webhook delivery
- Observe the GitHub interceptor **validating** the signature
- Add a **CEL interceptor** after the GitHub interceptor to filter by branch
- Test an **interceptor chain**: GitHub (signature validation) then CEL (branch filter)

## Prerequisites

This tutorial builds on the concepts from
[Getting Started with Triggers](../../getting-started/triggers/) and
[CEL Interceptor](../cel-interceptor/). You should understand TriggerTemplates,
TriggerBindings, and EventListeners.

While the environment loads, Tekton Pipelines, Tekton Triggers (with
interceptors), and the `tkn` CLI are being installed in the background. This may
take a minute or two.
