# Configure Results Retention Policies

Tekton Results stores historical PipelineRun and TaskRun data in a database.
Over time, this data grows and can consume significant storage. **Retention
policies** let you automatically clean up old records based on age or count.

Without retention policies, your Results database grows indefinitely. In
production, a busy Tekton cluster might generate thousands of records per day,
and you need a strategy for managing this data lifecycle.

In this tutorial, you will learn:

- The default Results **retention behavior** (keep everything)
- How to configure **time-based retention** (delete records older than N days)
- How to configure **count-based retention** (keep only the last N records)
- How to verify the **retention worker** is cleaning up expired records

**Prerequisites:** Familiarity with Tekton Results (covered in the Install
Results and Query History tutorial).

While the environment loads, Tekton Pipelines, Results, and PostgreSQL are being
installed. This may take a minute or two.
