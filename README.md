# Tekton Killercoda Tutorials

Interactive tutorials for learning [Tekton](https://tekton.dev), hosted on
[Killercoda](https://killercoda.com/tekton).

## Available Tutorials

### Getting Started

| Tutorial | Description | Difficulty | Duration |
|----------|-------------|------------|----------|
| [Basic Pipeline](https://killercoda.com/tekton/course/getting-started/basic-pipeline) | Create Tasks, build a Pipeline, and run it | Beginner | 30 min |
| [Dashboard](https://killercoda.com/tekton/course/getting-started/dashboard) | Install and use the Tekton Dashboard UI | Beginner | 30 min |
| [Workspaces](https://killercoda.com/tekton/course/getting-started/workspaces) | Share data between Tasks using Workspaces | Beginner | 25 min |
| [Triggers](https://killercoda.com/tekton/course/getting-started/triggers) | Automatically trigger Pipelines with events | Intermediate | 30 min |
| [Authentication](https://killercoda.com/tekton/course/getting-started/authentication) | Use Secrets and ServiceAccounts for private repos and registries | Intermediate | 25 min |
| [Build and Deploy](https://killercoda.com/tekton/course/getting-started/build-and-deploy) | Build a real CI/CD pipeline that clones, builds, and deploys | Intermediate | 35 min |

### Recommended Learning Path

1. **Basic Pipeline** - Learn the fundamentals: Tasks, Pipelines, PipelineRuns
2. **Dashboard** - Visualize and manage your pipelines through a web UI
3. **Workspaces** - Share data between Tasks (essential for real CI/CD)
4. **Triggers** - Automate pipeline execution with events
5. **Authentication** - Securely access private repos and registries
6. **Build and Deploy** - Put it all together in a realistic CI/CD workflow

## Contributing

Contributions are welcome! To add or update tutorials:

1. Fork and clone this repository
2. Create or edit scenario files following the [Killercoda documentation](https://killercoda.com/docs)
3. Test your changes (see below)
4. Submit a pull request

### Repository Structure

```
tektoncd-killercoda/
├── structure.json                    # Top-level course organization
├── getting-started/
│   ├── structure.json                # Course section organization
│   ├── basic-pipeline/              # Tasks and Pipelines basics
│   ├── dashboard/                   # Tekton Dashboard UI
│   ├── workspaces/                  # Sharing data between Tasks
│   ├── triggers/                    # Event-driven pipeline automation
│   └── build-and-deploy/           # Realistic CI/CD workflow
└── .github/
    └── workflows/
        └── validate.yaml            # CI validation
```

Each tutorial directory contains:
- `index.json` - Scenario configuration (title, steps, backend image)
- `intro.md` - Introduction page
- `step[N].md` - Tutorial steps
- `finish.md` - Completion page
- `scripts/` - Install (background) and verification scripts

### Testing Locally

Killercoda scenarios cannot be fully tested locally since they require the
Killercoda infrastructure. However, you can validate the structure:

```bash
# Validate all JSON files
find . -name "*.json" -exec sh -c 'echo "Checking {}..." && jq . {} > /dev/null' \;

# Check that all referenced files exist
for idx in $(find . -name "index.json"); do
  dir=$(dirname "$idx")
  echo "Checking $idx..."
  jq -r '.details.steps[].text' "$idx" | while read f; do
    [ -f "$dir/$f" ] || echo "  MISSING: $dir/$f"
  done
done
```

To test on Killercoda, push to your fork and connect it to your Killercoda
account at https://killercoda.com/creator.

## History

These tutorials were originally created for the [Katacoda](https://katacoda.com)
platform and hosted in the [tektoncd/website](https://github.com/tektoncd/website)
repository. They were removed in May 2022
([tektoncd/website#376](https://github.com/tektoncd/website/pull/376)) when
O'Reilly shut down the Katacoda platform. This repository restores and
modernizes those tutorials for the [Killercoda](https://killercoda.com) platform,
with additional tutorials covering Workspaces, Triggers, and CI/CD workflows.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
