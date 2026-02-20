# Congratulations!

You have built a **custom interceptor** for Tekton Triggers that validates
events and enriches them with computed fields.

## What you learned

- The **interceptor HTTP protocol**: InterceptorRequest and InterceptorResponse
- Building a custom interceptor as a **Python Flask HTTP service**
- Deploying the interceptor and registering it as a **ClusterInterceptor** CRD
- Using the custom interceptor in an **EventListener** for event validation
- Testing with valid and invalid events to verify the filtering logic

## Key points to remember

- Interceptors are simple HTTP services: POST in, JSON out
- Return `continue: true` to pass the event, `continue: false` to reject
- Add computed fields via `extensions` -- accessible in TriggerBindings as `$(extensions.field)`
- Register with ClusterInterceptor CRD pointing to your service URL
- Custom interceptors can be chained with built-in interceptors (CEL, GitHub)

## Real-world use cases

- **Custom validation**: Check API keys, team tokens, or project permissions
- **Event enrichment**: Look up JIRA tickets, user info, or deployment targets
- **Policy enforcement**: Block deployments outside maintenance windows
- **Rate limiting**: Throttle events per team or repository
- **Data transformation**: Normalize events from different source systems

## What's next

- [Interceptor Chaining](https://killercoda.com/tekton/course/advanced-triggers/interceptor-chaining) - Chain multiple interceptors
- [TriggerGroups](https://killercoda.com/tekton/course/advanced-triggers/triggergroups-clusterbindings) - Scale triggers across namespaces
- [Interceptor documentation](https://tekton.dev/docs/triggers/interceptors/) - Full reference
