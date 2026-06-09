#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d /private/tmp/codex-agent-install-test.XXXXXX)"

"$ROOT/tools/install-codex-agents.sh" "$TMP" >/tmp/codex-agent-install-test.out

count="$(find "$TMP/.codex/agents" -maxdepth 1 -name '*.toml' -type f | wc -l | tr -d ' ')"
[ "$count" = "25" ] || {
  echo "install-codex-agents_test: expected 25 installed agents, got $count" >&2
  exit 1
}

conflict="$TMP/.codex/agents/security-analyzer.toml"
printf '%s\n' '# user-owned security analyzer' 'name = "security-analyzer"' >"$conflict"

"$ROOT/tools/install-codex-agents.sh" "$TMP" >/tmp/codex-agent-install-test-conflict.out 2>/tmp/codex-agent-install-test-conflict.err

grep -q '# user-owned security analyzer' "$conflict" || {
  echo "install-codex-agents_test: user-owned custom agent was overwritten" >&2
  exit 1
}

grep -q 'skipped=1' /tmp/codex-agent-install-test-conflict.out || {
  echo "install-codex-agents_test: conflict summary did not report skipped=1" >&2
  exit 1
}

echo "install-codex-agents_test: install/update/conflict behavior verified"
