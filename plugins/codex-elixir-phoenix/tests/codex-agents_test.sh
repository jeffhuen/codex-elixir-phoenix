#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$ROOT/agents"
OUT_DIR="$ROOT/.codex/agents"

fail() {
  echo "codex-agents_test: $*" >&2
  exit 1
}

[ -d "$SRC_DIR" ] || fail "missing source agents directory: $SRC_DIR"
[ -d "$OUT_DIR" ] || fail "missing Codex custom agents directory: $OUT_DIR"

count=0
for src in "$SRC_DIR"/*.md; do
  [ -e "$src" ] || fail "no source agent markdown files found"

  name="$(sed -n 's/^name:[[:space:]]*//p' "$src" | head -1)"
  [ -n "$name" ] || fail "missing name in $src"

  out="$OUT_DIR/$name.toml"
  [ -f "$out" ] || fail "missing generated Codex agent for $name: $out"

  grep -q "^name = \"$name\"$" "$out" || fail "$out missing exact name field"
  grep -q '^description = ' "$out" || fail "$out missing description"
  grep -q '^developer_instructions = ' "$out" || fail "$out missing developer_instructions"
  grep -q '^model = "gpt-' "$out" || fail "$out missing Codex model"
  grep -q '^model_reasoning_effort = "' "$out" || fail "$out missing model_reasoning_effort"

  if grep -Eq '^(tools|disallowedTools|permissionMode|maxTurns|omitClaudeMd|effort|skills):' "$out"; then
    fail "$out contains Claude-style frontmatter keys"
  fi

  if grep -Eiq '@anthropic-ai|anthropic|\b(sonnet|opus|haiku)\b' "$out"; then
    fail "$out contains Claude/Anthropic runtime wording"
  fi

  count=$((count + 1))
done

[ "$count" -gt 0 ] || fail "expected at least one generated Codex agent"

echo "codex-agents_test: verified $count Codex custom agents"
