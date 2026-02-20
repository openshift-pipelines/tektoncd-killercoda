# Congratulations!

You have learned how to use **When Expressions** to add conditional logic to
Tekton Pipelines.

## What you learned

- **When Expression syntax:** `input`, `operator` (`in`/`notin`), `values`
- **Parameter-based conditions:** Skip Tasks based on Pipeline parameters
- **Result-based conditions:** Use upstream Task Results for dynamic branching
- **AND logic:** Multiple When Expressions on a Task are AND-ed together
- **Skipped Tasks are not failures:** Pipeline still succeeds when Tasks are
  skipped

## When Expression operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `in` | Input matches one of the values | `input: "main"` in `["main", "master"]` |
| `notin` | Input does not match any value | `input: "docs"` notin `["main"]` |

## What's next

- [Finally Tasks](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/finally-tasks) - Add guaranteed cleanup and notification Tasks
- [When Expressions documentation](https://tekton.dev/docs/pipelines/pipelines/#guard-task-execution-using-when-expressions) - Full reference
