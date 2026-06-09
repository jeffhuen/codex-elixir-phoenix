#!/usr/bin/env bash
# SessionStart hook: Create core workflow directories (other dirs created by skills on demand)

# Skip in non-Elixir projects (cross-project bleed guard — issue #55).
# Don't litter .claude/{plans,reviews,solutions,audit,...} into non-Elixir repos.
input="$(cat 2>/dev/null || true)"
proj="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$proj" ] || proj="$PWD"
[ -f "$proj/mix.exs" ] || exit 0

mkdir -p .claude/plans .claude/reviews .claude/solutions .claude/audit .claude/skill-metrics .claude/research 2>/dev/null || true

# Create persistent plugin data directory (survives plugin updates)
# Codex sets PLUGIN_DATA for plugin-owned writable state.
data_dir="${PLUGIN_DATA:-}"
if [ -n "$data_dir" ]; then
  mkdir -p "${data_dir}/skill-metrics" 2>/dev/null || true
fi
