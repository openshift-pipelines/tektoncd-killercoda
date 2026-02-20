# Congratulations!

You have learned how to configure **Tekton feature flags** and operational
settings to customize Pipeline behavior for your environment.

## What you learned

- The available **feature flags** and what each one controls
- How to **enable beta features** like Matrix and Pipelines-in-Pipelines
- Configuring **operational settings**: result formats, timeouts, security context
- How the Operator reconciles **TektonConfig** into ConfigMaps

## Key points to remember

- Feature flags live in the `feature-flags` ConfigMap in `tekton-pipelines`
- With the Operator, manage everything through the `TektonConfig` CR
- `enable-api-fields: beta` unlocks Matrix, PiP, and other beta features
- `results-from: sidecar-logs` removes the 4KB result size limit
- Always restart the Pipeline controller after ConfigMap changes

## Real-world use cases

- **Progressive rollout**: Enable beta features in dev, stable in production
- **Large results**: Switch to sidecar-logs for Tasks that produce large outputs
- **Security hardening**: Enable `set-security-context` and `require-git-ssh-secret-known-hosts`
- **Observability**: Enable `send-cloudevents-for-runs` for event-driven monitoring

## What's next

- [Install with Operator](https://killercoda.com/tekton/course/operations-observability/install-with-operator) - Full Operator management
- [Automatic Pruning](https://killercoda.com/tekton/course/operations-observability/automatic-pruning) - Clean up old runs
- [Feature flags documentation](https://tekton.dev/docs/pipelines/additional-configs/) - Full reference
