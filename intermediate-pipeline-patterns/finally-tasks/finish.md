# Congratulations!

You have learned how to use **Finally Tasks** for guaranteed cleanup and
notifications in Tekton Pipelines.

## What you learned

- **Finally Tasks** always run after all regular Tasks complete
- They run even when regular Tasks **fail**
- Multiple Finally Tasks run **in parallel** with each other
- **`$(tasks.status)`** provides the aggregate status of regular Tasks
- **`$(context.pipelineRun.name)`** provides the PipelineRun name
- Finally Tasks **cannot** use `runAfter` (they have no ordering among
  themselves)

## `$(tasks.status)` values

| Value | Meaning |
|-------|---------|
| `Succeeded` | All regular Tasks succeeded |
| `Failed` | One or more regular Tasks failed |
| `Completed` | Mix of succeeded and failed Tasks |
| `None` | No regular Tasks ran (all skipped or no tasks defined) |

## Key rules for Finally Tasks

1. Finally Tasks **cannot depend on each other** -- no `runAfter` between them
2. Finally Tasks **can reference Results** from regular Tasks (but only from
   Tasks that actually ran and succeeded)
3. Finally Tasks **can have their own When Expressions** to conditionally execute
4. Finally Tasks run after **all** regular Tasks finish, not after each one

## What's next

- [Matrix](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/matrix) -- Fan-out Tasks with parameterized matrix combinations
- [Finally Tasks documentation](https://tekton.dev/docs/pipelines/pipelines/#adding-finally-to-the-pipeline) -- Full reference
