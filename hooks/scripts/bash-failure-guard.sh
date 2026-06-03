#!/usr/bin/env bash
# PostToolUse dispatcher for failed Bash mix commands.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/codex-hook-utils.sh"

INPUT=$(cat)
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[[ "$TOOL" == "Bash" ]] || exit 0

COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
printf '%s\n' "$COMMAND" | grep -qE '^mix\b|MIX_ENV=\S+[[:space:]]+mix' || exit 0
hook_tool_failed "$INPUT" || exit 0

extract_context() {
  jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null
}

HINT_CONTEXT=$(printf '%s' "$INPUT" | "${SCRIPT_DIR}/elixir-failure-hints.sh" | extract_context)
CRITIC_CONTEXT=$(printf '%s' "$INPUT" | "${SCRIPT_DIR}/error-critic.sh" | extract_context)

COMBINED=""
if [[ -n "$HINT_CONTEXT" ]]; then
  COMBINED="$HINT_CONTEXT"
fi
if [[ -n "$CRITIC_CONTEXT" ]]; then
  if [[ -n "$COMBINED" ]]; then
    COMBINED="${COMBINED}"$'\n'"${CRITIC_CONTEXT}"
  else
    COMBINED="$CRITIC_CONTEXT"
  fi
fi

if [[ -n "$COMBINED" ]]; then
  printf '%s' "$COMBINED" | jq -Rs '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: .}}'
fi
