#!/usr/bin/env bash
# PostToolUse hook: When a plan.md file is CREATED (Write, not Edit),
# remind the agent to STOP and present the plan to the user.
# Skips in \$phx-full autonomous mode (detected by progress.md with State).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/codex-hook-utils.sh"
INPUT=$(cat)

# Skip in non-Elixir projects (cross-project bleed guard — issue #55)
proj="$(hook_project_dir)"
[ -f "$proj/mix.exs" ] || exit 0

while IFS= read -r FILE_PATH; do
  if [[ -z "$FILE_PATH" ]]; then
    continue
  fi

  # Only trigger for plan.md files
  echo "$FILE_PATH" | grep -qE '\.claude/plans/[^/]+/plan\.md$' || continue

  # Only trigger on new plan creation, not checkbox updates.
  hook_created_path "$INPUT" "$FILE_PATH" || continue

  # Skip in \$phx-full autonomous mode — workflow-orchestrator creates
  # progress.md with **State**: field during INITIALIZING.
  PLAN_DIR=$(dirname "$FILE_PATH")
  if [ -f "${PLAN_DIR}/progress.md" ] && grep -q '\*\*State\*\*:' "${PLAN_DIR}/progress.md" 2>/dev/null; then
    continue
  fi

  # PostToolUse: exit 2 + stderr feeds message back to the agent.
  cat >&2 <<'MSG'

==========================================
STOP: Plan file created.
==========================================
Do NOT proceed to implementation.
Present a brief summary of the plan to the user,
then use ask the user directly with options:
  - Start in fresh session (recommended)
  - Start here
  - Review the plan
  - Adjust the plan
==========================================
MSG
  exit 2
done < <(hook_tool_file_paths "$INPUT")
