# Review Track Selection Reference

Detailed tables and prompt templates for review specialists.
Referenced by `$phx-review` Step 2.

## Delegation Rule

Use these as independent review tracks. Delegate a track only when Codex
subagents are available in the current environment and the user/task has
authorized delegation. Otherwise run the selected tracks inline, sequentially.

## Track Selection Table

| Track | When to run |
|-------|-------------|
| Elixir Reviewer | **Always** |
| Iron Law Judge | Only if >200 lines changed AND auth/LiveView/Oban files in diff. Skip if hooks already verified all changed files |
| Verification Runner | Only if `mix test` has NOT been run in this session. Skip if `$phx-work` just passed all verification tiers |
| Security Analyzer | Auth/session/password/token files changed |
| Testing Reviewer | Test files changed OR new public functions |
| Oban Specialist | Worker files changed (`*_worker.ex`) |
| Deploy Validator | Dockerfile/fly.toml/runtime.exs changed |
| Requirements Verifier | Task ID detected OR plan/spec path passed. Skip on `--no-requirements` |

Run at least 1 track and at most 5 tracks. For <200 lines changed, run only
Elixir Reviewer plus Security Analyzer if auth/security files changed.

## Output File Mapping

Every delegated track prompt, or inline track note, should include an explicit
`output_file` path.

| Track | output_file |
|-------|-------------|
| elixir-reviewer | `.claude/plans/{slug}/reviews/elixir.md` |
| testing-reviewer | `.claude/plans/{slug}/reviews/testing.md` |
| iron-law-judge | `.claude/plans/{slug}/reviews/iron-laws.md` |
| security-analyzer | `.claude/plans/{slug}/reviews/security.md` |
| oban-specialist | `.claude/plans/{slug}/reviews/oban.md` |
| deployment-validator | `.claude/plans/{slug}/reviews/deploy.md` |
| verification-runner | `.claude/plans/{slug}/reviews/verification.md` |
| requirements-verifier | `.claude/plans/{slug}/reviews/requirements.md` |

## Standard Prompt Block

Include this instruction block in every delegated prompt or inline review note:

```
output_file: .claude/plans/{slug}/reviews/{agent}.md

CRITICAL: Write your findings to the output_file above. By turn ~12 at the
latest, write whatever you have — partial is better than nothing
if you hit the turn limit. Continue analyzing and Write again to overwrite
with the full version. Your chat response body must be ≤300 words — the
file IS the real output.
```

## Focused Review Mode

When the user passes a focus argument, run only the specified track:

| Argument | Track |
|----------|---------------|
| `test` | Testing Reviewer |
| `security` | Security Analyzer |
| `oban` | Oban Specialist |
| `deploy` | Deploy Validator |
| `iron-laws` | Iron Law Judge |

Zero tracks run = skill failure.
