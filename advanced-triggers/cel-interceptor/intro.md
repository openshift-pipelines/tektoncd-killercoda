# CEL Interceptor - Event Filtering and Transformation

In the [Getting Started with Triggers](../../getting-started/triggers/) tutorial,
you learned how EventListeners receive events and create PipelineRuns. But in
production, you need more control: you want to **filter out** irrelevant events
and **transform** payloads before they reach your Pipelines.

The **CEL Interceptor** is the most powerful way to do this. CEL (Common
Expression Language) is a lightweight expression language designed for exactly
this kind of data filtering and transformation.

## What CEL Interceptors can do

- **Filter events** - only trigger on push events, not pull requests
- **Extract fields** - pull the branch name from `refs/heads/main`
- **Transform data** - compute new values like a short commit SHA
- **Guard conditions** - only trigger for specific branches, users, or actions

## What you will learn

In this tutorial, you will:

- Create an EventListener with a **CEL filter** that only accepts push events
- Test that the filter **rejects non-matching events**
- Add **CEL overlays** to transform and enrich the event payload
- Build a **production-ready pattern** combining filters and overlays

## Prerequisites

This tutorial builds on the concepts from
[Getting Started with Triggers](../../getting-started/triggers/). You should
understand TriggerTemplates, TriggerBindings, and EventListeners.

While the environment loads, Tekton Pipelines, Tekton Triggers (with
interceptors), and the `tkn` CLI are being installed in the background. This may
take a minute or two.
