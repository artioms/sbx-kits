# Custom Docker Sandbox Kits

A collection of custom Docker Sandbox workload configurations for running development tools in isolated environments.

## Kits

| Kit | Description |
| --- | --- |
| [Pi](./pi/) | Pi coding agent with Docker-managed OpenAI OAuth |
| [Node 24](./node24/) | Node.js 24 development workload |

## Structure

- `pi/` — Pi coding agent sandbox configuration
- `node24/` — Node.js 24 sandbox configuration
- `shared/` — Reusable configuration and resources (planned)

## Usage

Run a sandbox with a project directory mounted into it. From a local clone of this repository:

### Pi

```bash
sbx run ./pi \
  --name sbx-pi \
  /Users/user/Dev/project
```

### Pi with the Node.js 24 mixin

`node24/` is a mixin, so add it to a workload such as Pi with `--kit`:

```bash
sbx run ./pi \
  --name sbx-pi-node24 \
  --kit ./node24 \
  /Users/user/Dev/project
```

Replace `/Users/user/Dev/project` with the absolute path to your project. Choose a unique value for `--name` if you run multiple sandboxes. To run Pi without the Node.js mixin, omit `--kit ./node24`. You can also use `.` as the project path to mount your current directory:

```bash
sbx run ./pi --name sbx-pi .
```

### Run directly from GitHub

Docker Sandbox can fetch a kit from a Git repository. Replace `<OWNER>/<REPOSITORY>` with this repository's GitHub location and `<COMMIT>` with a commit SHA (recommended) or tag. `dir` selects the kit directory in the repository:

```bash
sbx run \
  "git+https://github.com/<OWNER>/<REPOSITORY>.git#ref=<COMMIT>&dir=pi" \
  --name sbx-pi-node24 \
  --kit "git+https://github.com/<OWNER>/<REPOSITORY>.git#ref=<COMMIT>&dir=node24" \
  /Users/user/Dev/project
```

This runs the Pi workload with the Node.js 24 mixin from the same GitHub revision. Use a commit SHA to make both kit sources reproducible. Git-based kit sources may be restricted by Docker Sandbox configuration; allow Git sources if your installation blocks them by default. See Docker's [kit source documentation](https://docs.docker.com/ai/sandboxes/customize/use-kits/#choose-a-kit-source).

## Security

- Credentials are managed by Docker Sandbox.
- No API keys or OAuth tokens are stored in this repository.
- Network access is explicitly configured per workload.
