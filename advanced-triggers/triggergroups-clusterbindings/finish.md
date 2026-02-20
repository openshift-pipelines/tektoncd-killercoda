# Congratulations!

You have learned how to use **ClusterTriggerBindings** and **TriggerGroups** to
scale Tekton Triggers across teams and namespaces.

## What you learned

- **ClusterTriggerBindings** are cluster-scoped and shared across all namespaces
- How to reference ClusterTriggerBindings with `kind: ClusterTriggerBinding`
- Organizing multiple triggers by purpose in an **EventListener**
- The **multi-tenant pattern**: shared bindings + per-namespace templates/listeners

## Key points to remember

- Use `kind: ClusterTriggerBinding` in EventListener bindings to reference
  cluster-scoped bindings (default is namespace-scoped TriggerBinding)
- Each team namespace gets its own EventListener, TriggerTemplate, and Tasks
- PipelineRuns stay isolated in their respective namespaces
- ClusterTriggerBindings reduce duplication and prevent configuration drift

## Real-world use cases

- **Platform teams**: Provide standard bindings for all development teams
- **Multi-repo setups**: Same event fields across different repository webhooks
- **Compliance**: Centrally enforce required parameters (audit fields, timestamps)
- **Scaling**: Add new teams without duplicating binding configurations

## What's next

- [Custom Interceptors](https://killercoda.com/tekton/course/advanced-triggers/custom-interceptors) - Build custom event processing logic
- [Interceptor Chaining](https://killercoda.com/tekton/course/advanced-triggers/interceptor-chaining) - Multi-stage event filtering
- [TriggerGroups documentation](https://tekton.dev/docs/triggers/eventlisteners/#triggergroups) - Full reference
