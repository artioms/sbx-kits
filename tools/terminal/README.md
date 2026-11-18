# Developer Tools Kit

A reusable Docker Sandbox mixin providing common terminal utilities:

- `less` — interactive pager, including Git log navigation
- `jq` — JSON processing
- `rg` (`ripgrep`) — fast recursive text search
- `fd` — fast file discovery

## Compose

Add the kit alongside a shell workload and any runtime or agent kits that you need:

```bash
sbx run shell \
  --name dev-tools \
  --kit ./tools/terminal \
  --kit ./runtimes/node \
  --kit ./agents/pi \
  .
```

The kit also provides `pager` as a compatible alias for `less`, because Git or the shell environment may invoke the command by that name rather than `less`. It does not change Git configuration or disable paging.

## Compatibility

The current `sbx/shell-docker-image:latest` is Ubuntu 26.04.1 with glibc `2.43-2ubuntu2.7` and `libtinfo.so.6` on both `amd64` and `arm64` (verified from the image package metadata and assembled on arm64). Utilities are built from Ubuntu 22.04 (glibc 2.35) packages for compatibility with older sandboxes. Recursive shared-library dependencies are resolved at build time; missing dependencies fail the build. Non-core dependencies are isolated under `/opt/tools/lib`, while the runtime supplies glibc, the loader, and `libtinfo.so.6`. The build checks required `GLIBC`, `GLIBCXX`, `CXXABI`, and `GCC` symbol versions against the Ubuntu 22.04 ceilings. The kit never bundles or replaces glibc, the loader, or `libtinfo`. Compose it with the standard `sbx/shell` workload.
