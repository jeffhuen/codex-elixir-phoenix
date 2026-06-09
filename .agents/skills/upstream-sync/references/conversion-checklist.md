# Upstream Conversion Checklist

Use this checklist when merging updates from
`oliver-kriska/claude-elixir-phoenix` into this Codex port.

## Diff Strategy

Do not blindly merge upstream. Treat upstream as source material and port by
area.

1. Fetch or inspect the upstream release/tag/PR/commit.
2. Compare the last ported upstream version to the new upstream target.
3. Group changes by area:
   - Skills and references
   - Agents
   - Hooks and hook scripts
   - Commands or slash-command docs
   - Manifests and marketplace metadata
   - Tests and support scripts
   - README or release notes
4. Apply changes selectively, then run the conversion and validation gates below.

## Merge

Merge these when applicable:

- `plugins/codex-elixir-phoenix/skills/**` content, references, scripts, and
  tests that still apply to Elixir/Phoenix/Ash/Oban workflows.
- `plugins/codex-elixir-phoenix/agents/*.md` as upstream source files for
  specialist behavior.
- `plugins/codex-elixir-phoenix/hooks/scripts/**` behavior after checking it
  still works with Codex hook payloads and environment variables.
- New upstream test fixtures or smoke tests if they remain useful in this repo.
- Release-note features such as Ash skills, filters, freeze behavior, or
  specialist checklists, after translating Claude-specific surfaces.

## Do Not Touch Blindly

Do not overwrite these Codex-owned surfaces without an explicit reason:

- `plugins/codex-elixir-phoenix/.codex-plugin/plugin.json`
- `.agents/plugins/marketplace.json`
- `README.md` install commands for `jeffhuen/codex-elixir-phoenix`
- `plugins/codex-elixir-phoenix/skills/codex-compat/**`
- `plugins/codex-elixir-phoenix/tools/generate-codex-agents.mjs`
- `plugins/codex-elixir-phoenix/tools/install-codex-agents.sh`
- `plugins/codex-elixir-phoenix/.codex/agents/*.toml` by hand
- `plugins/codex-elixir-phoenix/hooks/hooks.json`

Do not restore upstream-only identifiers such as Claude slash-command
requirements, Claude model names, Anthropic SDK/package requirements, or
upstream repository install URLs as Codex runtime instructions.

## Codex Vs Claude Translation

Use this table before porting any upstream hook, agent, subagent, model, or
tooling change.

| Upstream Claude concept | Codex port rule |
|-------------------------|-----------------|
| Slash command file | Convert to a Codex plugin skill or skill instruction. Do not ship Claude slash-command runtime assumptions. |
| Claude `Task` tool | Treat as Codex subagent delegation only when the current run explicitly authorizes subagents; otherwise run the track inline. |
| Claude named agent Markdown | Keep as source in `agents/*.md`, then generate Codex custom-agent TOML with `tools/generate-codex-agents.mjs`. |
| Claude `Agent(subagent_type: "...")` examples | Treat as pseudocode. Use Codex named custom agents directly, or built-in `worker` / `explorer` fallback. |
| Claude namespaces such as `elixir-phoenix:security-analyzer` | Drop the namespace in Codex custom-agent names. |
| Claude model labels | Never ship as runtime model config. Convert through the model table below. |
| `tools`, `disallowedTools`, `permissionMode`, `maxTurns`, `omitClaudeMd` | Do not put these in Codex TOML. Translate intent into instructions, `sandbox_mode`, or omit. |
| Claude hook `if` filters | Codex uses event `matcher` regex plus script-level gates. |
| Claude `PostToolUseFailure` or `StopFailure` | Codex has no direct event for these names. Model with supported events plus payload/status checks, or omit. |
| Claude async hook command | Codex parses `async` but skips async command hooks today. Use synchronous command hooks only. |
| Claude prompt/agent hook handlers | Codex currently runs command handlers; prompt/agent handlers are parsed but skipped. |

## Model Mapping

Codex custom agents use `model` and `model_reasoning_effort`; Claude family
labels do not belong in generated TOML or runtime instructions.

| Upstream intent | Codex model fields |
|-----------------|--------------------|
| Strong/default specialist | `model = "gpt-5.5"`, `model_reasoning_effort = "medium"` |
| Security, deep review, orchestrator, high-risk design | `model = "gpt-5.5"`, `model_reasoning_effort = "xhigh"` |
| Fast/read-heavy/lightweight helper | `model = "gpt-5.4-mini"`, usually `model_reasoning_effort = "medium"` or `"low"` |
| Explicit GPT-5.4 workflow pin | `model = "gpt-5.4"` only when preserving an intentional Codex-side pin |

Update `plugins/codex-elixir-phoenix/tools/generate-codex-agents.mjs` when a
new upstream model label appears. Then regenerate and run
`tests/codex-agents_test.sh`.

## Skills

- Keep each plugin `SKILL.md` frontmatter with `name` and a concise
  trigger-focused `description`.
- Convert literal upstream slash commands like `/phx:review` to Codex skill
  references such as `$phx-review` where the text is user-facing.
- It is acceptable for plugin references to mention `.claude/` working
  directories because this port preserves upstream project artifact conventions.
- If upstream adds a new command, prefer creating or updating a Codex plugin skill
  rather than copying slash-command files.
- Keep `plugins/codex-elixir-phoenix/skills/codex-compat/SKILL.md` current when
  new upstream terminology needs Codex mapping.

## Agents

Upstream agents are Claude Markdown sources. Codex custom agents are TOML files.

