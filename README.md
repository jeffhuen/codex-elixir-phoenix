# Codex Elixir Phoenix

Codex-compatible Elixir/Phoenix/LiveView plugin with skills, lifecycle hooks,
Tidewave guidance, Ecto, Ash, Oban, and OTP workflows.

## Install

Add this repository as a Codex marketplace source, then install the plugin from
that marketplace:

```bash
codex plugin marketplace add jeffhuen/codex-elixir-phoenix
codex plugin add codex-elixir-phoenix@codex-elixir-phoenix
```

`--ref main` is optional and only needed when pinning a non-default ref during
testing.

After install, start a new Codex session. If Codex reports new hook definitions,
review and trust them with `/hooks`.

## Specialist Agents

Upstream Claude agents are source material in `plugins/codex-elixir-phoenix/agent-sources/*.md`.
For Codex plugin distribution, this repo generates matching skill wrappers under
`plugins/codex-elixir-phoenix/skills/<agent-name>/` with `agents/openai.yaml`
metadata. That makes specialists such as `$ash-resource-designer`,
`$ash-policy-reviewer`, `$security-analyzer`, and `$verification-runner`
available as normal Codex skills after plugin install.

The plugin-level `agents/` directory is intentionally not used for upstream
Claude files. OpenAI plugin examples may use `agents/*-agent.md` for
Codex-native companion prompts, but these upstream source files contain
Claude-only metadata and stay in `agent-sources/` instead.

The repo also generates optional Codex custom-agent TOML files under
`plugins/codex-elixir-phoenix/.codex/agents/`. Codex custom-agent discovery is
project/personal scoped, so run `$phx-init` inside an Elixir/Phoenix project if
you want those copied into `.codex/agents/` without overwriting user-owned agent
files. Use the generated skills as the reliable plugin-distributed route.

The installer can also be run directly from this repo:

```bash
plugins/codex-elixir-phoenix/tools/install-codex-agents.sh /path/to/elixir-project
```

Regenerate and validate the packaged agents after upstream updates:

```bash
node plugins/codex-elixir-phoenix/tools/generate-agent-skills.mjs
node plugins/codex-elixir-phoenix/tools/generate-codex-agents.mjs
bash plugins/codex-elixir-phoenix/tests/agent-skills_test.sh
bash plugins/codex-elixir-phoenix/tests/codex-agents_test.sh
bash plugins/codex-elixir-phoenix/tests/install-codex-agents_test.sh
```

## Upstream Updates

This repo includes a maintainer-only `$upstream-sync` skill under
`.agents/skills/upstream-sync`. Use it when porting a new upstream release, PR,
or commit from `oliver-kriska/claude-elixir-phoenix`.
