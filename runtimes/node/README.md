# Node.js LTS Runtime Kit

A Docker Sandbox mixin that contributes the official Node.js runtime, npm, and npx. Choose the Node.js LTS major line with the `version` kit argument. The kit currently supports Node.js 22, 24, and 26.

## Responsibility and dependencies

This kit provides only Node.js runtime files; it does not install an agent or impose a runtime network policy. It can be composed with a shell workload or other kits.

The mixin exports only the files it contributes from a `scratch` stage. The target workload must provide the runtime dependencies required by the official Linux binaries, including glibc, a dynamic loader, CA certificates, and `/usr/bin/env` for npm/npx shebangs. The kit also contributes `libatomic.so.1`, required by the official Node.js 26 binaries.

## Supported versions and architectures

| `version` argument | Pinned patch release |
| --- | --- |
| `22` | Node.js 22.23.5 LTS (Maintenance LTS) |
| `24` | Node.js 24.22.3 LTS (Maintenance LTS) |
| `26` | Node.js 26.13.1 LTS (Active LTS) |

All supported releases provide Linux `amd64` and `arm64` archives. The build verifies the selected archive against its checked-in SHA-256 checksum and fails for unsupported versions or architectures.

The patch releases are deliberately pinned in `spec.dockerfile` for reproducible builds. When a supported LTS line receives a security update, update its pinned patch release and AMD64/ARM64 checksums together, then verify the kit on both architectures.

## Configuration

| Argument | Default | Allowed values | Purpose |
| --- | --- | --- | --- |
| `version` | `24` | `22`, `24`, `26` | Select the Node.js LTS major line |

No credentials are required. Build-time network access is needed to download the Node.js archive from `nodejs.org` and install `curl`, `tar`, `xz-utils`, and `libatomic1` from Debian package repositories. The kit itself adds no runtime network permissions; the composing workload controls runtime network access.

## Usage

From the repository root, run a shell with Node.js 24:

```bash
sbx run shell \
  --name node-dev \
  --kit ./runtimes/node \
  --kit-arg version=24 \
  .
```

Select Node.js 22 or 26 by changing `version=24` to `version=22` or `version=26`. To compose this with another kit, pass another `--kit` argument; kit arguments should be prefixed by kit name if they conflict with arguments from another kit.

For reproducible remote composition, use an immutable repository commit rather than a moving branch reference.

## Verify installation

Inside the sandbox, run:

```bash
node --version
npm --version
npx --version
```

The `node --version` output should match the selected major line and the patch release listed above.
