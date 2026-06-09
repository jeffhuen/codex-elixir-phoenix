---
name: upstream-sync
description: "Use when updating this repository from oliver-kriska/claude-elixir-phoenix releases, tags, PRs, or commits; port upstream skills and agents while preserving Codex plugin metadata, hooks, install docs, tests, and cachebuster rules."
---

# Upstream Sync

Use this repo-scoped skill when syncing `jeffhuen/codex-elixir-phoenix` with
upstream `oliver-kriska/claude-elixir-phoenix`.

This is a maintainer workflow for building the Codex port. It is not a skill
shipped inside the `codex-elixir-phoenix` plugin.

## Required Reference

Read `references/conversion-checklist.md` before editing files. Keep it open as
the source of truth for what to merge, what not to touch, and which conversion
gates must pass.

## Workflow

1. Identify the target upstream release, tag, PR, or commit and compare it with
   the last upstream version already ported here.
2. Review the upstream diff by area: skills, agents, hooks, scripts, commands,
   manifests, docs, and tests.
3. Before editing hooks or agents, apply the Codex-vs-Claude translation tables
   in the conversion checklist.
4. Apply upstream `skills/**` and `agents/**` changes using the scoped
   conversion checklist. Preserve `agents/openai.yaml`.
5. Keep hooks as the Codex-owned port. When upstream hooks change, port behavior
   into the existing Codex hook manifest/scripts instead of copying Claude hook
   manifests.
6. Run all checklist validation commands.
7. Bump `plugins/codex-elixir-phoenix/.codex-plugin/plugin.json` with a new
   `+codex.<timestamp>` cachebuster only when packaged plugin files change.
8. Commit in clear stages when the sync is large: upstream content, Codex
   conversion, validation/cachebuster.

## Hard Rules

- Do not blindly merge upstream into `main`.
- Do not copy Claude hook manifests into `plugins/codex-elixir-phoenix/hooks/hooks.json`.
- Do not generate Codex agent TOML for this plugin; plugin-bundled Codex agent
  TOML is not supported here.
- Do not recreate `agent-sources/`; upstream agents live at
  `plugins/codex-elixir-phoenix/agents/*.md`.
- Do not rename the Codex plugin, marketplace, homepage, or repository back to
  upstream Claude values.
- Do not drop Codex compatibility assets: `skills/codex-compat/`,
  `agents/openai.yaml`, README install instructions, tests, or the
  GitHub-backed marketplace layout.
- When upstream changes Claude hooks, agents, subagents, tools, or model
  labels, update both this repo skill and the shipped `codex-compat` skill if
  the translation rules changed.

## Output

Report:

- Upstream source synced from.
- Areas changed.
- Codex conversions performed.
- Validation commands and results.
- Commit SHA and push status, if committed.
