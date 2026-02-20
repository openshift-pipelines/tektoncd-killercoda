# Finally Tasks - Guaranteed Cleanup and Notifications

In programming, a `try/finally` block ensures that cleanup code runs regardless
of whether the main code succeeded or failed. Tekton Pipelines have the same
concept: **Finally Tasks**.

The `finally` section of a Pipeline defines Tasks that **always run** after all
regular Tasks have completed - whether they succeeded, failed, or were skipped.
This makes Finally Tasks ideal for:

- **Cleaning up resources** (deleting temporary namespaces, removing test data)
- **Sending notifications** (Slack messages, email alerts)
- **Reporting status** (updating a dashboard, posting to a PR)
- **Releasing locks** (freeing shared resources)

In this tutorial, you will learn:

- How to add **Finally Tasks** to a Pipeline
- How Finally Tasks run even when **regular Tasks fail**
- How to access **Pipeline status** (`$(tasks.status)`) inside Finally Tasks

**Prerequisites:** You should be familiar with Tasks, Pipelines, and When
Expressions (covered in the previous tutorials).

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
