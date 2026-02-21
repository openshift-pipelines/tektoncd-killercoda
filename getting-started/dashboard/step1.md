# Access the Tekton Dashboard

## Verify the installation

It takes approximately 3-4 minutes for the environment to install Tekton
Pipelines and the Dashboard (images are pulled from the internet on each
start). Check if the pods are running:

```bash
kubectl get pods -n tekton-pipelines
```

You should see pods for both `tekton-pipelines-controller`,
`tekton-pipelines-webhook`, and `tekton-dashboard` in a `Running` state. If
they are not yet ready, wait a moment and try again.

## Expose the Tekton Dashboard

The Tekton Dashboard is running as a Service inside the cluster. To access it,
set up a port forward:

<!-- e2e-skip -->
```bash
kubectl port-forward -n tekton-pipelines --address=0.0.0.0 service/tekton-dashboard 8080:9097 > /dev/null 2>&1 &
```

## Open the Tekton Dashboard

Click on the "Traffic / Ports" tab at the top of the terminal, then select
port **8080** to open the Tekton Dashboard in your browser.

You should see the Dashboard homepage showing an overview of your Tekton
resources. At this point, there won't be any Tasks, Pipelines, or runs - we'll
create those in the next steps.

Take a moment to explore the left sidebar navigation:
- **TaskRuns** - View and manage TaskRuns
- **PipelineRuns** - View and manage PipelineRuns
- **Tasks** - View installed Tasks
- **Pipelines** - View installed Pipelines
