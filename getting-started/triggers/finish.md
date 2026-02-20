# Congratulations!

You have learned how to use Tekton Triggers to automatically run Pipelines in
response to events!

## What you learned

- How to create a **TriggerBinding** that extracts data from event payloads
- How to create a **TriggerTemplate** that defines PipelineRuns to create
- How to set up an **EventListener** that connects Bindings to Templates
- How to trigger a Pipeline by sending HTTP events

## How this works in production

In a real CI/CD setup:

1. You configure a **webhook** in your Git provider (GitHub, GitLab, etc.)
   pointing to your EventListener's public URL
2. When a developer pushes code, the Git provider sends a POST request to
   your EventListener
3. The TriggerBinding extracts relevant data (repo URL, branch, commit SHA)
4. The TriggerTemplate creates a PipelineRun with those values
5. The Pipeline runs your CI/CD workflow automatically

## Additional resources

- [Tekton Triggers documentation](https://tekton.dev/docs/triggers/)
- [GitHub Webhooks documentation](https://docs.github.com/en/webhooks)
- [TriggerBinding reference](https://tekton.dev/docs/triggers/triggerbindings/)
- [TriggerTemplate reference](https://tekton.dev/docs/triggers/triggertemplates/)
