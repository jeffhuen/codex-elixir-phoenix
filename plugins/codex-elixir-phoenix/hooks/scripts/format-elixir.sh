#!/usr/bin/env bash
# PostToolUse hook: Check Elixir file formatting after Edit/Write
# Only warns — does NOT modify files (prevents "file modified since read" race condition)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/codex-hook-utils.sh"
INPUT=$(cat)

# Skip in non-Elixir projects (defense in depth — issue #55)
proj="$(hook_project_dir "$INPUT")"
[ -f "$proj/mix.exs" ] || exit 0

while IFS= read -r FILE_PATH; do
  if [[ "$FILE_PATH" == *.ex ]] || [[ "$FILE_PATH" == *.exs ]]; then
    [[ -f "$FILE_PATH" ]] || continue
    if ! mix format --check-formatted "$FILE_PATH" 2>/dev/null; then
      # PostToolUse: exit 2 + stderr feeds message back to the agent.
      echo "NEEDS FORMAT: $FILE_PATH — run 'mix format' before committing" >&2
      exit 2
    fi
  fi
done < <(hook_tool_file_paths "$INPUT")
