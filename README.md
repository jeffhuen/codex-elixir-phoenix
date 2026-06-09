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

Upstream Claude agents are preserved under
`plugins/codex-elixir-phoenix/agents/*.md`, with Claude model labels normalized
to OpenAI model names. They are bundled specialist checklists and source
material, not additional Codex plugin skills and not project-scoped custom
agent TOML.

The `agents/openai.yaml` file provides plugin-level metadata for this agents
folder, following the OpenAI plugin examples. When a skill mentions a named
specialist such as `ash-policy-reviewer` or `security-analyzer`, read the
matching `agents/<name>.md` file and run that checklist inline unless Codex
subagent delegation is explicitly available and authorized.

## Upstream Updates

When porting a new upstream release, PR, or commit from
`oliver-kriska/claude-elixir-phoenix`, keep `skills/**` and `agents/**`
structurally close to upstream, preserve this repo's `.codex-plugin/` and
Codex hook implementation, and translate Claude-specific model and runtime
language in scoped passes.
