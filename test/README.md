# E2E Testing for Tekton Killercoda Tutorials

Automated end-to-end test framework that proves each Killercoda tutorial works
on a real Kubernetes cluster. Runs install scripts, extracts and executes bash
blocks from step Markdown files, and validates verify scripts -- all with
timeouts and retry logic.

## Prerequisites

- **kind** (or any Kubernetes cluster accessible via kubectl)
- **kubectl** configured to talk to your cluster
- **jq** for JSON parsing
- **bash** 4+ (macOS users: `brew install bash`)

## Running a Single Tutorial

```bash
./test/e2e-runner.sh getting-started/basic-pipeline
```

With a custom log directory:

```bash
./test/e2e-runner.sh getting-started/basic-pipeline --log-dir ./my-logs
```

## Running All Tutorials

```bash
for tutorial_dir in $(find . -name index.json -not -path './.git/*' -not -path './test/*' | xargs -I{} dirname {}); do
  echo "=== Testing: ${tutorial_dir} ==="
  ./test/e2e-runner.sh "$tutorial_dir" --log-dir "/tmp/e2e-logs/$(echo "$tutorial_dir" | tr '/' '-')"
done
```

Note: Running all tutorials sequentially takes a long time. For CI, use the
GitHub Actions workflow which runs tutorials in parallel with separate kind
clusters.

## What the Runner Does

For each tutorial, `e2e-runner.sh` follows this lifecycle:

1. **Parse** `index.json` to discover steps, verify scripts, and the install script
2. **Install** -- runs `scripts/install.sh` in the foreground (5-minute timeout)
3. **Step execution** -- for each step:
   - Extracts `bash` fenced code blocks from the step Markdown file
   - Executes each block with a 2-minute timeout
   - Runs the verify script with retry logic (3 attempts, 5-second delay, 1-minute timeout per attempt)
4. **Summary** -- prints an ASCII table showing PASS/FAIL and duration per step

### Block Extraction

`extract-bash-blocks.sh` uses AWK to extract **only** fenced code blocks marked
with ` ```bash `. It skips:

- ` ```yaml ` blocks (display-only YAML examples)
- ` ```json ` blocks (display-only JSON examples)
- Bare ` ``` ` blocks (output examples, not executable)

This distinction is critical: tutorials contain ~721 executable bash blocks and
~43 display-only blocks.

## Log Output

Logs are written to the log directory (default: `/tmp/e2e-logs/`):

```
/tmp/e2e-logs/
  install.log           # install.sh stdout+stderr
  step1-block1.log      # step 1, bash block 1
  step1-block2.log      # step 1, bash block 2
  step1-verify.log      # verify-step1.sh output
  step2-block1.log      # step 2, bash block 1
  ...
  blocks/               # temp bash scripts (auto-cleaned)
    step1-block1.sh
    step1-block2.sh
    ...
```

## CI

See `.github/workflows/e2e.yaml` for the GitHub Actions CI workflow. It:

- Dynamically discovers all tutorials (no hardcoded list)
- Creates a fresh kind cluster per tutorial (isolation)
- Runs tutorials in parallel (max 8 concurrent)
- Uploads failure logs as artifacts (7-day retention)
- Supports manual single-tutorial runs via `workflow_dispatch`

## Adding New Tutorials

The test framework auto-discovers tutorials from `index.json` files. When you
add a new tutorial:

1. Create the tutorial with the standard structure (`index.json`, `scripts/install.sh`, step files, verify scripts)
2. Run `./test/e2e-runner.sh your-course/your-tutorial` to test locally
3. The CI workflow will automatically include it in the next run

No changes to the test framework are needed.

## Troubleshooting

### Timeout failures

- **Install timeout (5 min):** The install script is pulling large images or waiting for pods. Check `install.log` for the last line before timeout.
- **Block timeout (2 min):** A command is hanging. Check the block log and the corresponding step Markdown for what command was running.
- **Verify timeout (1 min):** The verify script is waiting for a resource that never appears. Check cluster state with `kubectl get all`.

### Verify retry failures

Verify scripts retry 3 times with 5-second delays to handle Kubernetes eventual
consistency. If a verify still fails after 3 attempts:

- Check if the step's bash blocks actually created the expected resources
- Verify the cluster has enough resources (check `kubectl describe nodes`)
- Look at pod events: `kubectl get events --sort-by=.lastTimestamp`

### OOM / resource issues

Kind clusters have limited resources. If tutorials fail due to OOM:

- Increase Docker memory allocation
- Run fewer tutorials in parallel
- Check for resource-heavy tutorials (image builds, multiple deployments)

### Flaky tests

Some tutorials depend on external resources (image pulls, GitHub releases).
Network issues can cause flakiness. Re-run the specific tutorial to confirm.
