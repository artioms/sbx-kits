# SBX Kits

Reusable, composable Docker Sandbox kits. Each kit has one responsibility and can be combined with a shell workload or other kits.

## Available kits

| Kit | Responsibility |
| --- | --- |
| [`runtimes/node/`](./runtimes/node/) | Node.js 22, 24, or 26 LTS runtime, selected with a kit argument |
| [`tools/terminal/`](./tools/terminal/) | Common terminal utilities: less, jq, ripgrep, and fd |
| [`agents/pi/`](./agents/pi/) | Pi coding agent CLI and agent-specific configuration |
| [`agents/opencode/`](./agents/opencode/) | OpenCode coding agent CLI and agent-specific configuration |

The older [`pi/`](./pi/) workload is retained for now and is planned for removal. Prefer composing the Pi agent mixin with the runtime and tools you need.

## Usage

Run a sandbox with a project directory mounted into it. From a local clone of this repository, replace `/Users/user/Dev/project` with the absolute path to your project. Use `.` to mount the current directory. Choose a unique `--name` if you run multiple sandboxes.

### Legacy Pi workload

The existing `pi/` workload is kept temporarily while it is phased out:

```bash
sbx run ./pi \
  --name sbx-pi \
  /Users/user/Dev/project
```

### Pi agent with a Node.js runtime

The reusable Pi agent and Node runtime are separate mixins. This example composes them with the shell workload and selects Node.js 26:

```bash
sbx run shell \
  --name sbx-pi-node \
  --kit ./agents/pi \
  --kit ./runtimes/node \
  --kit-arg node.version=26 \
  /Users/user/Dev/project
```

Choose `node.version=22` or `node.version=24` for those LTS lines. Kit arguments are prefixed by kit name when needed to distinguish arguments declared by multiple kits. If the workload already provides Node.js, omit the Node runtime kit and its argument.

### OpenCode agent with a Node.js runtime

OpenCode is available as a separate agent mixin. Compose it with the Node runtime if the shell workload does not already provide Node.js:

```bash
sbx run shell \
  --name sbx-opencode \
  --kit ./agents/opencode \
  --kit ./runtimes/node \
  --kit-arg node.version=24 \
  /Users/user/Dev/project
```

See the [OpenCode mixin documentation](./agents/opencode/README.md) for its model argument and usage.

### Node.js runtime only

```bash
sbx run shell \
  --name sbx-node \
  --kit ./runtimes/node \
  --kit-arg version=24 \
  .
```

Verify the selected runtime in the sandbox with `node --version`, `npm --version`, and `npx --version`. See the [Node runtime documentation](./runtimes/node/README.md) for pinned patch releases, architecture support, platform requirements, and the update process.

### Run kits directly from GitHub

Docker Sandbox can fetch kits from a Git repository. Replace `<OWNER>/<REPOSITORY>` and `<COMMIT>` with the repository and an immutable commit SHA. The `dir` parameter selects a kit directory:

```bash
sbx run shell \
  --name sbx-pi-node \
  --kit "git+https://github.com/<OWNER>/<REPOSITORY>.git#ref=<COMMIT>&dir=agents/pi" \
  --kit "git+https://github.com/<OWNER>/<REPOSITORY>.git#ref=<COMMIT>&dir=runtimes/node" \
  --kit "git+https://github.com/<OWNER>/<REPOSITORY>.git#ref=<COMMIT>&dir=tools/terminal" \
  --kit-arg node.version=26 \
  /Users/user/Dev/project
```

For this repository, the same example using `main` is:

```bash
sbx run shell \
  --name sbx-pi-node \
  --kit "git+https://github.com/artioms/sbx-kits.git#ref=main&dir=agents/pi" \
  --kit "git+https://github.com/artioms/sbx-kits.git#ref=main&dir=runtimes/node" \
  --kit "git+https://github.com/artioms/sbx-kits.git#ref=main&dir=tools/terminal" \
  --kit-arg node.version=26 \
  .
```

The `main` example follows repository updates and is not immutable. For reproducible builds, use the same commit SHA in both kit URLs. Git-based kit sources may be restricted by Docker Sandbox configuration; allow Git sources if your installation blocks them by default. See Docker's [kit source documentation](https://docs.docker.com/ai/sandboxes/customize/use-kits/#choose-a-kit-source).

## Security

- Credentials are managed by Docker Sandbox; never store real API keys in kit files or images.
- Network access is declared by the relevant workload or kit.
- Prefer immutable Git commit references for reproducible composition.
