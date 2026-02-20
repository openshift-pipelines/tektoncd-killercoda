# Task Results and Data Passing Between Tasks

In Tekton, **Results** are small pieces of data (up to 4096 bytes) that a Task
can emit for downstream consumption. Results allow Tasks within a Pipeline to
communicate by passing data such as commit SHAs, image digests, build IDs, or
status messages from one Task to the next.

In this tutorial, you will learn:

- How to declare and emit **Results** from a Task
- How to **pass Results** between Tasks in a Pipeline
- How to **inspect Results** using `tkn` and `kubectl`
- How to build multi-Task Pipelines that chain data through Results

**Prerequisites:** You should be familiar with creating Tasks and Pipelines
(covered in the Basic Pipeline tutorial).

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
