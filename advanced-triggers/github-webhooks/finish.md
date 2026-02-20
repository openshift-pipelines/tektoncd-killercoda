# Congratulations!

You have learned how to integrate GitHub webhooks with Tekton Triggers using
HMAC signature validation and interceptor chaining!

## What you learned

- How to configure the **GitHub interceptor** with a shared secret for HMAC
  validation
- How to create a **TriggerBinding** that extracts GitHub-specific fields
  (`body.repository.full_name`, `body.head_commit.id`, `body.ref`)
- How to compute an **HMAC-SHA256 signature** and simulate a GitHub webhook
  delivery
- How the GitHub interceptor **rejects** requests with invalid signatures
- How to chain a **CEL interceptor** after the GitHub interceptor for branch
  filtering
- How an **interceptor chain** separates security concerns (signature) from
  business logic (branch filter)

## Interceptor chain pattern

| Interceptor | Role | Rejects when |
|-------------|------|--------------|
| GitHub | Security | Invalid HMAC signature or wrong event type |
| CEL | Business logic | `body.ref` does not match target branch |

## Connecting to a real GitHub repository

To use this with a real GitHub repository:

1. Expose your EventListener with an Ingress or LoadBalancer Service
2. In your GitHub repository, go to **Settings > Webhooks > Add webhook**
3. Set the **Payload URL** to your EventListener's external URL
4. Set the **Content type** to `application/json`
5. Set the **Secret** to the same token stored in your Kubernetes Secret
6. Select the events you want to receive (e.g., **Just the push event**)

## What is next

- [CEL Interceptor: Event Filtering and Transformation](../cel-interceptor/) -
  Deep dive into CEL expressions for filtering and payload transformation
- [Tekton Triggers documentation](https://tekton.dev/docs/triggers/) - Full
  reference for all interceptor types
- [GitHub Webhook documentation](https://docs.github.com/en/webhooks) -
  GitHub's guide to configuring and securing webhooks
- [Interceptor Chaining](https://tekton.dev/docs/triggers/interceptors/) -
  Chain multiple interceptors for complex event processing
