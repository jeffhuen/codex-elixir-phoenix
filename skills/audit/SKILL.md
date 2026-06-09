---
name: phx-audit
description: "Use when assessing Elixir/Phoenix project health, architecture, performance, tests, dependencies, or code quality before releases or after refactors."
---


# Project Health Audit

Comprehensive project-wide health assessment across five review tracks.

## Usage

```
$phx-audit              # Full audit (default)
$phx-audit --quick      # 2-3 minute pulse check
$phx-audit --focus=security   # Deep dive single area
$phx-audit --focus=performance
$phx-audit --since abc123   # Incremental audit since commit
$phx-audit --since HEAD~10  # Audit last 10 commits
```

## When to Use

- **Quarterly** health checks
- **Before major releases**
- **After large refactors**
- **New team member onboarding** (understand codebase health)

## Iron Laws

1. **Wait for ALL review tracks before synthesizing** — Partial results create misleading health scores because cross-category correlations get missed
2. **Scope each review track to specific directories** — Vague prompts like "analyze the codebase" produce generic findings that waste tokens and miss real issues
3. **Never compare scores across projects** — Scoring methodology depends on project size and maturity; only track trends within the same project
4. **Quick mode before full mode** — Run `--quick` first to catch compile/test failures before spending tokens on five full review tracks

## Specialist Routing

Run five review tracks. If Codex subagent tools are available and the user/task
explicitly authorizes delegation, run independent tracks in parallel. When the
current Codex surface exposes named custom agents, use the preferred routes
below. Otherwise use focused generic subagents, or run the same tracks
sequentially and label the limitation in the report.

| Track | Focus | Output File | Preferred Route |
|-------|-------|-------------|-----------------|
| Architecture | Structure quality, coupling, cohesion | `arch-review.md` | `phoenix-patterns-analyst` (`gpt-5.5` medium) |
| Performance | N+1, indexes, bottlenecks, scalability | `perf-audit.md` | `general-purpose` (no plugin specialist yet) |
| Security | OWASP scan, auth patterns, secrets | `security-audit.md` | `security-analyzer` (`gpt-5.5` xhigh) |
| Test Health | Coverage, quality, flaky tests | `test-audit.md` | `testing-reviewer` (`gpt-5.5` medium) |
| Dependencies | Vulnerabilities, outdated, unused | `deps-audit.md` | `general-purpose` (per-package `hex-deps-triager` only) |

## Workflow

### Step 1: Create Task List and Run All 5 Auditors

Use Codex plan updates for real-time progress visibility:

```
Create one plan item per audit track.
Mark a track in_progress when it starts.
Mark a track completed when its report is written.
```

For each track, write findings to `.claude/audit/reports/{track}.md`.
Prompt each track with its focus and the relevant directories/files. If using
subagents, make each prompt bounded, give it one output file, and use the
preferred route from the table above when named custom agents are available.

```
Architecture: module structure, context boundaries, coupling, cohesion.
Performance: N+1 queries, missing indexes, bottlenecks, scalability.
Security: OWASP scan, auth patterns, secret leakage.
Tests: coverage, quality, flakes.
Dependencies: vulnerabilities, outdated packages, unused deps.
```

Requested subagent routing when named custom agents are available:

```
phoenix-patterns-analyst -> Architecture audit, arch-review.md
general-purpose          -> Performance audit, perf-audit.md
security-analyzer        -> Security audit, security-audit.md
testing-reviewer         -> Test health audit, test-audit.md
general-purpose          -> Dependency audit, deps-audit.md
```

**Why specialist routing matters**: generic subagents inherit the parent
session model. Codex custom agents can declare their own model and effort, so
routing Architecture and Test Health to `gpt-5.5` medium agents avoids
unnecessary parent-effort subagent volume. Security intentionally stays on the
`gpt-5.5` xhigh agent. Performance and Dependencies remain generic until this
plugin has project-wide specialists for those tracks.

Prompts must be focused. Scope each prompt to the
relevant directories and patterns. Do NOT give vague prompts
like "analyze the codebase."

**Output efficiency**: Tell each agent: "Report ONLY issues found.
Do NOT list clean checks, passing categories, or 'What's Good'.
One summary line per clean area suffices."

### Step 2: Collect Results

Wait for ALL auditors to complete. Mark each auditor's task as
`completed` via `update_plan` as it finishes. NEVER proceed while
any auditor is still running.

Read reports from `.claude/audit/reports/`.

### Step 3: Compress Findings

After all 5 auditors complete, consolidate findings:

```
Compress audit findings.
Input: .claude/audit/reports/
Output: .claude/audit/summaries/
Priority: Health scores per category, critical findings
only, cross-category correlations, deduplicate findings
found by 2+ tracks.
```

Read `.claude/audit/summaries/consolidated.md` for synthesis.

### Step 4: Calculate Health Score

Each category scores 0-100. See `<skill-dir>/references/scoring-methodology.md`.

### Step 5: Generate Report

Write to `.claude/audit/summaries/project-health-{date}.md`.

## Output Format

Report includes: Executive summary with health score (A-F, numeric/100),
per-category score table (Architecture, Performance, Security, Tests, Dependencies),
critical issues, top recommendations, and action plan (Immediate/Short-term/Long-term).

## Quick Mode (`--quick`)

Only run essential checks (~2-3 minutes):

Run `mix compile --warnings-as-errors`, then `mix hex.audit && mix deps.audit`,
then `mix xref graph --format stats`, then `mix test --trace 2>&1 | tail -20`.

Skip: Full security scan, N+1 analysis, test quality metrics, architecture deep dive.

## Focus Mode (`--focus=area`)

Deep dive single area with full specialist resources:

| Focus | Subagent | Extra Checks |
|-------|----------|--------------|
| `security` | security-analyzer | Full OWASP, sobelow, manual patterns |
| `performance` | default | Profile-level analysis, query explain (no plugin specialist yet) |
| `architecture` | phoenix-patterns-analyst | Full xref, coupling matrix, cohesion |
| `tests` | testing-reviewer | Coverage by context, quality metrics |
| `deps` | default | License audit, maintenance status (per-package `hex-deps-triager` only) |

## Incremental Mode (`--since <commit>`)

Analyze only changes since a specific commit. Useful for pre-merge checks:

Run `git diff --name-only <commit>...HEAD` to identify changed files, then run targeted audits on changed files only (skips full project scan).

Combines with other flags: `$phx-audit --since HEAD~5 --focus=security`

## Relationship to Other Commands

| Command | Scope | Frequency |
|---------|-------|-----------|
| `$phx-review` | Changed files (diff) | Every PR |
| `$phx-audit` | Entire project | Quarterly |
| `$phx-boundaries` | Context structure | On-demand |
| `$phx-verify` | Compile/test pass | Anytime |

## References

- `<skill-dir>/references/scoring-methodology.md` - How scores are calculated
- `<skill-dir>/references/architecture-checks.md` - Detailed architecture criteria
