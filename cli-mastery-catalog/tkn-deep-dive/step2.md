# Master tkn logs and run management

In a real CI/CD environment, you will have many runs building up over time. In
this step, you will learn how to manage logs, list runs, and clean up old runs.

## Run the Pipeline

First, start the greeting Pipeline:

```bash
tkn pipeline start greeting-pipeline --showlog
```

Run it a second time with different parameters to build up some history:

```bash
tkn pipeline start greeting-pipeline \
  -p greeting="Howdy" \
  -p name="Partner" \
  --showlog
```

And a third time:

```bash
tkn pipeline start greeting-pipeline \
  -p greeting="Bonjour" \
  -p name="Monde" \
  --showlog
```

## View logs for runs

The `logs` command lets you access logs for any run. To see logs from the most
recent PipelineRun:

```bash
tkn pipelinerun logs --last
```

You can also follow logs in real time using the `-f` flag. This is especially
useful when you start a run and want to watch it progress. Let's start a new run
without `--showlog` and then follow the logs separately:

```bash
tkn pipeline start greeting-pipeline -p greeting="Hola" -p name="Amigo"
```

Now follow the logs of the most recent run:

```bash
tkn pipelinerun logs --last -f
```

The `-f` (follow) flag works like `tail -f` -- it streams new log lines as they
appear and exits when the run completes.

## List and manage runs

See all PipelineRuns:

```bash
tkn pipelinerun list
```

This shows each run's name, status, and duration. You can also list TaskRuns:

```bash
tkn taskrun list
```

## Clean up old runs

Over time, runs accumulate and consume cluster resources. Use the `--keep` flag
with `delete` to retain only the most recent runs:

```bash
tkn pipelinerun delete --keep 3 -f
```

This deletes all PipelineRuns except the 3 most recent ones. The `-f` flag skips
the confirmation prompt. Verify the cleanup:

```bash
tkn pipelinerun list
```

You can apply the same pattern to TaskRuns:

```bash
tkn taskrun delete --keep 3 -f
```

This is a common operational pattern: schedule periodic cleanup with `--keep` to
prevent unbounded growth of completed runs.
