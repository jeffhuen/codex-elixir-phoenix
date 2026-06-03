---
name: phx-permissions
description: "Use when Codex permission prompts, sandbox limits, workspace roots, network access, or config.toml profiles slow Elixir/Phoenix workflow."
---

# Codex Permission Analyzer

Review Codex permission profiles for an Elixir/Phoenix project and recommend
safe, minimal config changes. Do not edit global config without explicit user
approval.

## Usage

```
$phx-permissions
$phx-permissions --dry-run
$phx-permissions --profile project-edit
```

## What Codex Uses

Codex permissions live in `config.toml` profiles, not Claude `settings.json`
Bash allow patterns.

Relevant surfaces:

- `~/.codex/config.toml` for user-level defaults
- project `.codex/config.toml` when present and trusted
- `default_permissions`
- `[permissions.<name>]`
- `[permissions.<name>.workspace_roots]`
- `[permissions.<name>.filesystem]`
- `[permissions.<name>.network]`

Built-ins are `:read-only`, `:workspace`, and `:danger-full-access`.

## Workflow

1. Read active Codex config files that are visible in this environment.
2. Identify the active permission profile and whether it extends a built-in.
3. Check whether the Elixir project root and sibling repos used by the task are
   covered by workspace roots.
4. Check whether `.env` files and secrets remain denied.
5. Check whether network access is broader than needed.
6. Present a dry-run recommendation first. Ask before editing config.

## Recommendations

Prefer profiles that extend `:workspace`:

```toml
default_permissions = "phoenix-workspace"

[permissions.phoenix-workspace]
extends = ":workspace"

[permissions.phoenix-workspace.workspace_roots]
"/path/to/project" = true

[permissions.phoenix-workspace.filesystem.":workspace_roots"]
"**/*.env" = "deny"

[permissions.phoenix-workspace.network]
enabled = true
```

Add network domain allow/deny rules only when the current task needs network
access and Codex supports domain policy in the active environment.

## Iron Laws

1. **Do not recommend `:danger-full-access` as a routine fix.**
2. **Keep secret files denied** even when workspace roots are writable.
3. **Ask before editing config.**
4. **Prefer narrow workspace roots** over broad home-directory access.
5. **Report uncertainty** when current effective permissions cannot be read.

## Output

Return:

- active profile and config sources found
- missing workspace roots, if any
- excessive write/network access, if any
- exact proposed TOML patch, if the user wants changes
