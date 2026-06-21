#!/usr/bin/env bash
# Doctor probes for winter-github — diagnose gh CLI prerequisites for issue.
# Contract: workspace:/ai/winter-cli/setup.md#extension-doctor-probes
set -u

emit() {
  python3 -c '
import json, sys
o = {"name": sys.argv[1], "status": sys.argv[2]}
if sys.argv[3]: o["message"] = sys.argv[3]
if sys.argv[4]: o["remediation"] = sys.argv[4]
print(json.dumps(o))
' "$1" "$2" "${3:-}" "${4:-}"
}

strip_ansi() { sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g' <<<"${1:-}"; }
first_line() { printf '%s' "${1:-}" | head -n1; }

# Probe 1: gh binary present.
if gh_version=$(gh --version 2>/dev/null); then
  gh_present=1
  emit "gh binary" "pass" "$(first_line "$(strip_ansi "$gh_version")")"
else
  gh_present=0
  emit "gh binary" "fail" "gh CLI not found on PATH" \
       "Install gh: https://cli.github.com/manual/installation"
fi

# Probe 2: gh github.com auth — skip when the binary probe already failed.
# `gh auth status --hostname github.com` exits 0 only when logged in for that host.
if (( gh_present )); then
  if auth_status=$(gh auth status --hostname github.com 2>&1); then
    emit "gh github.com auth" "pass"
  else
    emit "gh github.com auth" "fail" "$(first_line "$(strip_ansi "$auth_status")")" \
         "Run \`gh auth login --hostname github.com\` (see ai/gh-cli.md)."
  fi
fi

# Probe 3: api.github.com reachable — 5s timeout; warn on network error.
# /zen is the canonical "is the API up?" endpoint; cheaper than /user (which also needs auth).
if err=$(curl -fsS --max-time 5 -o /dev/null https://api.github.com/zen 2>&1); then
  emit "api.github.com reachable" "pass"
else
  emit "api.github.com reachable" "warn" "$(first_line "${err:-curl failed}")"
fi

exit 0
