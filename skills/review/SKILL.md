---
name: phx-review
description: "Use when reviewing Elixir/Phoenix code after implementation for bugs, tests, security, Ecto, LiveView, Oban, deployment, Iron Laws, or PR readiness."
---


# Review Elixir/Phoenix Code

Review code through focused specialist tracks. Find and explain issues. Do not
fix anything unless the user separately asks for implementation work.

## Usage

```
$phx-review                          # Auto-detects task ID from branch/commits
$phx-review test                     # Review test files only
$phx-review security                 # Run security audit only
$phx-review oban                     # Review Oban workers only
$phx-review deploy                   # Validate deployment config
$phx-review iron-laws                # Check Iron Law violations only
$phx-review ENA-8931                 # Force Linear issue
$phx-review #42                      # Force GitHub issue
$phx-review .claude/plans/auth/plan.md    # Force plan / spec file
$phx-review --no-requirements        # Skip requirements coverage check
```

## Arguments

`$ARGUMENTS` = Focus area, task ID, or path to plan/spec file.

When no requirements argument is passed, the skill auto-detects a task ID
from the current git branch name and recent commits (see
`<skill-dir>/references/requirements-detection.md`).

## Workflow

### Step 1: Identify Changed Files and Prepare Directories

**CRITICAL**: Create output dirs BEFORE spawning agents — delegated tracks cannot
create directories and writes will fail.

1. Determine SLUG via Glob on `.claude/plans/*/` (default: `"review"`)
2. Run `mkdir -p ".claude/plans/${SLUG}/reviews" ".claude/plans/${SLUG}/summaries" .claude/reviews`
3. Run `git diff --name-only HEAD~5` and `git diff --name-only main`
4. Save the diff base for pre-existing detection in Step 3b

### Step 1b: Load Plan Context and Prior Reviews

- Read `.claude/plans/${SLUG}/scratchpad.md` for planning decisions and rationale
- Pass relevant decisions to review tracks as WHY-context (eliminates session archaeology)
- Check `.claude/plans/${SLUG}/reviews/` for prior output; if present, include a
  consolidated summary as "PRIOR FINDINGS" with: "Focus on NEW issues. Mark
  still-present issues as PERSISTENT."

### Step 1c: Detect Requirements Source (skip on `--no-requirements`)

Find a task/spec whose requirements should be cross-checked against the diff.
Priority order (stop at first match): explicit arg → conversation context →
branch regex → commit subjects → latest plan → none. Full table, regexes,
and fetch mapping in `<skill-dir>/references/requirements-detection.md`.

Fetch the detected source into `.claude/plans/${SLUG}/reviews/.requirements-input.md`
(Linear connector when available, GitHub via connector or `gh issue view`,
file requirements by reading the file).
Record `REQ_SOURCE` label (e.g. `"Linear ENA-8931"`) for the verifier heading.
On fetch failure, set `SOURCE_STATUS=FETCH_FAILED` and continue — verifier
will emit `NOT AVAILABLE` rather than block the review.

### Step 2: Run Review Tracks

Run each selected track exactly once. If Codex subagent tools are available and
the user/task explicitly authorizes delegation, run independent tracks in
parallel. Otherwise run the same tracks sequentially inline and state that
subagents were unavailable or not authorized.

1. Create Codex plan items for the selected tracks and mark each one
   `in_progress` / `completed` as work proceeds.
2. For `$phx-review` or `$phx-review all`: select tracks dynamically per the
   selection table in `<skill-dir>/references/agent-spawning.md`
3. For focused reviews (`test|security|oban|deploy|iron-laws`): run only the
   matching track from the focused mode table in the same reference
4. **If Step 1c succeeded** (REQ_SOURCE non-empty and `--no-requirements`
   not passed): add a requirements-verification track. Pass these prompt inputs:
   `REQUIREMENTS_TEXT` (content
   of `.requirements-input.md`), `REQUIREMENTS_SOURCE` (REQ_SOURCE label),
   `DIFF_FILES` (git diff --name-only output), `SOURCE_STATUS` (only if
   FETCH_FAILED), `output_file: .claude/plans/{slug}/reviews/requirements.md`
5. When using subagents, launch the selected independent tracks together. When
   working inline, execute the same track list one by one.
