# Specialist Track Selection Guidelines

Use these tracks when `$phx-plan` needs focused research. Delegate a track only
when Codex subagents are available and authorized; otherwise run it inline.

## Which Tracks To Run

| Feature Type | Tracks |
|--------------|--------|
| CRUD feature | patterns-analyst, ecto |
| Interactive UI | patterns-analyst, liveview |
| External integration | patterns-analyst, otp, hex-researcher only if a new library is needed |
| Background processing | patterns-analyst, oban, otp |
| Data-heavy | patterns-analyst, ecto, hex-researcher only if a new library is needed |
| Real-time | patterns-analyst, liveview |
| Auth/permissions | patterns-analyst, security-analyzer |
| Refactoring | patterns-analyst, call-tracer |
| Review fix, simple | patterns-analyst only |
| Review fix, complex | patterns-analyst plus relevant specialists |
| Full new feature | All relevant tracks |

## hex-library-researcher

Use ONLY when:

- Feature requires a new library not yet in `mix.exs`
- Evaluating alternative libraries to replace an existing dependency

Do NOT use when:

- Library is already in `mix.exs`; read `deps/` or use Tidewave docs instead
- Fixing review blockers
- Refactoring existing code
- Understanding an existing dependency API
- Handling simple bug fixes or improvements

## web-researcher

Use when:

- Feature involves an unfamiliar library or pattern
- Community input is needed
- Real-world examples would change the plan
- Known issues or gotchas need checking
- CI/CD or infrastructure questions are load-bearing

Do NOT use for standard CRUD, well-known patterns, or codebase-local patterns
that are already clear.

Rules:

- Use focused 5-15 word queries or pre-selected URLs, never vague prompts.
- If multiple web topics are independent, handle each as a separate track.
- Cap at 5 URLs per topic.
- Return a 500-800 word summary; synthesis happens in the main planning flow.

## call-tracer

Use when planning involves:

- Changing function signatures
- Moving or renaming functions
- Refactoring contexts
- Understanding request/data flow before changing APIs

## Clarifying Questions

Ask if scope, performance requirements, integration points, or approach choice
is ambiguous. Do not ask when best practice is clear and the codebase already
shows the pattern. Max 3 questions.
