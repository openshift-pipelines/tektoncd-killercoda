# Advanced tkn: start with params and dry-run

In this final step, you will learn advanced ways to start runs using `tkn`,
including parameter passing, re-running with `--last`, and using default
parameter values.

## Start with explicit parameters

You have already seen `-p` for passing parameters. Let's use it with the
Pipeline and explicitly set both parameters:

```bash
tkn pipeline start greeting-pipeline \
  -p greeting="Greetings" \
  -p name="Engineer" \
  --showlog
```

Each `-p` flag sets one parameter. The format is `-p name=value`.

## Re-run with --last

The `--last` flag re-runs a Pipeline (or Task) using the same parameters as the
most recent run. This is very useful when you want to retry a failed run or
re-execute the same configuration:

```bash
tkn pipeline start greeting-pipeline --last --showlog
```

This picks up the parameters from the previous run (greeting="Greetings",
name="Engineer") and starts a new PipelineRun with the same values.

## Use default parameter values

The `--use-param-defaults` flag starts a run using whatever default values are
defined in the Pipeline (or Task) spec. This avoids the interactive prompt when
all parameters have defaults:

```bash
tkn pipeline start greeting-pipeline --use-param-defaults --showlog
```

Since the Pipeline defines `greeting: "Hello"` and `name: "Tekton"` as defaults,
this run uses those values without asking for input.

## Combine flags for scripting

These flags are especially useful in scripts and CI environments where you need
non-interactive execution. Compare these approaches:

1. **Explicit parameters** - full control over every value:
   ```bash
   tkn pipeline start greeting-pipeline \
     -p greeting="Hi" \
     -p name="Bot" \
     --showlog
   ```

2. **Default parameters** - quick runs with predefined values:
   ```bash
   tkn pipeline start greeting-pipeline --use-param-defaults --showlog
   ```

3. **Re-run last** - retry or repeat the previous execution:
   ```bash
   tkn pipeline start greeting-pipeline --last --showlog
   ```

## Verify the final run

Check the latest PipelineRun to confirm everything worked:

```bash
tkn pipelinerun describe --last
```

You should see a successful run with the parameters from whichever approach you
used last. All three methods are equivalent in terms of what they produce - a
PipelineRun with resolved parameter values.
