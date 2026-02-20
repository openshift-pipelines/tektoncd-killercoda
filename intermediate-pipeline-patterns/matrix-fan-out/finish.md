# Congratulations!

You have learned how to use Tekton's **Matrix** feature to fan out Tasks across
multiple parameter combinations for efficient multi-platform testing.

## What you learned

- **Declaring a Matrix** with `matrix.params` to create a Cartesian product of
  parameter values
- **Fan-out behavior** - Tekton automatically creates one TaskRun per combination
- **Inspecting fan-out TaskRuns** using labels, `kubectl`, and `tkn` commands
- **Using matrix.include** to add specific extra combinations or override values
  in existing combinations

## Key points to remember

- Matrix computes a **Cartesian product** of all parameter lists
- Each combination becomes a separate **parallel TaskRun**
- Use **matrix.include** to add rows or modify existing combinations
- Fan-out TaskRuns are labeled with `tekton.dev/pipelineTask` for easy querying
- Matrix is a **beta feature** in Tekton Pipelines v1.9.0 and later
- Be mindful of cluster resources - large matrices produce many parallel TaskRuns

## Real-world use cases

- **Multi-platform builds**: Test across linux/mac/windows with different architectures
- **Multi-version testing**: Validate against multiple language or library versions
- **Matrix CI**: Run linting, unit tests, and integration tests across environments
- **Compliance scans**: Run security checks against multiple container images

## What's next

- [When Expressions](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/when-expressions) - Conditionally skip or run Tasks
- [Finally Tasks](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/finally-tasks) - Guaranteed cleanup regardless of Pipeline outcome
- [Matrix documentation](https://tekton.dev/docs/pipelines/matrix/) - Full reference for Matrix configuration
