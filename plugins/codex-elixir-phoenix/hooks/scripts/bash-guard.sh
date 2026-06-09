#!/usr/bin/env bash
# PreToolUse dispatcher for Bash events.
# Mirrors Claude's Bash hooks with Codex-supported matching:
# - block-dangerous-ops.sh runs for every Bash command and self-gates silently.
# - deps-audit-gate.sh runs only for mix deps.* commands, matching Claude's if.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT=$(cat)

TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[[ "$TOOL" == "Bash" ]] || exit 0

COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[[ -n "$COMMAND" ]] || exit 0

BLOCK_OUTPUT=$(printf '%s' "$INPUT" | "${SCRIPT_DIR}/block-dangerous-ops.sh")
if [[ -n "$BLOCK_OUTPUT" ]]; then
  printf '%s\n' "$BLOCK_OUTPUT"
  exit 0
fi

if printf '%s\n' "$COMMAND" | grep -qE 'mix[[:space:]]+deps\.(get|update|compile)\b'; then
  printf '%s' "$INPUT" | "${SCRIPT_DIR}/deps-audit-gate.sh"
fi
