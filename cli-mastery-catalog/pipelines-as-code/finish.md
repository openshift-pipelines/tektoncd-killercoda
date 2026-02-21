# Congratulations!

You have learned how to use **Pipelines as Code** to define CI/CD alongside
your source code.

## What you learned

- PAC stores Pipeline definitions in the **.tekton/ directory**
- Annotations control **when Pipelines trigger** (push, pull_request)
- **tkn pac resolve** tests Pipeline definitions locally
- The production workflow with **Git provider webhooks**

## Key points to remember

- `.tekton/` directory is the convention for PAC Pipeline definitions
- Annotations like `on-event` and `on-target-branch` control triggering
- PAC supports GitHub, GitLab, Bitbucket, and generic Git providers
- Use `tkn pac resolve` for local testing without webhooks

## What's next

- [Remote Resolvers](https://killercoda.com/tekton/course/cli-mastery-catalog/remote-resolvers) - Fetch Tasks from remote sources
- [tkn CLI Deep Dive](https://killercoda.com/tekton/course/cli-mastery-catalog/tkn-deep-dive) - Advanced CLI commands
- [PAC documentation](https://pipelinesascode.com/) - Full reference
