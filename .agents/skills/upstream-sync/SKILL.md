---
name: upstream-sync
description: "Use when updating this repository from oliver-kriska/claude-elixir-phoenix releases, tags, PRs, or commits; merge upstream Claude changes while preserving this Codex port's plugin names, hooks, skills, generated custom agents, install docs, tests, and cachebuster rules."
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
3. Apply upstream changes selectively using the conversion checklist.
4. Regenerate generated Codex artifacts, especially `.codex/agents/*.toml`.
5. Run all checklist validation commands.
6. Bump `plugins/codex-elixir-phoenix/.codex-plugin/plugin.json` with a new
   `+codex.<timestamp>` cachebuster only when packaged plugin files change.
7. Commit in clear stages when the sync is large: upstream content, Codex
   conversion, validation/cachebuster.

## Hard Rules

- Do not blindly merge upstream into `main`.
- Do not copy Claude hook manifests into `plugins/codex-elixir-phoenix/hooks/hooks.json`.
- Do not hand-edit generated `.codex/agents/*.toml`; edit `agents/*.md` and
  run the generator.
- Do not rename the Codex plugin, marketplace, homepage, or repository back to
  upstream Claude values.
- Do not drop Codex compatibility assets: `skills/codex-compat/`,
  `tools/generate-codex-agents.mjs`, `tools/install-codex-agents.sh`, tests,
  README install instructions, or the GitHub-backed marketplace layout.

## Output

Report:

- Upstream source synced from.
- Areas changed.
- Codex conversions performed.
- Validation commands and results.
- Commit SHA and push status, if committed.
