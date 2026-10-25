# tofu

[![CI](https://github.com/sogeor/tofu/actions/workflows/lint.yml/badge.svg)](https://github.com/sogeor/tofu/actions/workflows/lint.yml)
[![Release](https://img.shields.io/github/v/release/sogeor/tofu?sort=semver)](https://github.com/sogeor/tofu/releases)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/sogeor/tofu/badge)](https://scorecard.dev/viewer/?uri=github.com/sogeor/tofu)
[![License: source-available](https://img.shields.io/badge/license-source--available-informational)](LICENSE)

> OpenTofu stacks for Sogeor: server inventory for Ansible, Cloudflare DNS and OpenBao configuration

Everything outside the Kubernetes cluster that has an API is described here. The `servers` stack is the single source of truth for which servers exist and how to reach them; [sogeor/ansible](https://github.com/sogeor/ansible) reads its state as an inventory and configures the servers. Server addresses and other sensitive values are encrypted with SOPS, and the state lives in S3, encrypted by OpenTofu.

## Table of Contents

- [Security](#security)
- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [Development](#development)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Security

Report vulnerabilities privately as described in the [security policy](https://github.com/sogeor/.github/blob/HEAD/SECURITY.md). Secrets in this repository are encrypted with SOPS; never commit them in plain text.

State, plans, `*.tfvars` and `.envrc` are never committed. The state is stored in S3 and encrypted with AES-GCM; the passphrase and the S3 credentials are kept only by the maintainers.

## Background

| Stack | Manages | State |
| --- | --- | --- |
| `servers/` | inventory of existing servers: names, Ansible groups, SSH address and port, WireGuard address. Servers are described, not provisioned | `s3://master/tofu/servers.tfstate` |
| `dns/` | Cloudflare zone `sogeor.com`: DNSSEC, CAA, DMARC and the null DKIM record, apex redirect to the GitHub organization, the `docs` GitHub Pages record, Email Routing of `security@`, `conduct@` and `legal@` to the address in `dns/dns.sops.yaml`, GitHub domain verification, a record per server and service records (`master`, `status`) built from the `servers` state | `s3://master/tofu/dns.tfstate` |
| `openbao/` (planned) | OpenBao policies, auth methods, secret engines | `s3://master/tofu/openbao.tfstate` |

How the `servers` stack feeds Ansible:

```text
servers/servers.sops.yaml ──▶ tofu apply ──▶ ansible_host / ansible_group in encrypted state (S3)
                                                        │
ansible-playbook ◀── cloud.terraform.terraform_provider inventory plugin ◀── tofu show -json
```

Later, entries in `servers.sops.yaml` are replaced by provider resources (`tofu import` for existing VPS); the Ansible side does not change.

## Install

Requirements:

- [OpenTofu](https://opentofu.org/docs/intro/install/) 1.10 or newer;
- [SOPS](https://github.com/getsops/sops) and [age](https://github.com/FiloSottile/age), with a maintainer's age key;
- [direnv](https://direnv.net/) (recommended) and `jq`.

Point SOPS at the age key (once, in `~/.bashrc`):

```bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/personal.key"
```

Create `.envrc` in the repository root (ignored by Git) with values from the password manager:

```bash
export AWS_ACCESS_KEY_ID="..."            # S3 user "tofu", Timeweb
export AWS_SECRET_ACCESS_KEY="..."
export TF_VAR_state_passphrase="..."      # OpenTofu state encryption
export CLOUDFLARE_API_TOKEN="..."         # dns stack, zone-scoped token
```

```bash
direnv allow
```

## Usage

```bash
cd servers
tofu init
tofu plan -out=servers.tfplan
tofu apply servers.tfplan && rm servers.tfplan
tofu output -json servers | jq
```

Add or change a server:

```bash
sops servers/servers.sops.yaml            # opens the decrypted file in $EDITOR
```

```yaml
<name>:
  groups: [control_plane]                 # Ansible groups
  kind: dedicated                         # dedicated | vps
  location: "..."
  provider: selectel
  public_ipv4: "..."
  ssh_port: 822
  wg_address: 172.20.0.2                  # admin WireGuard, 172.20.0.0/20
```

Then open a pull request, merge it and run `tofu plan` / `tofu apply`. The `dns` stack reads the applied `servers` state and adds `<name>.sogeor.com`, plus `master` for `control_plane` and `status` for `status` hosts; in CI it runs right after `servers`. Check the result from the Ansible repository:

```bash
ansible-inventory --graph
```

## Development

```bash
pre-commit install          # gitleaks, linters, secret checks, tofu fmt
pre-commit run --all-files
tofu fmt -recursive
(cd servers && tofu init -backend=false && tofu validate)
```

Provider versions are pinned in `.terraform.lock.hcl` and updated by Renovate.

## Maintainers

[Sogeor maintainers](https://github.com/orgs/sogeor/teams/maintainers)

## Contributing

Issues and pull requests are welcome. Read the [contributing guidelines](https://github.com/sogeor/.github/blob/HEAD/CONTRIBUTING.md) and the [Code of Conduct](https://github.com/sogeor/.github/blob/HEAD/CODE_OF_CONDUCT.md). Pull request titles follow [Conventional Commits](https://www.conventionalcommits.org/); first-time contributors sign the [CLA](https://github.com/sogeor/.github/blob/HEAD/CLA.md).

Changes are applied by maintainers only: CI does not have access to the state.

## License

© 2026 Georgii Sopin. [Sogeor License 1.0](LICENSE) (English and Russian; the Russian version prevails) — you may read the code and contribute, but not copy, redistribute or reuse it.
