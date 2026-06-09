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
  'agents/openai.yaml' \
  'plugins/codex-elixir-phoenix/agents/*.md' \
  'do not generate Codex agent TOML' \
  '.agents/skills/upstream-sync/scripts/validate.sh' \
  'hooks/hooks.json' \
  'Codex Vs Claude Translation' \
  'Do not expose upstream Claude agents as Codex skills' \
  'Do not rename it to `omitAgentsMd`' \
  'Model Mapping' \
  'gpt-5.5' \
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
  grep -Fq "$required" "$REFERENCE" || fail "checklist missing: $required"
done

if grep -Eq 'generate-agent-skills|agent-skills_test|generate-codex-agents|install-codex-agents|codex-agents_test|generated custom agents' "$SKILL" "$REFERENCE"; then
  fail "checklist must not reference removed agent generation paths"
fi

if [ -d "$ROOT/plugins/codex-elixir-phoenix/agents" ] && \
  grep -R -n -E 'omitClaudeMd|omitAgentsMd' "$ROOT/plugins/codex-elixir-phoenix/agents" >/dev/null; then
  fail "agent frontmatter must drop omitClaudeMd and must not invent omitAgentsMd"
fi

echo "upstream-sync validate: guardrails verified"
