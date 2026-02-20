# Congratulations!

You have learned how to use **Task Results** in Tekton to pass data between
Tasks in a Pipeline.

## What you learned

- **Declaring Results** in a Task's `spec.results` section
- **Emitting Results** by writing to `$(results.<name>.path)` with `echo -n`
- **Passing Results** between Tasks using `$(tasks.<task-name>.results.<result-name>)`
- **Chaining Results** through multiple Tasks in a Pipeline
- **Inspecting Results** with `tkn pipelinerun describe` and `kubectl`

## Key points to remember

- Results are limited to **4096 bytes** -- use Workspaces for larger data
- Always use `echo -n` to avoid trailing newlines
- Result references create implicit ordering (the consuming Task waits for the
  producing Task)

## What's next

- [When Expressions](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/when-expressions) -- Use Results to conditionally skip or run Tasks
- [Tekton Results documentation](https://tekton.dev/docs/pipelines/tasks/#emitting-results) -- Full reference for Task Results