1. Merge upstream agent changes into `plugins/codex-elixir-phoenix/agents/*.md`.
2. Preserve useful specialist body instructions.
3. Map Claude model labels through
   `plugins/codex-elixir-phoenix/tools/generate-codex-agents.mjs`:
   - high-capability Claude labels -> `gpt-5.5`
   - lightweight Claude labels -> `gpt-5.4-mini`
   - high-risk/security/orchestrator agents -> `model_reasoning_effort = "xhigh"`
   - normal specialists -> `model_reasoning_effort = "medium"`
4. Run:

```bash
node plugins/codex-elixir-phoenix/tools/generate-codex-agents.mjs
```

5. Codex custom agent TOML requires `name`, `description`, and
   `developer_instructions`. Optional Codex fields include `model`,
   `model_reasoning_effort`, `sandbox_mode`, `mcp_servers`, and
   `skills.config`.
6. Plugin install packages `.codex/agents/*.toml`, but Codex discovers named
   custom agents from project `.codex/agents/` or personal `~/.codex/agents/`.
   Keep `$phx-init` and `tools/install-codex-agents.sh` responsible for
   installing project-scoped copies.
7. Never hand-edit generated `.codex/agents/*.toml`.
8. Generated agent instructions must not contain runtime Claude model labels,
   Anthropic attribution, `permissionMode`, `maxTurns`, or Claude tool
   metadata.

## Hooks

Upstream Claude hook manifests are not Codex hook manifests.

- Keep `plugins/codex-elixir-phoenix/hooks/hooks.json` in Codex format:
  `{"hooks": {"Event": [{"matcher": "...", "hooks": [{"type": "command", ...}]}]}}`.
- Supported useful Codex events include `SessionStart`, `PreToolUse`,
  `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`,
  `UserPromptSubmit`, `SubagentStart`, `SubagentStop`, and `Stop`.
- Matchers are regex strings over the event's supported value. For tool events,
  use tool names such as `Bash`, `apply_patch`, `Edit|Write`, or MCP tool
  names. For compaction use `manual|auto`; for `SessionStart` use
  `startup|resume|clear|compact`.
- `Stop` and `UserPromptSubmit` do not support matcher filtering; Codex ignores
  a configured matcher there.
- Do not copy unsupported Claude features such as `if` filters, direct
  `Edit(*.ex)` syntax, `async` behavior assumptions, prompt/agent handlers, or
  unsupported event names.
- Keep the dispatcher/root-resolution pattern in `hooks/hooks.json`. Manifest
  commands should stay POSIX-compatible and exec `hooks/scripts/run-hook.sh`.
- Hook commands must tolerate missing plugin roots and missing scripts without
  exiting with code 127.
- Hook scripts may accept `PLUGIN_ROOT`, `CODEX_PLUGIN_ROOT`, and compatibility
  `CLAUDE_PLUGIN_ROOT`, but must not require Claude-only variables.
- Codex runs multiple matching command hooks concurrently. Do not rely on one
  hook preventing another matching hook from starting.
- Non-managed command hooks require trust review through `/hooks`; changing a
  hook changes its trust hash.
- When upstream adds a hook script, add or adapt the script, then wire it
  through the Codex manifest only if Codex supports the event and matcher.

## Manifests And Marketplace

- Keep plugin name `codex-elixir-phoenix`.
- Keep homepage/repository pointing at
  `https://github.com/jeffhuen/codex-elixir-phoenix`.
- Keep `.agents/plugins/marketplace.json` pointing to
  `./plugins/codex-elixir-phoenix`.
- Bump `.codex-plugin/plugin.json` version with a fresh
  `+codex.<YYYYMMDDHHMMSS>` cachebuster whenever packaged files change.
- Do not add unsupported manifest fields just to mirror upstream.

## Validation

Run these after every upstream sync:

```bash
node plugins/codex-elixir-phoenix/tools/generate-codex-agents.mjs
bash plugins/codex-elixir-phoenix/tests/codex-agents_test.sh
bash plugins/codex-elixir-phoenix/tests/install-codex-agents_test.sh
.agents/skills/upstream-sync/scripts/validate.sh
node -e 'JSON.parse(require("fs").readFileSync("plugins/codex-elixir-phoenix/.codex-plugin/plugin.json","utf8")); JSON.parse(require("fs").readFileSync(".agents/plugins/marketplace.json","utf8")); console.log("json ok")'
find plugins/codex-elixir-phoenix/hooks/scripts -name '*.sh' -type f -exec bash -n {} \;
```

Use `bash -n` for individual hook scripts because several use Bash-only syntax
such as process substitution. Keep `hooks/hooks.json` launcher commands
POSIX-compatible and let `hooks/scripts/run-hook.sh` exec Bash for the actual
script.

Run a fresh install smoke test:

```bash
tmp=$(mktemp -d /private/tmp/codex-plugin-sync-test.XXXXXX)
mkdir -p "$tmp/.codex"
HOME="$tmp" CODEX_HOME="$tmp/.codex" codex plugin marketplace add /path/to/codex-elixir-phoenix
HOME="$tmp" CODEX_HOME="$tmp/.codex" codex plugin add codex-elixir-phoenix@codex-elixir-phoenix
find "$tmp/.codex/plugins/cache" -path '*/.codex/agents/*.toml' -type f | wc -l
```

The expected agent count is currently 25 unless upstream adds or removes
agents and the test is intentionally updated.

## Final Review

Before committing:

- `git diff` should show intentional upstream content changes plus Codex
  conversion changes.
- `rg -ni '@anthropic-ai|anthropic|\b(sonnet|opus|haiku)\b'` should find no
  runtime instructions outside source Markdown or explicit mapping code.
- No generated Codex agent should contain Claude frontmatter keys.
- Hook changes should not introduce `hook exited with code 127` risks.
- Mention any upstream feature intentionally skipped and why.
