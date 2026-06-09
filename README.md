# Codex Elixir Phoenix

Codex-compatible Elixir/Phoenix/LiveView plugin with skills, lifecycle hooks,
Tidewave guidance, Ecto, Ash, Oban, and OTP workflows.

## Install

Add this repository as a Codex marketplace source, then install the plugin from
that marketplace:

```bash
codex plugin marketplace add jeffhuen/codex-elixir-phoenix --ref main
codex plugin add codex-elixir-phoenix@codex-elixir-phoenix
```

After install, start a new Codex session. If Codex reports new hook definitions,
review and trust them with `/hooks`.

## Subagents

Codex subagents are the Codex-native equivalent of the upstream Claude agents.
This plugin keeps upstream `agents/*.md` as source material and generates Codex
custom-agent TOML files under `plugins/codex-elixir-phoenix/.codex/agents/`.

Codex discovers named custom agents from a project `.codex/agents/` directory,
so run `$phx-init` inside each Elixir/Phoenix project after installing the
plugin. It runs the bundled installer to refresh generated agents without
overwriting user-owned agent files.

The installer can also be run directly from this repo:

```bash
plugins/codex-elixir-phoenix/tools/install-codex-agents.sh /path/to/elixir-project
```

Regenerate and validate the packaged agents after upstream updates:

```bash
node plugins/codex-elixir-phoenix/tools/generate-codex-agents.mjs
bash plugins/codex-elixir-phoenix/tests/codex-agents_test.sh
bash plugins/codex-elixir-phoenix/tests/install-codex-agents_test.sh
```

## Upstream Updates

This repo includes a maintainer-only `$upstream-sync` skill under
`.agents/skills/upstream-sync`. Use it when porting a new upstream release, PR,
or commit from `oliver-kriska/claude-elixir-phoenix`.
