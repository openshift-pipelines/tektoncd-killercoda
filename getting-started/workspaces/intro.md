# Introduction to Tekton Workspaces

In real CI/CD workflows, Tasks often need to share data with each other. For
example, one Task might clone source code from a Git repository, and a
subsequent Task needs to build that source code. Tekton **Workspaces** provide
a way to share data between Tasks in a Pipeline.

A Workspace is a volume that is mounted into a Task's Steps. When used in a
Pipeline, the same Workspace can be passed to multiple Tasks, allowing them to
share files.

In this tutorial, you will learn:

- How to declare a Workspace in a Task
- How to write data to a Workspace in one Task
- How to read that data in another Task
- How to wire Workspaces through a Pipeline

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
