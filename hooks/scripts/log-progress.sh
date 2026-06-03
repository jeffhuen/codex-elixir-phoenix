#!/usr/bin/env bash
# PostToolUse hook: Cross-project edit metrics (JSONL).
#
# The previous progress.md appender was removed in v2.8.3 — it picked the
# most recently modified progress.md across ALL plans, which wrote entries
# into unrelated plans whenever the user had more than one in flight
# (issue #38). The \$phx-work skill logs structured progress entries itself,
# so the hook-driven append was both redundant and wrong.

# Skip in non-Elixir projects (cross-project bleed guard — issue #55)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/codex-hook-utils.sh"

proj="$(hook_project_dir)"
[ -f "$proj/mix.exs" ] || exit 0

INPUT=$(cat)
PLUGIN_METRICS_DIR="${PLUGIN_DATA:-${CLAUDE_PLUGIN_DATA:-}}"
[[ -n "$PLUGIN_METRICS_DIR" ]] || exit 0

mkdir -p "${PLUGIN_METRICS_DIR}/skill-metrics" 2>/dev/null || true
METRICS_FILE="${PLUGIN_METRICS_DIR}/skill-metrics/edits-$(date '+%Y-%m').jsonl"

while IFS= read -r FILE_PATH; do
  if [[ -n "$FILE_PATH" ]]; then
    jq -nc \
      --arg ts "$(date -Iseconds)" \
      --arg file "$FILE_PATH" \
      --arg project "$(basename "$(pwd)")" \
      '{ts: $ts, file: $file, project: $project}' >> "$METRICS_FILE" 2>/dev/null || true
  fi
done < <(hook_tool_file_paths "$INPUT")
