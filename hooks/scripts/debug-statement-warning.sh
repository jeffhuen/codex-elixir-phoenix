#!/usr/bin/env bash
# PostToolUse hook: Warn about debug statements left in Elixir files.
# Extends AutoHarness action-verifier pattern — catches IO.inspect,
# dbg(), IO.puts in production code (not tests).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/codex-hook-utils.sh"
INPUT=$(cat)

# Skip in non-Elixir projects (defense in depth — issue #55)
proj="$(hook_project_dir "$INPUT")"
[ -f "$proj/mix.exs" ] || exit 0

while IFS= read -r FILE_PATH; do
  [[ -z "$FILE_PATH" ]] && continue

  # Only check Elixir source files (not tests, not scripts)
  [[ "$FILE_PATH" == *.ex ]] || continue
  [[ "$FILE_PATH" != *_test.exs ]] || continue
  [[ "$FILE_PATH" != */test/* ]] || continue
  [[ -f "$FILE_PATH" ]] || continue

  DEBUGS=""

  # IO.inspect (most common debug leftover)
  MATCH=$(grep -n 'IO\.inspect\b' "$FILE_PATH" 2>/dev/null | head -3)
  if [[ -n "$MATCH" ]]; then
    DEBUGS="${DEBUGS}\n  IO.inspect:\n${MATCH}"
  fi

  # dbg() calls
  MATCH=$(grep -n '\bdbg(' "$FILE_PATH" 2>/dev/null | head -3)
  if [[ -n "$MATCH" ]]; then
    DEBUGS="${DEBUGS}\n  dbg():\n${MATCH}"
  fi

  # IO.puts outside @moduledoc/@doc
  MATCH=$(grep -n 'IO\.puts\b' "$FILE_PATH" 2>/dev/null | grep -v '@moduledoc\|@doc' | head -3)
  if [[ -n "$MATCH" ]]; then
    DEBUGS="${DEBUGS}\n  IO.puts:\n${MATCH}"
  fi

  if [[ -n "$DEBUGS" ]]; then
    cat >&2 <<MSG
DEBUG STATEMENTS in $(basename "$FILE_PATH"):
$(echo -e "$DEBUGS")

Remove before committing. Use Logger for intentional logging.
MSG
    exit 2
  fi
done < <(hook_tool_file_paths "$INPUT")
