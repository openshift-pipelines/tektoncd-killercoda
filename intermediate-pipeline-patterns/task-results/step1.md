# Create a Task that emits a Result

A Task can declare **Results** in its `spec.results` section. Each Result has a
name and an optional description. Inside the Task's steps, you write data to the
Result using the special path `$(results.<name>.path)`.

## Declare and emit a Result

Create a `generate-id` Task that generates a random build ID and emits it as a
Result:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: generate-id
spec:
  results:
    - name: build-id
      description: A randomly generated build identifier
  steps:
    - name: generate
      image: alpine:3.19
      script: |
        #!/usr/bin/env sh
        BUILD_ID="build-\$(date +%s)-\$(shuf -i 1000-9999 -n 1)"
        echo "Generated build ID: \$BUILD_ID"
        echo -n "\$BUILD_ID" > \$(results.build-id.path)
EOF
```

There are three important things to notice here:

1. **`spec.results`** declares a Result named `build-id` - this tells Tekton
   the Task will produce this piece of data.
2. **`$(results.build-id.path)`** is the file path where the Result value must
   be written. Tekton reads this file after the step completes.
3. **`echo -n`** writes the value without a trailing newline - this is a best
   practice that avoids unexpected whitespace when the Result is consumed
   downstream.

## Run the Task

Now create a TaskRun to execute the `generate-id` Task:

```bash
tkn task start generate-id --showlog
```

You should see output showing the generated build ID. Tekton captures the value
written to the Result path and stores it in the TaskRun status.

## Verify the Result was captured

Check the TaskRun's results:

<!-- e2e-skip -->
```bash
tkn taskrun describe --last
```

In the output, you should see a **Results** section showing the `build-id` value
that was emitted by the Task.
