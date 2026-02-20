# Matrix - Fan-Out for Multi-Platform Builds

In CI/CD, you often need to run the same test or build across multiple
configurations - different operating systems, language versions, or
architectures. Tekton's **Matrix** feature (defined in TEP-0090) lets you fan out
a single PipelineTask into multiple parallel TaskRuns by specifying parameter
combinations.

Instead of duplicating Tasks for each platform or version, you declare a matrix
of parameters, and Tekton automatically creates a TaskRun for every combination
in the Cartesian product.

In this tutorial, you will learn:

- How to declare a **Matrix** on a PipelineTask to fan out across parameters
- How Tekton creates one **TaskRun per combination** in the Cartesian product
- How to **inspect** individual fan-out TaskRuns and their parameters
- How to use **matrix.include** to add specific extra combinations

**Prerequisites:** You should be familiar with Tasks, Pipelines, and parameters
(covered in the Basic Pipeline and Task Results tutorials).

Matrix is a **beta feature** available in Tekton Pipelines v1.9.0 and later.

While the environment loads, Tekton Pipelines and the `tkn` CLI are being
installed in the background. This may take a minute or two.
