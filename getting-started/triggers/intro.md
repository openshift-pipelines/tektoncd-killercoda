# Introduction to Tekton Triggers

So far you've learned how to create Tasks, Pipelines, and run them manually.
In a real CI/CD system, you want Pipelines to run automatically in response
to events - like a `git push` to a repository.

[Tekton Triggers](https://tekton.dev/docs/triggers/) makes this possible by
listening for events and creating PipelineRuns automatically.

The key components are:

- **TriggerTemplate** - defines what resources to create (e.g., a PipelineRun)
- **TriggerBinding** - extracts values from the incoming event payload
- **EventListener** - receives events and connects Bindings to Templates

In this tutorial, you will learn:

- How to create a TriggerTemplate that generates PipelineRuns
- How to create a TriggerBinding that extracts data from events
- How to set up an EventListener
- How to trigger a Pipeline by sending an event

While the environment loads, Tekton Pipelines, Tekton Triggers, and the `tkn`
CLI are being installed in the background. This may take a minute or two.
