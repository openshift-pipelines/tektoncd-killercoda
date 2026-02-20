# Congratulations!

You have learned how to use Tekton's **object and array parameter types** for
structured data passing in your CI/CD pipelines.

## What you learned

- **Object parameters** let you group related values (image, tag, registry) into
  a single structured parameter with typed properties
- **Array parameters** let you pass lists of values that expand in commands
- **Object results** let Tasks emit structured metadata that other Tasks consume
- **Structured data flow** through Pipelines using object results and parameters

## Key points to remember

- Object parameters use `type: object` with `properties` defining each field
- Access object fields with dot notation: `$(params.config.image)`
- Array parameters use `type: array` and expand with `$(params.flags[*])`
- Object results write each property to its own path: `$(results.name.field.path)`
- Pipelines can pass object results between Tasks field-by-field

## Real-world use cases

- **Build configuration**: Group image, tag, registry, and platform into one object
- **Multi-target operations**: Pass arrays of directories, images, or environments
- **Metadata propagation**: Pass build digests, timestamps, and sizes between Tasks
- **Configuration management**: Group feature flags or settings into object parameters

## What's next

- [Pipelines in Pipelines](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/pipelines-in-pipelines) - Compose Pipelines within Pipelines
- [Matrix](https://killercoda.com/tekton/course/intermediate-pipeline-patterns/matrix-fan-out) - Fan out Tasks across parameter combinations
- [Parameters documentation](https://tekton.dev/docs/pipelines/tasks/#specifying-parameters) - Full reference for parameter types
