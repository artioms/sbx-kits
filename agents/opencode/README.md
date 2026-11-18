# OpenCode agent mixin

Installs the [OpenCode](https://opencode.ai/) coding agent CLI and configures its default model for Docker Sandbox shell workloads.

## Usage

```bash
sbx run shell \
  --name sbx-opencode \
  --kit ./agents/opencode \
  --kit ./runtimes/node \
  --kit-arg node.version=24 \
  /Users/user/Dev/project
```

Omit the Node runtime kit if the workload already provides Node.js. Run `opencode` for the interactive interface or `opencode run "Your task"` for a one-shot task.

## Arguments

| Argument | Default | Purpose |
| --- | --- | --- |
| `version` | `1.19.6` | OpenCode npm package version installed at build time |
| `model` | `openai/gpt-5.1` | Default model in `provider/model` form |

The model value is passed to the sandbox lifecycle and written to `~/.config/opencode/opencode.json`. Docker Sandbox manages optional OpenAI and Anthropic credentials; do not add real API keys to the kit or image.

The mixin also makes shared skills available at `~/.agents/skills` and installs its agent instructions at `~/.config/opencode/AGENTS.md`.
