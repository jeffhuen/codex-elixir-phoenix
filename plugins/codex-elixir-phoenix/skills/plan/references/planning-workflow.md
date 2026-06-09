# Planning Workflow — Detailed Steps

Full step-by-step details for `$phx-plan`. The SKILL.md has a
summary; this reference has the complete workflow.

## Interview Detection (from $phx-brainstorm)

Before asking clarification questions, check for a pre-existing
brainstorm interview:

1. Check `$ARGUMENTS` for a path containing `interview.md`
2. Check `.claude/plans/*/interview.md` for recent files (<24h)

If found with `Status: COMPLETE`:

- Read the interview.md Summary and Coverage Details
- Skip clarification questions entirely — the interview IS the clarification
- Use interview content as input for research track selection (depth detection still applies)
- Note in scratchpad: "Requirements from $phx-brainstorm interview"

If found with `Status: IN_PROGRESS`:

- Read what exists, note gaps in coverage
- Ask ONLY about uncovered dimensions (don't re-ask covered ones)

## Clarification Questions (when requirements are fuzzy)

When the description is vague, unclear, or missing key details,
and no brainstorm interview.md exists, ask clarifying questions
**one at a time** before planning.

**Signals that clarification is needed:**

- Description is under 10 words without specifics
- Contains "some kind of", "maybe", "I think", "not sure"
- Missing WHO (which users), WHAT (specific behavior), or WHY
- Multiple possible interpretations exist
- Security/data implications that need explicit decisions

**Question flow** (ask ONE at a time, not all at once):

1. **Purpose**: "What problem does this solve for users?"
2. **Scope**: "Which specific behavior should this include?"
3. **Users**: "Who will use this? Any role/permission differences?"
4. **Constraints**: "Any technical constraints or preferences?"
5. **Edge cases**: "What should happen when [X]?"

**Stop asking when**: You have enough to write a plan with
concrete tasks. 2-4 questions is usually enough. Don't
interrogate — if the user gives a detailed answer, extract
what you need and move on.

**Capture decisions**: Save all clarification answers to
`.claude/plans/{slug}/scratchpad.md` as DECISION entries for future
reference.

## Depth Detection

If `--depth` not specified, auto-detect from **both** the clarity
of the request and the technical complexity:

| Request Clarity            | Technical Scope                    | Depth                       |
| -------------------------- | ---------------------------------- | --------------------------- |
| Clear + specific           | 1 context, <5 files                | `quick`                     |
| Clear + specific           | 2-3 contexts, schemas/LiveViews    | `standard`                  |
| Clear + specific           | 4+ contexts, security, new workers | `deep`                      |
| Vague (post-clarification) | Any                                | At least `standard`         |
| From review file           | Any                                | `standard` (scope is known) |

**Depth determines research breadth AND plan detail:**

| Depth      | Research Breadth   | Clarification           | Plan Detail                          |
| ---------- | ------------------ | ----------------------- | ------------------------------------ |
| `quick`    | Codebase patterns only | Skip if clear       | Task list, minimal prose             |
| `standard` | 2-3 specialist tracks | 1-2 questions if needed | Phased tasks with code patterns   |
| `deep`     | Full research tracks | 3-5 questions         | Full system map, risks, alternatives |

**Elixir-specific complexity signals**: New migration? New LiveView?
New Oban worker? Changes Phoenix context boundaries? Multiple
contexts affected? These push toward deeper planning.

## Research Tracks

Select research tracks based on what's actually needed. Delegate broad
research only when Codex subagents are available in the current environment
and the user/task has authorized delegation. Otherwise run the selected tracks
inline, sequentially. You MAY read specific files (CI config, a single module)
for plan detail, but keep the research scoped to the selected tracks.

**Track count scales with depth:**

- `quick`: 1 track (phoenix-patterns-analyst only)
- `standard`: 2-3 tracks (patterns + relevant specialists)
- `deep`: 4+ tracks (patterns + specialists +
  web-researcher + hex-library-researcher)

**Always run:**

- `phoenix-patterns-analyst`: Analyze codebase for existing patterns

**Run conditionally based on feature needs:**

| Condition                             | Agent                    |
| ------------------------------------- | ------------------------ |
| NEW library needed (not in mix.exs)   | `hex-library-researcher` |
| UI, form, live, real-time features    | `liveview-architect`     |
| Database, schema, table changes       | `ecto-schema-designer`   |
| Job, worker, async, queue             | `oban-specialist`        |
| GenServer, process, state             | `otp-advisor`            |
| Auth, login, permission, security     | `security-analyzer`      |
| Unfamiliar tech, need community input | `web-researcher`         |
| Changing function signatures          | `call-tracer`            |

**hex-library-researcher rules (STRICT):**

- ONLY use when evaluating a library NOT already in mix.exs
- Do NOT use for: review blockers, refactoring, existing libraries
- To understand an existing library's API, use Read/Grep on
  `deps/{library}/lib/` or use Tidewave's `get_docs` instead

If delegation is available, start all selected research tracks together when
their scopes are independent. Minimum 1 track must run.

**Track prompts must be FOCUSED.** Scope each prompt to the
relevant directories, files, and patterns. Do NOT give vague
prompts like "analyze the codebase."

## Waiting for Delegated Tracks

When tracks are delegated, wait until each completes. Read each output file to
collect results. Do NOT proceed to plan generation until every selected track
has completed or you have explicitly fallen back to inline research.

Then read reports from `.claude/plans/{slug}/research/`.

If a delegated track fails, do the research yourself with Read/Grep instead of
delegating again.

## Infrastructure Knowledge Persistence

When research discovers **project infrastructure** (not feature-specific code)
such as test helpers, factory patterns, API endpoint maps, or compile
environments, write a compact summary to
`.claude/plans/{slug}/scratchpad.md` under a `## Infrastructure` heading. This
prevents re-exploration in follow-up sessions.

Signals that knowledge is infrastructure (not feature-specific):

- Test setup patterns (`test/support/`, `test/int_support/`)
- Custom MIX_ENV configurations
- Factory/fixture patterns
- CI/deployment pipeline structure

## Breadboard System Map (LiveView Features)

**When to breadboard**: The feature touches 2+ LiveView pages or
components, has complex event flows (PubSub, streams, multi-step
forms), or involves navigation between multiple live routes.
**Skip** for single-page CRUD, config changes, or non-LiveView work.

If the liveview-architect track ran, its report should include affordance
tables. Use these to build a system map. See `references/breadboarding.md` for
full details.

## Completeness Check

**MANDATORY when planning from review.** List ALL findings from
the source and verify every one is covered:

> Source has N items. Coverage:
>
> - Finding 1: -> Plan A / Task X
> - Finding 2: -> Plan A / Task Y
>
> All N items are planned.

Every finding gets a task. No exceptions. If the user wants to
exclude something, they must say so explicitly.

**Elixir completeness**: Does the plan include migration if schema
changes? Tests for new public functions? LiveView mount + event
handlers? Context functions for new domain logic?

## Split Decision

**One plan = one MD file = one focused work unit.**

If the feature is small (up to ~8 tasks, same domain), skip this
step and create one plan. Do NOT ask unnecessary questions.

If the feature is large, present OPTIONS with concrete numbers:

> Based on my analysis, this feature has N concerns and ~M tasks.
> How should I structure the plans?
>
> 1. **One plan** -- 1 file, ~M tasks across K phases
> 2. **Split into X plans** -- grouped by domain:
>    - `auth/plan.md` (5 tasks) -- login, register, reset
>    - `profiles/plan.md` (4 tasks) -- avatar, bio, settings

## Plan Generation

Create plan(s) at `.claude/plans/{feature-slug}/plan.md`.

Key requirements:

- Tasks in `- [ ] [Pn-Tm][annotation] Description` format
  (required for `$phx-work`). Valid annotations:
  `[direct]` (most common), `[ecto]`, `[liveview]`, `[oban]`,
  `[otp]`, `[security]`, `[test]`.
  Do NOT use delegated worker names like `[general-purpose]` or
  `[solo]` -- those are not valid annotations.
- Include: Summary, Scope, Technical Decisions, Phased Tasks,
  Patterns, Risks

**Task granularity**: Tasks are logical work units, NOT individual
file edits. Group by PATTERN (what you're doing), list LOCATIONS
within. Each task includes implementation detail (code examples,
before/after). Aim for 3-8 tasks per phase, not 15+.

**Function signature precision**: When a task involves extracting,
refactoring, or renaming functions, ALWAYS specify the exact
`ModuleName.function_name/arity` for both source and target.
Example: "Extract `MyApp.Orders.currency_options/0` from
`MyApp.Orders.Order` to `MyApp.Shared.CurrencyHelpers`".
Never write vague tasks like "extract existing pattern" without
specifying the function signature — this causes compile stalls.

**Scratchpad**: Also create `.claude/plans/{feature-slug}/scratchpad.md`
with initial context (feature name, brief description, plan file
path). This captures planning decisions for future sessions.

Read only the reference files needed for the selected tracks. Keep the plan
template local to the planning flow.

## Self-Check (Deep Plans Only)

For `deep` plans, answer these three questions in the plan's
**Risks** section before presenting:

1. **"What was the hardest decision?"** — Which technical choice
   had the most tradeoffs? Document alternatives considered.
2. **"What alternatives were rejected?"** — For each major
   decision, note what else was considered and why it lost.
3. **"What am I least confident about?"** — Flag areas where
   the plan might be wrong. Mark with ⚠️ for user review.

## Presenting the Plan

**STOP and present the plan.** Briefly summarize the plan (task
count, phase names, key scope). Then use `ask the user directly`:

For single plan:

- **Start in fresh session** (recommended for 5+ tasks)
- **Get a briefing** -- interactive walkthrough via `$phx-brief`
- **Start here** -- in current session (fine for small plans)
- **Review the plan** -- walk through phases in detail
- **Adjust the plan** -- tell me what to change

Do NOT say "Start Phase 1" — `$phx-work` runs the whole plan.

**When user selects "Start in fresh session"**, print clear
step-by-step:

```
1. Run `/new` to start a fresh session
2. Then run one of:
   $phx-work .claude/plans/{slug}/plan.md
   $phx-full .claude/plans/{slug}/plan.md  (includes review + compound)
```

## Deepening an Existing Plan (--existing mode)

When `--existing` is passed with a plan file path, enhance the
plan with deeper research instead of creating a new one.

### Deepening Workflow

1. **Load plan** -- Parse phases, tasks, annotations, `???` markers
2. **Search compound docs** -- Find known issues in planned areas
   (`grep -rl "KEYWORD" .claude/solutions/`)
3. **Run research tracks** -- Use specialist tracks with the same
   selection rules as the main flow. Each track should write detailed output to
   `.claude/plans/{slug}/research/{topic}.md` and return ONLY a
   500-word summary. Delegate only when Codex subagents are available and
   authorized; otherwise run inline.
4. **Wait for ALL delegated tracks** -- Read each output file. Do NOT proceed
   until all selected tracks are complete or have been handled inline.
5. **Enhance plan** -- Add implementation detail, resolve spikes,
   add verification criteria, note risk from compound docs
6. **Present diff summary** -- Show what was enhanced

### When Deepening Adds Value

- Plan has 5+ tasks touching unfamiliar code
- Feature involves external API integration
- Security-sensitive features (auth, payments)
- Plan generated from review findings
- Tasks have `???` or spike markers

### Deepening Rules

- **NEVER delete existing tasks** — Only add detail and risks
- **Preserve task IDs** — `[Pn-Tm]` identifiers must not change
- **Compound docs first** — Check solution docs before extra research
  (saves context)
- **Context budget** — `--existing` often runs in sessions with prior history.
  Prefer specialist tracks that write to files and return short summaries.
