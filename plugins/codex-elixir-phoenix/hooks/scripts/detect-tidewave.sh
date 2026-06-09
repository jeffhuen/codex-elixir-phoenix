#!/usr/bin/env bash
# SessionStart hook: Check if Tidewave MCP server is running
input="$(cat 2>/dev/null || true)"
proj="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$proj" ] || proj="$PWD"
[ -f "$proj/mix.exs" ] || exit 0

data_dir="${PLUGIN_DATA:-${TMPDIR:-/tmp}/codex-elixir-phoenix-hooks}"
state_dir="$data_dir/session-start"

if command -v shasum >/dev/null 2>&1; then
  project_key="$(printf '%s' "$proj" | shasum -a 256 | awk '{print $1}')"
else
  project_key="$(printf '%s' "$proj" | cksum | awk '{print $1}')"
fi

if curl -s --connect-timeout 2 http://localhost:4000/tidewave/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"ping"}' 2>/dev/null | grep -q "result"; then
  status="available"
  message="✓ Tidewave MCP available — prefer mcp__tidewave__project_eval over mix eval/test, mcp__tidewave__get_docs over WebSearch for Elixir docs, mcp__tidewave__execute_sql_query over psql"
else
  status="missing"
  message="○ Tidewave not detected — start Phoenix server with Tidewave for runtime tools"
fi

if mkdir -p "$state_dir" 2>/dev/null; then
  state_file="$state_dir/tidewave-$project_key"
  ttl="${CODEX_ELIXIR_PHOENIX_TIDEWAVE_NOTICE_TTL:-600}"
  now="$(date +%s)"

  if [ -r "$state_file" ]; then
    read -r last_ts last_status < "$state_file" || true
    if [[ "$last_ts" =~ ^[0-9]+$ ]] &&
      [[ "$ttl" =~ ^[0-9]+$ ]] &&
      [[ "$last_status" == "$status" ]] &&
      ((now - last_ts < ttl)); then
      exit 0
    fi
  fi

  printf '%s %s\n' "$now" "$status" > "$state_file" 2>/dev/null || true
fi

echo "$message"
