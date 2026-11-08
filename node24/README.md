# Node.js 24 Mixin

Provides the official Node.js 24 Linux binaries, npm, and npx for `amd64` and `arm64` sandbox workloads.

## Runtime requirements

This kit is a **mixin**, not a standalone container image. Its `scratch` final stage contributes the Node.js files and symlinks; it intentionally does not install operating-system runtime packages. The workload it is mixed into must provide the dependencies required by the official Node.js Linux binaries, including glibc, a dynamic loader, CA certificates, and `/usr/bin/env` for npm/npx shebangs. Confirm those dependencies are present in the target workload and smoke-test `node --version`, `npm --version`, and `npx --version` after applying the mixin.

## Updating Node.js

Update `NODE_VERSION` in `spec.dockerfile`, the matching `provides` entry in `spec.yaml`, and both architecture-specific SHA-256 values in the Dockerfile from Node.js' official `SHASUMS256.txt` for that release. The build verifies the downloaded archive before extracting it.
