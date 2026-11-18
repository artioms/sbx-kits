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

The utilities are installed against `sbx/shell-docker-image:latest` and exported with their non-core shared-library dependencies under `/opt/tools/lib`. They use the shell image's system C runtime and dynamic loader; compose the kit with the standard `sbx/shell` workload. The kit follows the shell image's supported target architectures.
