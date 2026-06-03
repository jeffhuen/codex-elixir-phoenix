---
name: phx-plan
description: "Use when planning Elixir/Phoenix features across multiple files or domains, converting findings into tasks, or designing interconnected auth, billing, jobs, webhooks, or realtime work."
---


# Plan Elixir/Phoenix Feature

Plan a feature with Elixir/Phoenix-aware research tracks, then output a
structured plan with checkboxes.

## What Makes $phx-plan Different from /plan

1. Uses Elixir specialist research tracks, delegated only when available and authorized
2. Plans with `[ecto]`, `[liveview]`, `[oban]` task routing
3. Checks for Iron Law compliance in the plan
4. Includes `mix compile/format/credo/test` verification
5. Understands Phoenix context boundaries

## Usage

```
$phx-plan Add user avatars with S3 upload
$phx-plan .claude/plans/notifications/reviews/notifications-review.md
$phx-plan Implement notifications --depth deep
$phx-plan .claude/plans/auth/plan.md --existing
```

## Arguments

- `$ARGUMENTS` = Feature description, review file, or existing plan
- `--depth quick|standard|deep` = Planning depth (auto-detected)
- `--existing` = Enhance an existing plan with deeper research

## Workflow

1. **Gather context** — File path (skip to targeted research), brainstorm
   interview.md (skip clarification), clear description, or vague
2. **Clarify if vague** — Ask questions ONE at a time (skip if
   brainstorm interview.md exists with Status: COMPLETE)
3. **Detect depth** — Auto-detect quick/standard/deep
4. **Runtime context** (Tidewave) — Gather live schemas, routes,
   and warnings before research tracks (see `<skill-dir>/references/planning-workflow.md`)
5. **Run research tracks** — Selective, parallel only when Codex subagents are
   available and the user/task explicitly authorizes delegation. Otherwise run
   tracks sequentially inline. Use Codex plan updates for progress visibility.
6. **Wait for ALL tracks** — Do NOT proceed until all selected tracks are
   complete. NEVER write the plan while any track is still running.
7. **Breadboard** (LiveView) — System map for multi-page features
8. **Completeness check** — MANDATORY when planning from review
9. **Split decision** — One plan or multiple, concrete options
10. **Generate plan** — Checkboxes, phased tasks, code patterns.
    Also create `plans/{slug}/scratchpad.md` for decisions and dead-ends
11. **Self-check** (deep only) — Three questions in Risks section
12. **Present and ask** — STOP, show summary, let user decide

**When planning from review**: Every finding must appear in the
plan — either as a task OR explicitly deferred by the user.

See `<skill-dir>/references/planning-workflow.md` for detailed step-by-step.

### --existing Mode (Deepening)

Enhances an existing plan instead of creating a new one:

1. Load plan, search `.claude/solutions/` for known risks
2. Run specialist research tracks for thin sections. Each track writes to
   `.claude/plans/{slug}/research/` and returns only a 500-word summary.
   Delegate only when available and authorized.
3. Wait for ALL tracks (mark plan items `completed` as each finishes)
4. Add implementation detail, resolve spikes, add verification
5. Present diff summary — **NEVER delete existing tasks**

## Iron Laws

1. **NEVER auto-start $phx-work** — Always present plan and ask
2. **Research before assuming** — Web-search unfamiliar tech
3. **Run research selectively** — Only relevant tracks, not all
4. **NEVER write plan while research tracks are still running**
5. **NEVER skip input findings** — Every finding MUST have a task
6. **Do NOT re-research existing deps unnecessarily**
7. **Skip research when planning from review/investigation** — When
   input is a review file or `$phx-investigate` output, the findings
   ARE the research. Do NOT run tracks to re-discover what the
   review already found. Convert findings directly to plan tasks.
   (Confirmed: 56-session analysis showed same findings discovered
   3-4x across review→investigate→plan phases, wasting ~96K tokens)

## Integration with Workflow

```text
$phx-plan {feature}  <-- YOU ARE HERE
       |
   $phx-plan --existing (optional enhancement)
       |
   ASK USER -> $phx-work .claude/plans/{feature}/plan.md
       |
$phx-review → $phx-compound
```

## Notes

- Plans saved to `.claude/plans/{slug}/plan.md`
- Research reports in `.claude/plans/{slug}/research/` can be deleted after

## CRITICAL: After Writing the Plan

**STOP. Do NOT proceed to implementation.**

After writing `.claude/plans/{slug}/plan.md`:

1. Summarize: task count, phases, key decisions
2. Use `ask the user directly` with options:
   - "Start in fresh session" (recommended for 5+ tasks)
   - "Get a briefing" (`$phx-brief` — interactive walkthrough)
   - "Start here"
   - "Review the plan"
   - "Adjust the plan"
3. Wait for user response. Never auto-start work.

**When user selects "Start in fresh session"**, print:

```
1. Run `/new` to start a fresh session
2. Then run one of:
   $phx-work .claude/plans/{slug}/plan.md
   $phx-full .claude/plans/{slug}/plan.md  (includes review + compound)
```

This is Iron Law #1. Violating it wastes user context.

## References (DO NOT read — for human reference only)

- `<skill-dir>/references/planning-workflow.md` — Detailed step-by-step
- `<skill-dir>/references/plan-template.md`
- `<skill-dir>/references/complexity-detail.md`
- `<skill-dir>/references/example-plan.md`
- `<skill-dir>/references/agent-selection.md`
- `<skill-dir>/references/breadboarding.md`