6. **MANDATORY**: assign an explicit `output_file` per track (mapping in the reference)
7. Include the CRITICAL prompt block for delegated tracks: write by turn ~12,
   chat body <=300 words
8. Scope every track to the diff: pass `git diff --name-only` output with
   "Focus on NEW code. Pre-existing: one-line `{file}:{line} — {brief}`. Do
   NOT deep-analyze unchanged files."

### Step 3: Collect and Compress Findings

Wait for ALL tracks to complete. **Do NOT report status until every selected
track completes.** Mark each plan item `completed` as it finishes.

**Missing file fallback** — after each track finishes, verify its expected
`output_file` exists. If missing (turn exhaustion, error):

1. Append to `.claude/plans/{slug}/scratchpad.md`:
   `[HH:MM] WARN: {track} did not write {expected_path} — extracting from message`
2. Parse findings from the track's return message as fallback
3. Mark the section in the final review with
   `⚠️ EXTRACTED FROM AGENT MESSAGE (see scratchpad)` — never silent

**Verification-runner fallback** — if it times out, run directly:
`mix compile --warnings-as-errors && mix format --check-formatted $(git diff --name-only HEAD~5 | grep '\.exs\?$' | tr '\n' ' ') && mix credo --strict && mix test`

**Context supervision** — for 4+ tracks, consolidate output before synthesis:

```
Prompt/focus: "Compress review track output.
  input_dir: .claude/plans/{slug}/reviews
  output_dir: .claude/plans/{slug}/summaries
  output_file: review-consolidated.md
  priority_instructions: BLOCKERs and WARNINGs: KEEP ALL.
    SUGGESTIONs: COMPRESS similar ones into groups.
    Deconfliction: when iron-law-judge and elixir-reviewer
    flag same code, keep iron-law-judge finding."
```

Skip consolidation for focused one-track reviews — read output directly.

### Step 3b: Filter Findings (Anti-Noise)

Before writing the review, apply these overriding filters to each finding:

1. Would a senior Elixir dev dismiss this as noise?
2. Does the finding add complexity exceeding the problem's complexity?
3. Are any findings duplicates reworded by different tracks?
4. Does the finding affect code actually changed in this diff?
5. Is the finding on unchanged code (not in diff)? → Mark PRE-EXISTING

Demote or remove findings that fail filters 1-4. Mark pre-existing per filter 5.

### Step 4: Generate Review Summary

Read consolidated/agent output. Write to `.claude/plans/{slug}/reviews/{feature}-review.md`
with verdict: PASS | PASS WITH WARNINGS | REQUIRES CHANGES | BLOCKED.

**Requirements Coverage in verdict**: if the verifier ran, read its
summary line and fold into the verdict:

- Any `UNMET` → escalate to `REQUIRES CHANGES` (even if code-quality PASS)
- Any `PARTIAL` (no UNMET) → downgrade PASS → `PASS WITH WARNINGS`
- `NOT AVAILABLE` / all `MET` / `UNCLEAR` only → no verdict change

Insert the verifier's `## Requirements Coverage` block into the
review document **before** the per-agent findings so it's the first
thing the user sees.

### Step 5: Present Findings and Ask User

**STOP and present the review.** Do NOT create tasks or fix
anything.

**On BLOCKED or REQUIRES CHANGES**: Show finding count by severity,
then offer via `ask the user directly`: `$phx-triage` (recommended), `$phx-plan`,
fix directly, or "I'll handle it myself".

**On PASS / PASS WITH WARNINGS**: Suggest `$phx-compound`, `$phx-learn-from-fix`.

**Convention extraction**: After presenting findings, offer: "Any findings
to suppress or enforce as conventions?" See `<skill-dir>/references/conventions.md`.

## Iron Laws

1. **Review is READ-ONLY** — Find and explain, never fix
2. **NEVER auto-fix after review** — Always ask the user first
3. **Always offer both paths**: `$phx-plan` and `$phx-work`
4. **Research before claiming** — Agents MUST research before
   making claims about CI/CD or external services

## Integration

`$phx-plan` → `$phx-work` → `$phx-review` (YOU ARE HERE) → Blocked? `$phx-triage` or `$phx-plan` | Pass? `$phx-compound`

See: `<skill-dir>/references/review-template.md`, `<skill-dir>/references/example-review.md`, `<skill-dir>/references/blocker-handling.md`, `<skill-dir>/references/requirements-detection.md`
