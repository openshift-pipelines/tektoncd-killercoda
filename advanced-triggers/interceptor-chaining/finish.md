# Congratulations!

You have learned how to chain multiple interceptors in Tekton Triggers for
production-grade event processing.

## What you learned

- How interceptors execute **in order** as a chain, each receiving the output
  of the previous one
- How to chain **two CEL interceptors** (filter then overlay) to filter events
  and add computed fields
- How to chain a **GitHub interceptor with CEL interceptors** for HMAC
  validation, branch filtering, and field extraction
- How to build a **3-interceptor production pattern** that progressively
  modifies the event body (filter -> transform -> enrich)
- How **overlays from one interceptor are visible to the next** interceptor and
  to the TriggerBinding

## Interceptor chaining patterns

| Pattern | Interceptors | Use case |
|---------|-------------|----------|
| Filter + Transform | CEL -> CEL | Basic event processing |
| Validate + Filter | GitHub -> CEL | Secure webhooks |
| Validate + Filter + Transform | GitHub -> CEL -> CEL | Production GitHub pipelines |
| Filter + Transform + Enrich | CEL -> CEL -> CEL | Complex event routing |

## Key principle

Each interceptor in the chain can:

- **Filter** events (returning false stops the chain)
- **Modify** the event body (overlays add/transform fields)
- **Pass data forward** to the next interceptor and ultimately to the
  TriggerBinding

## What is next

- [CEL Interceptor Deep Dive](/advanced-triggers/cel-interceptor) - Master CEL
  expressions for filtering and transformation
- [Tekton Triggers documentation](https://tekton.dev/docs/triggers/) - Full
  reference for interceptors, bindings, and templates
- [CEL Language Spec](https://github.com/google/cel-spec) - Learn all
  available CEL functions and operators
- [GitHub Webhook Events](https://docs.github.com/en/webhooks/webhook-events-and-payloads) -
  Understand the structure of GitHub webhook payloads
