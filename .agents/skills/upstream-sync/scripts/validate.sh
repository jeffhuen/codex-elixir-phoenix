#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
SKILL="$ROOT/.agents/skills/upstream-sync/SKILL.md"
REFERENCE="$ROOT/.agents/skills/upstream-sync/references/conversion-checklist.md"

fail() {
  echo "upstream-sync validate: $*" >&2
  exit 1
}

[ -f "$SKILL" ] || fail "missing upstream-sync skill"
[ -f "$REFERENCE" ] || fail "missing conversion checklist reference"

grep -q '^name: upstream-sync$' "$SKILL" || fail "skill name must be upstream-sync"
grep -q 'oliver-kriska/claude-elixir-phoenix' "$SKILL" || fail "description must mention upstream repo"
grep -q 'conversion-checklist.md' "$SKILL" || fail "skill must point to conversion checklist"

for required in \
  'Do not blindly merge upstream' \
  'tools/generate-codex-agents.mjs' \
  'tests/codex-agents_test.sh' \
  '.agents/skills/upstream-sync/scripts/validate.sh' \
  'hooks/hooks.json' \
  'Codex Vs Claude Translation' \
  'Model Mapping' \
  'model_reasoning_effort' \
  'PermissionRequest' \
  'SubagentStart' \
  'SubagentStop' \
  'prompt/agent handlers' \
  'code 127' \
  'bash -n' \
  '.codex-plugin/plugin.json' \
  'cachebuster' \
  'codex plugin marketplace add'
do
  grep -q "$required" "$REFERENCE" || fail "checklist missing: $required"
done

echo "upstream-sync validate: guardrails verified"
