#!/usr/bin/env bash
# Shared helpers for hooks that need to run in both Claude Code and Codex.

hook_project_dir() {
  local input="${1:-}"
  local cwd=""

  if [ -n "$input" ]; then
    cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
  fi

  printf '%s\n' "${cwd:-${CLAUDE_PROJECT_DIR:-${PWD}}}"
}

hook_tool_file_paths() {
  local input="$1"

  printf '%s' "$input" | jq -r '
    def string_values:
      if type == "string" then . else empty end;

    [
      .tool_input.file_path?,
      .tool_input.path?,
      (.tool_input.paths[]?),
      (.tool_input.files[]?),
      (
        .tool_input.command?
        | string_values
        | split("\n")[]
        | capture("^\\*\\*\\* (?:Add|Update|Delete) File: (?<path>.+)$")?
        | .path
      )
    ]
    | .[]
    | select(type == "string" and length > 0)
  ' 2>/dev/null | awk '!seen[$0]++'
}

hook_tool_failed() {
  local input="$1"
  local code status error

  code=$(
    printf '%s' "$input" | jq -r '
      .tool_response.exit_code?
      // .tool_response.exitCode?
      // .tool_response.code?
      // .tool_response.status_code?
      // empty
    ' 2>/dev/null | head -1
  )
  if [[ "$code" =~ ^-?[0-9]+$ ]] && [[ "$code" != "0" ]]; then
    return 0
  fi

  status=$(
    printf '%s' "$input" | jq -r '
      .tool_response.status?
      // .tool_response.result.status?
      // empty
    ' 2>/dev/null | head -1
  )
  case "$status" in
    failed|failure|error|errored) return 0 ;;
  esac

  error=$(
    printf '%s' "$input" | jq -r '
      .error?
      // .tool_response.error?
      // empty
    ' 2>/dev/null | head -1
  )
  [[ -n "$error" && "$error" != "null" ]]
}

hook_tool_error_text() {
  local input="$1"

  printf '%s' "$input" | jq -r '
    [
      .error?,
      .tool_response.stderr?,
      .tool_response.stdout?,
      .tool_response.output?,
      .tool_response.message?,
      (if (.tool_response | type) == "string" then .tool_response else empty end)
    ]
    | map(select(type == "string" and length > 0))
    | join("\n")
  ' 2>/dev/null
}

hook_created_path() {
  local input="$1"
  local path="$2"
  local command content

  content=$(printf '%s' "$input" | jq -r '.tool_input.content? // empty' 2>/dev/null)
  if [[ -n "$content" ]]; then
    return 0
  fi

  command=$(printf '%s' "$input" | jq -r '.tool_input.command? // empty' 2>/dev/null)
  [[ -n "$command" ]] && printf '%s\n' "$command" | grep -Fq "*** Add File: $path"
}
