# Contributing to Helm OCI Publish Action

Thank you for considering contributing!

## Development Setup

1. Clone the repository
2. Make changes to scripts in `scripts/`
3. Test locally with real Helm charts
4. Update README.md with any new features

## Testing

Test the action locally:

```bash
# Set environment variables
export CHART_PATH=charts/my-chart
export VERSION=0.0.1
export APP_VERSION=0.0.1
export REGISTRY=ghcr.io/owner/charts
export GITHUB_TOKEN=your_token
export GITHUB_ACTOR=username

# Run scripts
bash scripts/update-version.sh
bash scripts/package-publish.sh
```

## Pull Request Guidelines

- Add examples for new features
- Update README.md
- Test with real Helm charts
- Follow existing code style

## License

MIT
