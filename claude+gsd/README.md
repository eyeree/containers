# claude+gsd

Docker image for running Claude Code with [get-shit-done](https://www.npmjs.com/package/get-shit-done-cc) inside [NVIDIA OpenShell](https://docs.nvidia.com/openshell/latest/about/overview.html) sandboxes. Provides an isolated, policy-controlled environment where Claude Code runs in `--dangerously-skip-permissions` mode with network egress restricted to declared endpoints.

## Quick start

```sh
# Prerequisite: openshell CLI

cp example.env .env
$EDITOR .env # set CLAUDE_CODE_OAUTH_TOKEN and GH_TOKEN

# First time (or after Dockerfile changes): build and push image to gateway
./build

# Create sandboxes (uses pre-built image, instant startup)
./create [--name NAME] [--build] [repo...] [-- command...]
```

Examples:
```sh
./create owner/repo                  # clone one repo, run claude
./create a/one b/two                 # clone multiple repos, run claude
./create owner/repo -- zsh           # clone repo, run zsh instead
./create -- zsh                      # no repos, run zsh
./create                             # no repos, run claude
./create --name my-box owner/repo    # clone repo, named sandbox
./create --build owner/repo          # force rebuild of image
```

The `build` script builds the Docker image and pushes it to the OpenShell gateway once. The image tag is saved to `.image-tag`. Subsequent `create` calls reference the pre-built image.

The `create` script:
1. Uses the pre-built image from `.image-tag` (or re-builds with `--build`)
2. Launches the sandbox with `policy.yaml` applied
3. Passes repos and optional command through to `entrypoint.sh`

> [!NOTE]
> If the gateway is destroyed the previously uploaded image will be lost and the contents of the `.image-tag` file will be invalid. In this case attempting to create without first doing a build will result in polling for the missing image. If that happens, stop the creation process and re-run with the `--build` option, or run `./build` first.

## Other Scripts

`./connect`, `./delete`, `./list`, `./upload`, and `./download` are just shortcuts for `openshell sandbox connect|delete|list|upload|download`, respectively.