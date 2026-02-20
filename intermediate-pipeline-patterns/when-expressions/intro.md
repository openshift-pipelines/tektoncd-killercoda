# When Expressions and Conditional Pipeline Logic

**When Expressions** are conditional gates on Tasks within a Pipeline. They let
you skip or run a Task based on the value of parameters, Results, or other data.
This is how you implement branching logic in Tekton Pipelines.

Common use cases for When Expressions:

- **Skip deployment** when the branch is not `main`
- **Skip tests** when only documentation files changed
- **Conditionally notify** based on a previous Task's output
- **Gate promotion** based on approval status

In this tutorial, you will learn:

- How to **skip a Task** using a When Expression with parameters
- How to use **Results in When Expressions** for dynamic conditions
- How to **combine multiple When Expressions** (AND logic)
- How skipped Tasks affect Pipeline status

**Prerequisites:** You should be familiar with Task Results and data passing
(covered in the Task Results tutorial).

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
