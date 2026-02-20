# Debugging with Breakpoints

When a Tekton Task fails, the pod is normally terminated immediately, taking with
it all the runtime state you need to diagnose the problem. The **breakpoint
debug API** (alpha feature) changes this: when a step fails, the pod **pauses**
instead of terminating, giving you time to exec into the container and
investigate.

This is the Tekton equivalent of setting a breakpoint in a debugger: the
execution pauses at the failure point, and you can inspect the environment,
check files, test commands, and even fix the issue before continuing.

In this tutorial, you will learn:

- How to enable the **alpha breakpoint API** via feature flags
- How to set **`onFailure` breakpoints** on a TaskRun
- How to **exec into the paused container** and inspect the environment
- How to **continue or abort** execution after debugging

**Prerequisites:** Familiarity with Tasks, TaskRuns, and `kubectl exec`.

**Note:** This is an **alpha feature** requiring `enable-api-fields: alpha` in
the Tekton Pipelines feature-flags ConfigMap.

While the environment loads, Tekton Pipelines is being installed with alpha API
fields enabled. This may take a minute or two.
