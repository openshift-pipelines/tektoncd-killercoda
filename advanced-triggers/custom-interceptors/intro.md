# Custom Interceptors

Tekton Triggers comes with built-in interceptors (CEL, GitHub, GitLab, Bitbucket),
but sometimes you need custom event processing logic that goes beyond what the
built-in interceptors provide.

**Custom interceptors** are HTTP services that receive an event, process it, and
return a (possibly modified) event. They follow a simple protocol:

1. Triggers sends a POST request with an `InterceptorRequest` JSON body
2. Your interceptor processes the event (validate, transform, enrich)
3. Your interceptor returns an `InterceptorResponse` JSON body

This lets you implement any logic: validate custom headers, call external APIs,
compute derived fields, or enforce custom policies.

In this tutorial, you will learn:

- The **interceptor HTTP protocol** (request/response format)
- How to **build a custom interceptor** as a Python Flask service
- How to **register** it as a ClusterInterceptor CRD
- How to **use** it in an EventListener and test it end-to-end

**Prerequisites:** Familiarity with Tekton Triggers, EventListeners, and
TriggerBindings (covered in the CEL Interceptor tutorial).

While the environment loads, Tekton Pipelines and Triggers are being installed.
This may take a minute or two.
