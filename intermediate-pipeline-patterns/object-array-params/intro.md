# Object and Array Parameters

Tekton's basic parameters use the `string` type, which works for simple values
like image names or version numbers. But real-world CI/CD often needs to pass
**structured data** between Tasks -- configuration objects, lists of targets, or
grouped settings.

Tekton supports two additional parameter types:

- **`object`** -- a key-value map with typed properties (like a JSON object)
- **`array`** -- an ordered list of string values

These types let you group related configuration into a single parameter instead
of passing many individual strings, and they let you fan out over lists of values
without resorting to Matrix.

In this tutorial, you will learn:

- How to declare **object-type parameters** with typed properties
- How to access individual fields of an object parameter
- How to declare **array-type parameters** and expand them in commands
- How to use **object and array results** to pass structured data between Tasks

**Prerequisites:** Familiarity with Tasks, Pipelines, and basic string parameters.

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
