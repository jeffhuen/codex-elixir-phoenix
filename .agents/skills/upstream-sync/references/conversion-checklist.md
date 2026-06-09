# Upstream Conversion Checklist

Use this checklist when merging updates from
`oliver-kriska/claude-elixir-phoenix` into this Codex port.

## Diff Strategy

Do not blindly merge upstream. Treat upstream as source material and port by
surface.

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
4. Apply the scoped conversion rules below, then run validation.

## Merge

Merge these when applicable:

- `plugins/elixir-phoenix/skills/**` into
  `plugins/codex-elixir-phoenix/skills/**`, after applying Codex skill
  transforms.
- `plugins/elixir-phoenix/agents/*.md` into
  `plugins/codex-elixir-phoenix/agents/*.md`, after applying model transforms.
- Upstream hook script behavior only after checking it still works with Codex
  hook payloads and environment variables.
- New upstream test fixtures or smoke tests if they remain useful in this repo.
- Release-note features such as Ash skills, filters, freeze behavior, or
  specialist checklists, after translating Claude-specific surfaces.

## Do Not Touch Blindly

Do not overwrite these Codex-owned surfaces without an explicit reason:

- `plugins/codex-elixir-phoenix/.codex-plugin/plugin.json`
- `.agents/plugins/marketplace.json`
- `README.md` install commands for `jeffhuen/codex-elixir-phoenix`
- `plugins/codex-elixir-phoenix/agents/openai.yaml`
- `plugins/codex-elixir-phoenix/skills/codex-compat/**`
- `plugins/codex-elixir-phoenix/hooks/hooks.json`

Do not restore upstream-only package metadata or runtime assumptions:

- `plugins/codex-elixir-phoenix/.claude-plugin/**`
- `plugins/codex-elixir-phoenix/agent-sources/**`
- generated Codex agent TOML
- agent TOML generator or installer scripts
- Claude slash-command runtime assumptions
- Claude model family labels
- Anthropic SDK/package requirements
- upstream repository install URLs

## Codex Vs Claude Translation

Use this table before porting any upstream hook, agent, subagent, model, or
tooling change.

| Upstream Claude concept | Codex port rule |
|-------------------------|-----------------|
| Slash command file | Convert to a Codex plugin skill or skill instruction. Do not ship Claude slash-command runtime assumptions. |
| Slash command invocation such as `/phx:review` | Convert user-facing text to `$phx-review`. |
| `${CLAUDE_SKILL_DIR}` | Convert to `<skill-dir>` in skill instructions. |
| `CLAUDE.md` project install target | Convert runtime install guidance to `AGENTS.md`; preserve `.claude/` artifact directories when they are normal workflow output paths. |
| Claude `Task` tool | Treat as Codex subagent delegation only when the current run explicitly authorizes subagents; otherwise run the track inline. |
| Claude named agent Markdown | Keep as source in `agents/*.md` with normalized model metadata. Do not expose upstream Claude agents as Codex skills and do not generate Codex agent TOML. |
| Claude `Agent(subagent_type: "...")` examples | Treat as pseudocode. Read `agents/<name>.md` and run that checklist inline, or delegate to built-in `worker` / `explorer` only when delegation is explicitly authorized. |
| Claude namespaces such as `elixir-phoenix:security-analyzer` | Drop the namespace in Codex instructions; refer to `security-analyzer` and the matching `agents/security-analyzer.md` checklist. |
| Claude model labels | Never ship `sonnet`, `haiku`, or `opus`; convert through the model table below. |
| `tools`, `disallowedTools`, `permissionMode`, `maxTurns` | These may remain as upstream source metadata in `agents/*.md`; do not treat them as Codex runtime config. |
| `omitClaudeMd` | Drop this Claude-only field from Codex agent Markdown. Do not rename it to `omitAgentsMd`; that field is not documented for Codex plugin-level agents. |
| Claude hook `if` filters | Codex uses event `matcher` regex plus script-level gates. |
| Claude `PostToolUseFailure` or `StopFailure` | Codex has no direct event for these names. Model with supported events plus payload/status checks, or omit. |
| Claude async hook command | Codex parses `async` but skips async command hooks today. Use synchronous command hooks only. |
| Claude prompt/agent hook handlers | Codex currently runs command handlers; prompt/agent handlers are parsed but skipped. |

## Model Mapping

Normalize model labels in `plugins/codex-elixir-phoenix/agents/*.md` and any
user-facing skill/reference text.

| Upstream label or intent | Codex fields |
|--------------------------|--------------|
| `model: sonnet` | `model: gpt-5.5`, `effort: medium` |
| `model: haiku` | `model: gpt-5.5`, `effort: medium` |
| `model: opus` | `model: gpt-5.5`; preserve upstream `effort: high` for high-risk/review/orchestration agents unless the port has a reason to lower it |
| Body text mentioning `sonnet`, `haiku`, or `opus` | Rewrite to explicit `gpt-5.5` wording, for example `` `gpt-5.5` medium `` |

