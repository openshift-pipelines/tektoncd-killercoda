# Congratulations!

You have completed a deep dive into the `tkn` CLI and learned how to manage
Tekton resources efficiently from the command line.

## What you learned

- **Listing and describing** Tasks, Pipelines, TaskRuns, and PipelineRuns
- **Streaming logs** in real time with `--showlog` and `tkn pipelinerun logs -f`
- **Managing runs** with `tkn pipelinerun list` and `tkn pipelinerun delete --keep`
- **Formatting output** as JSON and YAML with `-o json` and `-o yaml`
- **Processing output** with `jq` for dashboards, monitoring, and automation
- **Dry-run mode** with `--dry-run -o yaml` for template generation
- **Starting runs** with `-p`, `--last`, and `--use-param-defaults`

## Key commands reference

| Command | Description |
|---------|-------------|
| `tkn task list` | List all Tasks |
| `tkn task describe <name>` | Show Task details |
| `tkn task start <name> --showlog` | Run a Task and stream logs |
| `tkn pipeline start <name> -p key=val` | Start Pipeline with parameters |
| `tkn pipelinerun logs --last -f` | Follow logs of latest run |
| `tkn pipelinerun describe --last -o json` | Get run details as JSON |
| `tkn pipelinerun delete --keep N -f` | Keep only N most recent runs |
| `tkn task start <name> --dry-run -o yaml` | Generate YAML without running |
| `tkn pipeline start <name> --last` | Re-run with previous parameters |
| `tkn pipeline start <name> --use-param-defaults` | Run with default values |

## What's next

- [Remote Resolvers](https://killercoda.com/tekton/course/cli-mastery-catalog/remote-resolvers) -- Fetch Tasks from remote sources without pre-installing them
- [Debugging Failed Pipelines with tkn](https://killercoda.com/tekton/course/cli-mastery-catalog/debugging-with-tkn) -- Diagnose and fix failed PipelineRuns
- [tkn CLI reference](https://tekton.dev/docs/cli/) -- Full documentation for all tkn commands
