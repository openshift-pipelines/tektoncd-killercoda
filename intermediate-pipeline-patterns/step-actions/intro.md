# StepActions -- Reusable Step Definitions

In Tekton, a **StepAction** is a reusable definition of a single step that can
be referenced from any Task. Think of it as the step-level equivalent of what
Tasks are to Pipelines -- just as you can define a Task once and reference it
from many Pipelines using `taskRef`, you can define a StepAction once and
reference it from many Tasks using `ref`.

Before StepActions, if you wanted the same step logic in multiple Tasks, you had
to copy and paste the step definition into each Task. This led to duplication
and made maintenance harder. StepActions solve this by letting you define step
logic once and share it everywhere.

In this tutorial, you will learn:

- How to create a **StepAction** with `apiVersion: tekton.dev/v1beta1`
- How to **reference a StepAction** from a Task using `ref`
- How to **parameterize StepActions** for flexible reuse across different Tasks
- How to use StepAction-powered Tasks in a **Pipeline**

**Prerequisites:** You should be familiar with creating Tasks and Pipelines
(covered in the Basic Pipeline tutorial).

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
