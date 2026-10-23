# {{REPO_NAME}}

[![CI](https://github.com/sogeor/{{REPO_NAME}}/actions/workflows/lint.yml/badge.svg)](https://github.com/sogeor/{{REPO_NAME}}/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/sogeor/{{REPO_NAME}}?sort=semver)](https://github.com/sogeor/{{REPO_NAME}}/releases)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/sogeor/{{REPO_NAME}}/badge)](https://scorecard.dev/viewer/?uri=github.com/sogeor/{{REPO_NAME}})
[![License: source-available](https://img.shields.io/badge/license-source--available-informational)](LICENSE)

> {{SHORT_DESCRIPTION — one line, under 120 characters}}

{{LONG_DESCRIPTION — what the project does, who it is for, how it fits into Sogeor. (optional)}}

## Table of Contents

- [Security](#security)
- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [Development](#development)
- [API](#api)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Security

Report vulnerabilities privately as described in the [security policy](https://github.com/sogeor/.github/blob/HEAD/SECURITY.md). Secrets in this repository are encrypted with SOPS; never commit them in plain text.

## Background

{{Why the project exists, design decisions, links to architecture documents. (optional)}}

## Install

{{Prerequisites and installation/deployment. For services: how the release reaches the cluster (image + OCI chart → Renovate PR to sogeor/fleet → Flux).}}

```bash
{{commands}}
```

## Usage

{{How to use it: examples, configuration options, environment variables.}}

## Development

```bash
pre-commit install          # gitleaks, linters, secret checks
{{build / test commands, e.g. cargo test or ./gradlew check}}
```

## API

{{Link to the API reference, e.g. <https://api.sogeor.com/docs>. (optional)}}

## Maintainers

[Sogeor maintainers](https://github.com/orgs/sogeor/teams/maintainers)

## Contributing

Issues and pull requests are welcome. Read the [contributing guidelines](https://github.com/sogeor/.github/blob/HEAD/CONTRIBUTING.md) and the [Code of Conduct](https://github.com/sogeor/.github/blob/HEAD/CODE_OF_CONDUCT.md). Pull request titles follow [Conventional Commits](https://www.conventionalcommits.org/); first-time contributors sign the [CLA](https://github.com/sogeor/.github/blob/HEAD/CLA.md).

## License

© {{YEAR}} Georgii Sopin. [Sogeor License 1.0](LICENSE) (English and Russian; the Russian version prevails) — you may read the code and contribute, but not copy, redistribute or reuse it.
