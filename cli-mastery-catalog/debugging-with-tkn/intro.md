# Debugging Failed Pipelines with tkn

When a Pipeline fails, knowing how to quickly find and fix the problem is a
critical skill. The `tkn` CLI provides powerful commands for inspecting failed
PipelineRuns, reading Task logs, and diagnosing issues at every level.

In this tutorial, you will learn:

- How to create Pipelines that fail in different ways (wrong image, script errors)
- How to use `tkn pipelinerun describe`, `tkn taskrun describe`, and
  `tkn taskrun logs` to trace failures
- How to use `kubectl describe pod` for low-level debugging
- How to fix Tasks and rerun Pipelines with `tkn pipeline start --last`
- How to cancel running PipelineRuns

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
