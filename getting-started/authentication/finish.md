# Congratulations!

You have learned how to set up authentication in Tekton for private Git
repositories and container registries!

## What you learned

- How to create `basic-auth` Secrets for Git with `tekton.dev/git-*` annotations
- How to create `basic-auth` or `dockerconfigjson` Secrets for container registries
  with `tekton.dev/docker-*` annotations
- How to bundle Secrets into ServiceAccounts
- How to reference ServiceAccounts in PipelineRuns
- How to test end-to-end by cloning a private Gitea repository

## The authentication pattern

```
Secret (credentials)        ServiceAccount         PipelineRun
┌────────────────────┐     ┌──────────────┐     ┌────────────────┐
│ basic-auth         │     │              │     │                │
│ + tekton.dev/git-0 │────▶│              │     │ serviceAccount │
│                    │     │   build-bot  │◀────│  Name:         │
│ basic-auth         │     │              │     │  build-bot     │
│ + tekton.dev/      │────▶│              │     │                │
│     docker-0       │     └──────────────┘     └────────────────┘
└────────────────────┘
        │                          │
        ▼                          ▼
  Tekton creates:           Used by TaskRun
  ~/.gitconfig               to get all
  ~/.git-credentials         attached Secrets
  ~/.docker/config.json
```

## Additional resources

- [Tekton Authentication documentation](https://tekton.dev/docs/pipelines/auth/)
- [Configuring basic-auth for Git](https://tekton.dev/docs/pipelines/auth/#configuring-basic-auth-authentication-for-git)
- [Configuring ssh-auth for Git](https://tekton.dev/docs/pipelines/auth/#configuring-ssh-auth-authentication-for-git)
- [Configuring authentication for Docker](https://tekton.dev/docs/pipelines/auth/#configuring-authentication-for-docker)
