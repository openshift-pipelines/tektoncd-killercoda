# Create a Pipeline and run it from the Dashboard

## Create the Pipeline

First, create a Pipeline that chains the `hello` and `goodbye` Tasks together:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: hello-goodbye
spec:
  tasks:
    - name: hello
      taskRef:
        name: hello
    - name: goodbye
      runAfter:
        - hello
      taskRef:
        name: goodbye
EOF
```

## View the Pipeline in the Dashboard

Go to the Dashboard and click on **Pipelines** in the left sidebar. You should
see the `hello-goodbye` Pipeline listed. Click on it to see its details.

## Create a PipelineRun from the Dashboard

1. In the Dashboard, click on **PipelineRuns** in the left sidebar
2. Click the **Create** button (blue "+" button)
3. Select the `hello-goodbye` Pipeline from the Pipeline dropdown
4. Leave the default namespace as `default`
5. Click **Create** to start the PipelineRun

## Monitor the PipelineRun

After creating the PipelineRun, the Dashboard will show you its progress. You
can:

- Watch the status of each Task in the Pipeline as it executes
- Click on individual Tasks to view their logs
- See the overall Pipeline status change from "Running" to "Succeeded"

You can also monitor from the terminal:

<!-- e2e-skip -->
```bash
tkn pipelinerun logs --last -f
```

When complete, you should see:

```
[hello : hello] Hello World!

[goodbye : goodbye] Goodbye World!
```

## Explore the Dashboard

Take some time to explore what the Dashboard shows you:

- Click on **TaskRuns** to see the individual TaskRuns created by the
  PipelineRun
- Click on any TaskRun to see its detailed logs and status
- Try creating another PipelineRun using the Dashboard
