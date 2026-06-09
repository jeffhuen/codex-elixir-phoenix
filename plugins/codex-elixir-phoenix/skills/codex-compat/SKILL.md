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
- Codex only spawns subagents when explicitly asked or when the selected skill
  says delegation is authorized for the task. Otherwise run the same specialist
  track inline.
- Upstream `agents/*.md` files are source material. Generated Codex custom
  agents live under this plugin at `.codex/agents/*.toml`.
- Claude `Agent(...)` examples are pseudocode in Codex. Use available named
  Codex custom agents directly, or built-in `worker` / `explorer` subagents.
- Codex discovers custom agents from the current project `.codex/agents/` or
  personal `~/.codex/agents/`. A plugin install does not, by itself, make
  plugin-bundled agent files discoverable as named custom agents.
- Run `$phx-init` in each Elixir/Phoenix project to install or refresh the
  generated project-scoped custom agents.
- Use Codex agent names directly, for example `ash-resource-designer` or
  `security-analyzer`. Do not use Claude namespaces such as
  `elixir-phoenix:security-analyzer`.
- Codex custom agents are TOML and require `name`, `description`, and
  `developer_instructions`. Optional model control uses `model` and
  `model_reasoning_effort`, not Claude model family labels.
- Model guidance for this port: demanding specialists use `gpt-5.5`; fast
  read-heavy helpers may use `gpt-5.4-mini`; high-risk security/review or
  orchestration can use `model_reasoning_effort = "xhigh"`.
- Ignore upstream `tools`, `disallowedTools`, `permissionMode`, `maxTurns`, and
  `omitClaudeMd` as config fields. Translate their intent into normal Codex
  instructions or sandbox settings when needed.
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

- Codex hook manifests are event -> matcher group -> command handlers. Keep
  `hooks/hooks.json` in Codex format with `matcher`, `hooks`, `type:
  "command"`, `command`, optional `timeout`, and optional `statusMessage`.
- Codex hook `if` filters such as `Edit(*.ex)` and `Bash(*mix*)` are not a
  Codex hook manifest feature. Use supported event matchers and put file,
  command, and project gates inside dispatcher scripts.
- For tool events, match tool names such as `Bash`, `apply_patch`,
  `Edit|Write`, or MCP tool names. `PreCompact` / `PostCompact` match
  `manual|auto`; `SessionStart` matches `startup|resume|clear|compact`.
- `Stop` and `UserPromptSubmit` do not support matcher filtering.
- Codex `PostToolUseFailure` behavior is mapped to Codex `PostToolUse` for
  `Bash`; the dispatcher checks the tool response for a failed exit/status
  before invoking the upstream failure-hint scripts.
- Codex `async` hook handlers are run synchronously when their behavior should
  still exist in Codex, because Codex currently parses but skips async command
  hooks.
- Codex currently runs command hook handlers. Prompt/agent hook handlers are
  parsed but skipped.
- Codex `StopFailure` has no direct Codex event equivalent. Do not add an
  unsupported event name to `hooks/hooks.json`; preserve normal `Stop` behavior
  and only add a best-effort failure shim if Codex exposes a failure signal in
  the hook payload.
- Plugin hook command strings should remain POSIX-compatible and resolve
  `PLUGIN_ROOT` / `CODEX_PLUGIN_ROOT` / compatibility `CLAUDE_PLUGIN_ROOT`.
  Missing roots or scripts must exit 0, not 127.
- Codex can run multiple matching hooks concurrently, so do not assume one
  matching hook can block another from starting.
- Non-managed command hooks require `/hooks` trust review. A changed hook
  definition gets a new trust hash.

## Execution Discipline

- Follow the repo's local instructions first, then the selected plugin skill.
- Prefer focused verification commands (`mix format --check-formatted`,
  `mix compile --warnings-as-errors`, focused `mix test`) before claiming a
  Phoenix change is complete.
- When a skill asks for parallel specialists and subagents are unavailable, run
  the same review dimensions sequentially and label the limitation.
