---
name: hexdocs-fetcher
description: "Use when looking up HexDocs pages, Elixir library modules, function docs, guides, changelogs, or version-matched docs for dependencies."
---


# HexDocs Fetcher

Efficiently fetch Elixir library documentation from hexdocs.pm using the
best documentation source available in the current Codex session.

## Usage

Prefer sources in this order:

1. Tidewave MCP `get_docs` when available, because it is version-matched to
   the running project.
2. Official HexDocs pages through the available web/documentation tools.
3. General web search only when the exact HexDocs URL is unknown.

```
# Version-matched docs through Tidewave MCP
mcp__tidewave__get_docs(module: "Oban.Worker")

# Official HexDocs URLs to fetch with available web/documentation tools
https://hexdocs.pm/oban
https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html
https://hexdocs.pm/ecto/getting-started.html
```

Use focused extraction prompts:

```
Extract installation instructions, main concepts, and one basic usage example.
Extract all public function docs with @spec and examples.
Extract configuration options and defaults.
Extract troubleshooting sections, common errors, and FAQs.
```

## Token Efficiency

Focused fetches keep context small:

| Source | Raw HTML | Focused extraction | Benefit |
|--------|----------|---------------|---------|
| HexDocs page | ~80k tokens | ~15k tokens | **80% reduction** |
| Phoenix docs | ~120k tokens | ~25k tokens | **79% reduction** |
| README | ~20k tokens | ~8k tokens | **60% reduction** |

## Integration with hex-library-researcher

When evaluating libraries, fetch only the relevant docs:

```
https://hexdocs.pm/oban
Prompt/focus: installation instructions, main features, basic usage example.
```

## Common HexDocs URLs

```
# Library overview
https://hexdocs.pm/{library}

# Module documentation
https://hexdocs.pm/{library}/{Module}.html
https://hexdocs.pm/{library}/{Module.Submodule}.html

# Guides
https://hexdocs.pm/{library}/guides.html
https://hexdocs.pm/{library}/{guide-name}.html

# API reference
https://hexdocs.pm/{library}/api-reference.html
```

## Prompt Strategies

Use focused prompts for better extraction:

```
# For API docs
prompt: "Extract all public function docs with @spec and examples"

# For guides
prompt: "Extract the complete guide content preserving code examples"

# For troubleshooting
prompt: "Extract any troubleshooting sections, common errors, and FAQs"

# For configuration
prompt: "Extract configuration options and their defaults"
```

## Caching

Use whatever caching the available Codex documentation or web tool provides.
Avoid repeatedly fetching the same full page in one session.

For longer persistence, save to planning directory:

```
# After fetching, write the result to:
.claude/plans/{slug}/research/docs/oban.md
```

## Tidewave Alternative

If Tidewave MCP is available, prefer `mcp__tidewave__get_docs` for exact version-matched documentation:

```
mcp__tidewave__get_docs(module: "Oban.Worker")
```

This fetches docs for the exact version in your `mix.lock`.

## Iron Laws

1. **NEVER fetch entire HexDocs sites** — always target specific modules or guides
2. **Use focused prompts** — generic fetches waste tokens; specify what to extract
3. **Prefer Tidewave when available** — exact version match beats generic hexdocs.pm
