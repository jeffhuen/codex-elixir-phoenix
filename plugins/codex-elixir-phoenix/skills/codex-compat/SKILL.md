---
name: codex-elixir-phoenix
description: "Use when working with this Elixir/Phoenix plugin in Codex, especially when older instructions mention slash commands, Claude tool names, subagents, or CLAUDE_* variables."
---


# Codex Compatibility Notes

This plugin is a Codex-compatible port of the Claude Elixir/Phoenix plugin.
Some reference files may still use upstream terminology. When following those
instructions in Codex, apply these mappings.

## Invocation

- Treat `/phx:<name>` references as references to the matching installed
  `$phx-<name>` skill. For example, `$phx-review` maps to `$phx-review`.
- Treat `$ecto-n1-check` as `$ecto-n1-check` and `$lv-assigns` as
  `$lv-assigns`.
- Treat chained workflow suggestions such as `$phx-plan -> $phx-work` as
  skill-to-skill workflow guidance, not literal Codex slash commands.
- If the user explicitly types an upstream slash command in Codex, route it to
  the matching skill instead of saying the command is unavailable.

## Tool Names

- `Read`, `Grep`, and `Glob` mean inspect files with Codex shell tools such as
  `sed`, `rg`, `find`, and `rg --files`.
- `Edit` and `Write` mean use Codex file editing, preferably `apply_patch` for
  manual edits.
- `Bash` means use the Codex shell command tool.
- `available web/documentation tool` and `web search` mean use the available
  official web/search tools only when current external facts are required.
- `Task` or named Claude agents mean delegate only if Codex subagents are
  available and the user/task explicitly authorizes delegation; otherwise
  execute the workflow inline and preserve the same review/checklist intent.
- `ask the user directly` means ask the user directly in Codex when a real decision
  gate remains.

## Subagents And Custom Agents

- Codex subagents are the equivalent of upstream Claude agents.
- Upstream `agents/*.md` files are source material. Generated Codex custom
  agents live under this plugin at `.codex/agents/*.toml`.
- Codex discovers custom agents from the current project `.codex/agents/` or
  personal `~/.codex/agents/`. A plugin install does not, by itself, make
  plugin-bundled agent files discoverable as named custom agents.
- Run `$phx-init` in each Elixir/Phoenix project to install or refresh the
  generated project-scoped custom agents.
- Use Codex agent names directly, for example `ash-resource-designer` or
  `security-analyzer`. Do not use Claude namespaces such as
  `elixir-phoenix:security-analyzer`.
- If named custom agents are unavailable, delegate to built-in Codex
  `worker` / `explorer` subagents with the same checklist, or run the track
  inline when delegation is unavailable or unauthorized.

## Paths And Environment

- `<skill-dir>` means the current skill directory. Resolve referenced
  `references/`, `scripts/`, or other relative files from the directory that
  contains that skill's `SKILL.md`.
- `.claude/` paths are preserved as the upstream plugin's working convention.
  Do not move them to `.codex/` unless the user asks for a native rewrite.
- Hook scripts can use `PLUGIN_ROOT`/`CODEX_PLUGIN_ROOT` and `PLUGIN_DATA`;
  Codex also provides `CLAUDE_PLUGIN_ROOT` and `CLAUDE_PLUGIN_DATA` for
  compatibility.

## Hooks

- Codex hook `if` filters such as `Edit(*.ex)` and `Bash(*mix*)` are not a
  Codex hook manifest feature. In this port, the Codex manifest uses supported
  tool/event matchers and the dispatcher scripts apply the upstream file,
  command, and project gates internally.
- Codex `PostToolUseFailure` behavior is mapped to Codex `PostToolUse` for
  `Bash`; the dispatcher checks the tool response for a failed exit/status
  before invoking the upstream failure-hint scripts.
- Codex `async` hook handlers are run synchronously when their behavior should
  still exist in Codex, because Codex currently parses but skips async command
  hooks.
- Codex `StopFailure` has no direct Codex event equivalent. Do not add an
  unsupported event name to `hooks/hooks.json`; preserve normal `Stop` behavior
  and only add a best-effort failure shim if Codex exposes a failure signal in
  the hook payload.

## Execution Discipline

- Follow the repo's local instructions first, then the selected plugin skill.
- Prefer focused verification commands (`mix format --check-formatted`,
  `mix compile --warnings-as-errors`, focused `mix test`) before claiming a
  Phoenix change is complete.
- When a skill asks for parallel specialists and subagents are unavailable, run
  the same review dimensions sequentially and label the limitation.
