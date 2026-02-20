# Congratulations!

You have learned how to use Tekton Workspaces to share data between Tasks!

## What you learned

- How to declare Workspaces in Tasks using `spec.workspaces`
- How to access Workspace paths using `$(workspaces.<name>.path)`
- How to use Parameters to make Tasks configurable
- How to wire Pipeline-level Workspaces to Task-level Workspaces
- How to use `volumeClaimTemplate` to provide persistent storage

## What's next

Workspaces are essential for real CI/CD workflows. Common uses include:

- **git-clone** writes source code to a Workspace, then build tasks read it
- **Build tasks** write container images or artifacts to a Workspace
- **Test tasks** read built artifacts from a Workspace

To learn more:

- [Tekton Workspaces documentation](https://tekton.dev/docs/pipelines/workspaces/)
- [Using Workspaces in Pipelines](https://tekton.dev/docs/pipelines/pipelines/#specifying-workspaces)
- [Tekton Triggers](https://tekton.dev/docs/triggers/) - Automate pipeline runs with events
