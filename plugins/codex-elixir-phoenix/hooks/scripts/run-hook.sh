#!/bin/sh
# Portable launcher for plugin-bundled hooks.
#
# Keep hooks/hooks.json POSIX-only so Codex does not fail with exit 127 when a
# runtime lacks /bin/bash or a plugin root alias differs across surfaces. The
# individual hook scripts use bash; if bash is unavailable, skip quietly instead
# of breaking every tool call.

script="${1:-}"
[ -n "$script" ] || exit 0

root="${PLUGIN_ROOT:-}"
[ -n "$root" ] || root="${CODEX_PLUGIN_ROOT:-}"
[ -n "$root" ] || root="${CLAUDE_PLUGIN_ROOT:-}"

if [ -z "$root" ]; then
  case "$0" in
    */hooks/scripts/run-hook.sh)
      script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd -P)
      root=$(CDPATH= cd -- "$script_dir/../.." 2>/dev/null && pwd -P)
      ;;
  esac
fi

[ -n "$root" ] || exit 0

target="$root/hooks/scripts/$script"
[ -r "$target" ] || exit 0

if command -v bash >/dev/null 2>&1; then
  exec bash "$target"
fi

exit 0
