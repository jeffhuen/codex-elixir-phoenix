# Skill Checklist — Codex skill compatibility

Pre-flight for any new skill added to `codex-elixir-phoenix`. Apply this list
before validating or reinstalling the plugin.

## Frontmatter

- Only `name:` and `description:` are supported.
- `name:` uses letters, numbers, and hyphens only. Convert upstream names:
  `phx:deps-audit` -> `phx-deps-audit`, `ecto:n1-check` ->
  `ecto-n1-check`.
- `description:` starts with `Use when...` and describes trigger conditions,
  not workflow steps. Include concrete Elixir/Phoenix terms such as `hex`,
  `mix`, `security`, `ecto`, or `liveview` when relevant.
- Do not use `argument-hint`, `allowed-tools`, `effort`, `paths`, or
  upstream-only fields.

## Headings

- The Iron Laws heading must be literally `## Iron Laws` — no em-dash,
  no parenthetical. The eval scorer's `section_exists` check does a
  literal string match. Variants like `## Iron Laws — Never Violate`
  fail completeness.

## Body

- Keep SKILL.md concise; move heavy detail to `references/`.
- Reference paths use `<skill-dir>/references/<file>.md` when the skill needs
  an absolute skill-root hint. Bare `references/<file>.md` paths assume the
  current working directory and are fragile.
- Iron Laws section: numbered list with concrete prohibitions and a
  one-sentence rationale per law. Aim for 4-6 laws.

## Markdown lint

- Lists need a blank line above and below (MD032).
- No hard tabs in code fences. Use 2-space indent. Even one tab in a
  Makefile snippet trips MD010 and fails CI.
- Code fences must declare a language (` ```bash ` not just ` ``` `).

## Validation

- Run the Codex plugin validator before reinstalling.
- Run a frontmatter check over every `skills/*/SKILL.md`.
- Validate `hooks/hooks.json` with `jq empty`.
- Run `bash -n hooks/scripts/*.sh`.
- Cache-bust and reinstall the personal plugin before testing in a fresh Codex
  session.

## Description keyword reference

The fixed Elixir/Phoenix domain list is in `lab/eval/matchers.py`.
Effective single-word triggers include: `audit`, `security`, `review`,
`hex`, `mix`, `liveview`, `ecto`, `oban`, `phoenix`, `elixir`,
`migration`, `changeset`, `genserver`, `supervisor`, `compile`, `test`,
`debug`, `performance`. Aim for ≥3 of these in the description.

## Quick verification flow

```bash
python3 /Users/jeffhuen/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
jq empty hooks/hooks.json
for f in hooks/scripts/*.sh; do bash -n "$f" || exit 1; done
```
