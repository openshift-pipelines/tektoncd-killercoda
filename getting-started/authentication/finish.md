# Congratulations!

You have learned how to set up authentication in Tekton for private Git
repositories and container registries!

## What you learned

- How to create `basic-auth` Secrets for Git authentication
- How to create `docker-registry` Secrets for container registries
- How to annotate Secrets with `tekton.dev/git-*` for host matching
- How to create ServiceAccounts that bundle multiple Secrets
- How to reference ServiceAccounts in PipelineRuns

## The authentication pattern

Tekton's authentication uses three Kubernetes-native building blocks:

1. **Secrets** — hold credentials (Git PAT, registry password)
2. **Annotations** — tell Tekton which host each Secret applies to
3. **ServiceAccounts** — bundle Secrets for use in TaskRuns/PipelineRuns

## Additional resources

- [Tekton Authentication documentation](https://tekton.dev/docs/pipelines/auth/)
- [Using Secrets with ServiceAccounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [Git authentication in Tekton](https://tekton.dev/docs/pipelines/auth/#configuring-basic-auth-authentication-for-git)
- [Docker authentication in Tekton](https://tekton.dev/docs/pipelines/auth/#configuring-docker-authentication-for-docker)
