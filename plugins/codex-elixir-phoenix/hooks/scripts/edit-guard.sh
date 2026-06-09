#!/usr/bin/env bash
# PostToolUse dispatcher for Edit/Write/apply_patch events.
# Keep Codex hook fan-out low; invoke expensive checks only for relevant paths.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/codex-hook-utils.sh"

INPUT=$(cat)
proj="$(hook_project_dir "$INPUT")"
[ -f "$proj/mix.exs" ] || exit 0

HAS_PATH=false
HAS_ELIXIR=false
HAS_SECURITY_SURFACE=false
HAS_DEBUG_SURFACE=false
HAS_PLAN=false

while IFS= read -r FILE_PATH; do
  [[ -n "$FILE_PATH" ]] || continue
  HAS_PATH=true

  case "$FILE_PATH" in
    *.ex|*.exs)
      HAS_ELIXIR=true
      ;;
  esac

  case "$(basename "$FILE_PATH")" in
    *.ex)
      HAS_DEBUG_SURFACE=true
      ;;
  esac

  case "$(basename "$FILE_PATH")" in
    *.ex|*.exs|*.heex|*.eex|*.leex)
      HAS_SECURITY_SURFACE=true
      ;;
  esac

  if echo "$FILE_PATH" | grep -qE '\.claude/plans/[^/]+/plan\.md$'; then
    HAS_PLAN=true
  fi
done < <(hook_tool_file_paths "$INPUT")

if [ "$HAS_PATH" = false ]; then
  exit 0
fi

run_hook() {
  local script="$1"
  printf '%s' "$INPUT" | "${SCRIPT_DIR}/${script}"
}

if [ "$HAS_ELIXIR" = true ]; then
  run_hook format-elixir.sh || exit $?
  run_hook iron-law-verifier.sh || exit $?
fi

if [ "$HAS_DEBUG_SURFACE" = true ]; then
  run_hook debug-statement-warning.sh || exit $?
fi

if [ "$HAS_SECURITY_SURFACE" = true ]; then
  run_hook security-reminder.sh || exit $?
fi

if [ "$HAS_PLAN" = true ]; then
  run_hook plan-stop-reminder.sh || exit $?
fi

run_hook log-progress.sh || exit $?
