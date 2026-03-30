# claude+gsd

Docker image for running Claude Code with [get-shit-done](https://www.npmjs.com/package/get-shit-done-cc) inside [NVIDIA OpenShell](https://docs.nvidia.com/openshell/latest/about/overview.html) sandboxes. Provides an isolated, policy-controlled environment where Claude Code runs in `--dangerously-skip-permissions` mode with network egress restricted to declared endpoints.

## Quick start

```sh
# Requires: openshell CLI, CLAUDE_CODE_OAUTH_TOKEN, GH_TOKEN or GITHUB_TOKEN
./start <owner/repo> [sandbox-name]
```

The `start` script:
1. Ensures `claude-oauth` and `github` providers exist on the gateway (creates them if not)
2. Creates a per-sandbox provider with `GSD_REPO` pointing to the target repo
3. Builds and launches the sandbox from this directory's Dockerfile with `policy.yaml` applied

## Key files

| File | Purpose |
|---|---|
| `Dockerfile` | Ubuntu 24.04 image with Claude Code, Node 24 (NVM), uv, gh CLI, get-shit-done-cc |
| `start` | Host-side script to create an OpenShell sandbox for a given repo |
| `entrypoint.sh` | In-container init: copies config, sets up git/gh auth, clones `GSD_REPO`, launches Claude Code |
| `policy.yaml` | OpenShell policy (v1): filesystem, process, and network rules |
| `default.claude/` | Default Claude Code config copied into the image at build time (bypass permissions, opus model) |
| `.zshrc` | Shell config with git aliases and NVM setup |

## Container layout

- User: `sandbox` (uid/gid 1000, required by OpenShell)
- Shell: zsh
- Working directory: `/home/sandbox/workspace` (after repo clone)
- Config files stored in `/opt/claude-gsd/` to survive home volume mounts

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `CLAUDE_CODE_OAUTH_TOKEN` | Yes | OAuth token for Claude Code API access (injected via OpenShell provider, never inside sandbox) |
| `GH_TOKEN` / `GITHUB_TOKEN` | Yes | GitHub auth (injected via OpenShell provider) |
| `GSD_REPO` | Set by `start` | GitHub repo to clone (owner/repo format) |
| `GIT_USER_NAME` | No | Git commit author name |
| `GIT_USER_EMAIL` | No | Git commit author email |

## Network policy summary

All egress is default-deny. The policy allows:

- **GitHub**: API (`api.github.com`), git (`github.com`), content CDN (`*.githubusercontent.com`, `codeload.github.com`)
- **Claude Code**: `api.anthropic.com`, `claude.ai`, `platform.claude.com`, telemetry (`statsig.anthropic.com`, `sentry.io`)
- **npm**: `registry.npmjs.org`
- **PyPI**: `pypi.org`, `files.pythonhosted.org`

Each policy rule restricts which binaries can access which endpoints. Credentials are injected by the OpenShell proxy -- they never exist inside the sandbox.

## Building without OpenShell

```sh
docker build -t claude-gsd .
```

The image can run standalone but loses OpenShell's network policy enforcement and credential injection.

## Modifying the policy

Edit `policy.yaml`. Filesystem and process policies are static (require sandbox recreation). Network policies can be hot-reloaded on a running sandbox:

```sh
openshell policy set <sandbox-name> --policy ./policy.yaml --wait
```
