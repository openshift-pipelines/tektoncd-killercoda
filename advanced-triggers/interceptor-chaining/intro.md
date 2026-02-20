# Interceptor Chaining: Filter, Transform, and Route Events

In production, webhook events need to go through multiple processing stages
before triggering a Pipeline. You might need to validate the webhook signature,
filter for specific event types, extract and transform fields, and add
computed values. Tekton Triggers supports **interceptor chaining** to handle
all of these stages in order.

## What is interceptor chaining?

When you list multiple interceptors in a trigger, they execute **in order**,
like a pipeline. Each interceptor receives the output of the previous one:

```
Webhook event
    |
    v
Interceptor 1: Validate (e.g., HMAC signature check)
    |
    v
Interceptor 2: Filter (e.g., only push events to main)
    |
    v
Interceptor 3: Transform (e.g., extract branch name, add overlays)
    |
    v
TriggerBinding + TriggerTemplate --> PipelineRun
```

If any interceptor rejects the event (filter returns false, validation fails),
the chain stops and no PipelineRun is created.

## What you will learn

In this tutorial, you will:

- Chain two **CEL interceptors** (filter then overlay) and see how ordering
  matters
- Chain a **GitHub interceptor** with **CEL interceptors** for HMAC validation
  plus event filtering
- Build a production-grade **3-interceptor chain** that validates, filters,
  and transforms events

While the environment loads, Tekton Pipelines, Tekton Triggers, and the `tkn`
CLI are being installed. This may take a minute or two.
