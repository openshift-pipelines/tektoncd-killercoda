# Congratulations!

You have learned how to use **StepActions** in Tekton to create reusable step
definitions and share them across Tasks.

## What you learned

- **Creating StepActions** with `apiVersion: tekton.dev/v1beta1` and `kind: StepAction`
- **Referencing StepActions** from a Task step using `ref: {name: ...}`
- **Parameterizing StepActions** so one definition serves multiple use cases
- **Composing Pipelines** with Tasks that internally use shared StepActions
- **Two levels of reuse** - Task-level reuse via `taskRef` and Step-level reuse via `ref`

## Key points to remember

- StepActions use `apiVersion: tekton.dev/v1beta1` - this is the correct API
  version (not `v1`), and the feature is GA since Tekton Pipelines v1.0.0
- Inside a Task step, `ref: {name: <stepaction-name>}` references a StepAction
  - the step inherits its `image`, `script`, and other configuration from the
  StepAction
- One StepAction can be used across many different Tasks - define once, use
  everywhere
- StepActions are the step-level equivalent of Tasks in a Pipeline: Tasks give
  you coarse-grained reuse, StepActions give you fine-grained reuse

## What's next

- [Retries, Timeouts, and Error Handling](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/retries-timeouts) - Handle failures with retries, timeouts, and error strategies
- [StepAction documentation](https://tekton.dev/docs/pipelines/stepactions/) - Full reference for StepActions
