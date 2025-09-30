# Durantic Helm Charts

This repository contains Helm charts for all Durantic services.

## Charts

- **dashboard**: Web frontend for Durantic control plane
- **controlplane**: Backend API and services (coming soon)
- **agent**: Durantic monitoring agent (coming soon)

## Usage

### Using from GitHub

```bash
# Add the repo
helm repo add durantic https://raw.githubusercontent.com/durantic/charts/main

# Install dashboard
helm install dashboard durantic/dashboard \
  --values my-values.yaml
```

### Local Development

```bash
# Install locally
helm install dashboard ./dashboard \
  --values dashboard/values-stage.yaml
```

## Development

When making changes to charts:

1. Update `Chart.yaml` version (semver)
2. Update `CHANGELOG.md`
3. Test with `helm lint` and `helm template`
4. Create PR for review
5. After merge, tag release

### Versioning

Charts use semantic versioning:
- **Major**: Breaking changes
- **Minor**: New features (backwards compatible)
- **Patch**: Bug fixes

## Testing

```bash
# Lint chart
helm lint dashboard/

# Generate templates
helm template test-release dashboard/ \
  --values dashboard/values-stage.yaml

# Dry run install
helm install test-release dashboard/ \
  --values dashboard/values-stage.yaml \
  --dry-run --debug
```

## Chart Structure

```
dashboard/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── values-example.yaml # Example configuration
├── values-stage.yaml   # Stage environment values
├── README.md          # Chart documentation
└── templates/         # Kubernetes manifests
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── configmap.yaml
    ├── serviceaccount.yaml
    ├── hpa.yaml
    └── poddisruptionbudget.yaml
```

## Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit PR
5. Wait for review

## Support

For issues or questions, open an issue in this repository.