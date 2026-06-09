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

5. Never hand-edit generated `.codex/agents/*.toml`.
6. Generated agent instructions must not contain runtime Claude model labels,
   Anthropic attribution, `permissionMode`, `maxTurns`, or Claude tool
   metadata.

## Hooks

Upstream Claude hook manifests are not Codex hook manifests.

- Keep `plugins/codex-elixir-phoenix/hooks/hooks.json` in Codex format.
- Do not copy unsupported Claude features such as `if` filters, direct
  `Edit(*.ex)` syntax, `async` behavior assumptions, or unsupported event
  names.
- Keep the dispatcher/root-resolution pattern in `hooks/hooks.json`.
- Hook commands must tolerate missing plugin roots and missing scripts without
  exiting with code 127.
- Hook scripts may accept `PLUGIN_ROOT`, `CODEX_PLUGIN_ROOT`, and compatibility
  `CLAUDE_PLUGIN_ROOT`, but must not require Claude-only variables.
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
