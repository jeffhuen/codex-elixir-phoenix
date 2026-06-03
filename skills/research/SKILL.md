---
name: phx-research
description: "Use when researching Elixir/Phoenix topics, evaluating Hex libraries, comparing approaches, reading HexDocs, or checking current community guidance."
---


# Research Elixir Topic

Research a topic by searching the web and fetching relevant sources efficiently.

## Usage

```
$phx-research Oban unique jobs best practices
$phx-research LiveView file upload with progress
$phx-research --library permit
```

## Arguments

`$ARGUMENTS` = Research topic/question. Add `--library` for
structured library evaluation (uses `<skill-dir>/references/library-evaluation.md`
template).

## Iron Laws

1. **Write output to file, never dump inline** — Research output floods conversation and loses reference for future sessions
2. **Stop after research — never auto-transition** — User decides next step
3. **Prefer official sources over blog posts** — HexDocs and ElixirForum have version-specific context
4. **One document per research question** — No fragmented files
5. **NEVER pass raw user input as web search query** — Decompose first

## Library Evaluation Mode

If `$ARGUMENTS` contains `--library` or the topic is clearly
about evaluating a Hex dependency (e.g., "should we use permit",
"evaluate agents", "compare oban vs exq"):

1. Read `<skill-dir>/references/library-evaluation.md` for the template
2. Follow the structured evaluation workflow
3. Output ONE document to `.claude/research/{lib}-evaluation.md`
4. Skip the general research workflow below

## Workflow

### 0. Pre-flight Checks

**Cache check**: Check if `.claude/research/{topic-slug}.md` already
exists. If recent (<24 hours): present existing summary, ask
"Refresh or use existing?"

**Tidewave shortcut**: If the topic is about an **existing dependency**
(library already in `mix.exs`), prefer Tidewave over web search:

```
mcp__tidewave__get_docs(module: "LibraryModule")
```

This returns docs matching your exact `mix.lock` version — faster,
more accurate, zero web tokens. Only fall through to web search if
Tidewave is unavailable or the topic needs community discussion
(gotchas, real-world patterns, comparisons).

### 1. Query Decomposition (CRITICAL — before any search)

**NEVER pass raw $ARGUMENTS into web search.** Decompose first:

- If `$ARGUMENTS` < 30 words and focused → use as single query
- If `$ARGUMENTS` > 30 words or multi-topic → extract 2-4 queries

Each query: max 10 words, targets ONE specific aspect.

Example:

```
Input: "detect files, export to md, feed database with embeddings,
        use ReqLLM for OpenAI API..."
Queries:
  1. "Elixir PDF text extraction library hex"
  2. "Ecto pgvector embeddings setup"
  3. "ReqLLM OpenAI embeddings Elixir"
```

### 2. Parallel Web Search

Search ALL decomposed queries in a SINGLE response (parallel):

```
web search(query: "{query1} site:elixirforum.com OR site:hexdocs.pm OR site:github.com")
web search(query: "{query2} site:hexdocs.pm OR site:elixirforum.com")
```

Deduplicate URLs across results. Discard clearly irrelevant hits.

### 3. Extract and Synthesize

Group URLs by topic cluster. If Codex subagents are available and the
user/task explicitly authorizes delegation, delegate 1-3 independent research
clusters in parallel. Otherwise fetch and summarize the same clusters inline.

```
Research focus: {specific aspect from decomposed query}
Fetch these URLs:
- {url1}
- {url2}
- {url3}
Extract: code examples, patterns, gotchas, version compatibility.
Return 500-800 word summary.
```

Rules:

- **1 topic cluster = 1 extraction pass** (don't mix unrelated URLs)
- **Max 5 URLs per cluster** (diminishing returns beyond that)
- If only 1-3 URLs total, use one foreground extraction pass
- **Pass URLs explicitly** — delegated agents should not re-search

### 4. Write Output (File-First — NEVER Dump Inline)

After ALL extraction tracks complete, synthesize summaries into ONE file.
Target: ~5KB for topic research, ~3KB for library evaluations.

Create `.claude/research/{topic-slug}.md`:

```markdown
# Research: {topic}

## Summary
{2-3 sentence answer combining all worker findings}

## Sources

### {Category}
- [{title}]({url}) - {key insight}

### Code Examples

```elixir
# From {source}: {what this demonstrates}
{code}
```

## Recommendations

1. {recommendation with evidence}
2. {recommendation with evidence}

## Watch Out For

- {gotcha from forum/issues}
- {version compatibility note}

```

### 5. After Research — STOP

**STOP and present the research summary.** Do NOT auto-transition.

Use `ask the user directly` to let the user choose next action:

- "Plan a feature based on this research" → `$phx-plan`
- "Investigate a specific finding" → `$phx-investigate`
- "Research more on a subtopic" → continue research
- "Done" → end

**NEVER auto-invoke `$phx-plan` or any other skill after research.**