## Skills

- Keep each plugin `SKILL.md` frontmatter with `name` and a concise
  trigger-focused `description`.
- Convert literal upstream slash commands like `/phx:review` to Codex skill
  references such as `$phx-review` where the text is user-facing.
- Convert `${CLAUDE_SKILL_DIR}` to `<skill-dir>`.
- Convert `CLAUDE.md` project installation instructions to `AGENTS.md`.
- Keep `.claude/` artifact paths when they are workflow output directories
  such as plans, reviews, or audit reports.
- Convert named-agent instructions to "read `agents/<name>.md` and run that
  checklist inline or with authorized Codex subagents."
- Keep `plugins/codex-elixir-phoenix/skills/codex-compat/SKILL.md` current when
  new upstream terminology needs Codex mapping.

## Agents

Upstream agents are Claude Markdown sources stored under `agents/`. In this
Codex port they remain under `plugins/codex-elixir-phoenix/agents/*.md` as
bundled specialist checklists and source material.

They must not be converted into `skills/` entries, and they must not be
converted into plugin-bundled Codex agent TOML.

1. Replace or merge upstream agent changes from
   `plugins/elixir-phoenix/agents/*.md` into
   `plugins/codex-elixir-phoenix/agents/*.md`.
2. Preserve useful specialist body instructions.
3. Normalize model labels:
   - `model: sonnet` -> `model: gpt-5.5`, `effort: medium`
   - `model: haiku` -> `model: gpt-5.5`, `effort: medium`
   - `model: opus` -> `model: gpt-5.5`; usually keep `effort: high`
4. Rewrite body mentions of Claude model family names to explicit `gpt-5.5`
   wording.
5. Drop `omitClaudeMd` from frontmatter instead of renaming it to
   `omitAgentsMd`.
6. Keep `plugins/codex-elixir-phoenix/agents/openai.yaml` present with
   plugin-level interface metadata for the agents folder.
7. Preserve upstream source metadata such as `tools`, `disallowedTools`,
   `permissionMode`, and `maxTurns` as non-runtime source metadata unless it
   causes Codex validation issues.

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
- Do not keep `.claude-plugin/` inside the packaged Codex plugin.

## Validation

Run these after every upstream sync:

```bash
python3 /Users/jeffhuen/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/codex-elixir-phoenix
node -e 'JSON.parse(require("fs").readFileSync("plugins/codex-elixir-phoenix/.codex-plugin/plugin.json","utf8")); JSON.parse(require("fs").readFileSync(".agents/plugins/marketplace.json","utf8")); console.log("json ok")'
find plugins/codex-elixir-phoenix/hooks/scripts -name '*.sh' -type f -exec bash -n {} \;
bash plugins/codex-elixir-phoenix/hooks/tests/block-dangerous-ops_test.sh
.agents/skills/upstream-sync/scripts/validate.sh
```

Run count and stale-reference checks:

```bash
find plugins/codex-elixir-phoenix/skills -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l
find plugins/codex-elixir-phoenix/agents -maxdepth 1 -name '*.md' | wc -l
test -f plugins/codex-elixir-phoenix/agents/openai.yaml
test ! -d plugins/codex-elixir-phoenix/agent-sources
test ! -d plugins/codex-elixir-phoenix/.claude-plugin
rg -n '\b(sonnet|haiku|opus)\b|agent-sources|generate-.+agents|install-.+agents|agents-only|generated Codex agent' README.md plugins/codex-elixir-phoenix
```

Current expected counts are 48 plugin skills and 25 bundled agent Markdown
files unless upstream intentionally adds or removes entries.

Run a fresh install smoke test when package layout changes:

```bash
tmp=$(mktemp -d /private/tmp/codex-plugin-sync-test.XXXXXX)
mkdir -p "$tmp/.codex"
HOME="$tmp" CODEX_HOME="$tmp/.codex" codex plugin marketplace add /path/to/codex-elixir-phoenix
HOME="$tmp" CODEX_HOME="$tmp/.codex" codex plugin add codex-elixir-phoenix@codex-elixir-phoenix
find "$tmp/.codex/plugins/cache" -path '*/agents/*.md' -type f | wc -l
find "$tmp/.codex/plugins/cache" -path '*/skills/*/SKILL.md' -type f | wc -l
```

Use `bash -n` for individual hook scripts because several use Bash-only syntax
such as process substitution. Keep `hooks/hooks.json` launcher commands
POSIX-compatible and let `hooks/scripts/run-hook.sh` exec Bash for the actual
script.

## Final Review

Before committing:

- `git diff` should show intentional upstream content changes plus Codex
  conversion changes.
- No packaged Codex runtime instructions should contain Claude model family
  labels.
- No generated Codex agent TOML path or generator should be present.
- Hook changes should not introduce `hook exited with code 127` risks.
- Mention any upstream feature intentionally skipped and why.
