# Tekton Killercoda Tutorials

Interactive tutorials for learning [Tekton](https://tekton.dev), hosted on
[Killercoda](https://killercoda.com/tekton).

## Available Tutorials

### Getting Started

| Tutorial | Description | Duration |
|----------|-------------|----------|
| [Basic Pipeline](https://killercoda.com/tekton/course/getting-started/basic-pipeline) | Create Tasks, build a Pipeline, and run it | 30 min |
| [Dashboard](https://killercoda.com/tekton/course/getting-started/dashboard) | Install and use the Tekton Dashboard UI | 30 min |

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
│   ├── basic-pipeline/              # Basic Pipeline tutorial
│   │   ├── index.json               # Scenario configuration
│   │   ├── intro.md                 # Introduction page
│   │   ├── step[1-3].md             # Tutorial steps
│   │   ├── finish.md                # Completion page
│   │   └── scripts/                 # Install and verification scripts
│   └── dashboard/                   # Dashboard tutorial
│       ├── index.json
│       ├── intro.md
│       ├── step[1-3].md
│       ├── finish.md
│       └── scripts/
└── .github/
    └── workflows/
        └── validate.yaml            # CI validation
```

### Scenario Configuration

Each tutorial has an `index.json` that defines:
- **title** and **description**: Displayed on Killercoda
- **difficulty** and **time**: Help learners choose appropriate tutorials
- **details.intro.background**: Script that runs when the scenario starts (e.g., installing Tekton)
- **details.steps**: Sequential tutorial steps with optional verification scripts
- **backend.imageid**: The Killercoda environment (`kubernetes-kubeadm-1node`)

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
modernizes those tutorials for the [Killercoda](https://killercoda.com) platform.

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.
