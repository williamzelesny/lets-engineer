#!/usr/bin/env bash
# Print the upstream `version` field from plugins/lets-engineer/.claude-plugin/plugin.json
# on the repository's default branch, or the literal sentinel
# `__LETS_UPDATE_VERSION_FAILED__` if the lookup fails.
#
# Reads the current default-branch HEAD (not a release tag) because the marketplace
# installs plugin contents from HEAD; comparing against tags false-positives whenever
# the branch is ahead of the last tag.
#
# The GitHub repo (owner/name) is derived from the installed plugin.json `repository`
# field rather than hardcoded, so forks and renames keep working. Falls back to the
# checkout's `origin` remote when the field is absent (e.g. local development).

set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plugin_root="${CLAUDE_PLUGIN_ROOT:-$(cd "$script_dir/../../.." && pwd)}"
plugin_json="$plugin_root/.claude-plugin/plugin.json"

fail() { echo '__LETS_UPDATE_VERSION_FAILED__'; exit 0; }

# 1) repository URL from plugin.json (no jq dependency)
repo_url=""
if [ -f "$plugin_json" ]; then
  repo_url=$(grep -oE '"repository"[[:space:]]*:[[:space:]]*"[^"]+"' "$plugin_json" \
    | sed -E 's/.*:[[:space:]]*"([^"]+)".*/\1/')
fi

# 2) fall back to the git checkout's origin remote
if [ -z "$repo_url" ]; then
  repo_url=$(git -C "$plugin_root" remote get-url origin 2>/dev/null || true)
fi

# Derive owner/repo with portable parameter expansion (no lazy regex — BSD sed safe).
case "$repo_url" in *github.com*) ;; *) fail ;; esac
slug="${repo_url#*github.com}"   # strip protocol + host
slug="${slug#[:/]}"              # strip leading ':' (ssh) or '/' (https)
slug="${slug%.git}"              # strip trailing '.git'
slug="${slug%/}"                 # strip trailing slash
case "$slug" in
  */*/*) fail ;;                 # more than owner/repo
  */*) : ;;                      # exactly owner/repo
  *) fail ;;
esac

command -v gh >/dev/null 2>&1 || fail

# `gh api` exits non-zero on HTTP errors (e.g. 404) but still writes the error
# body to stdout, so guard on the exit status AND sanity-check the result.
version=$(gh api "repos/$slug/contents/plugins/lets-engineer/.claude-plugin/plugin.json" \
  --jq '.content | @base64d | fromjson | .version' 2>/dev/null) || fail

case "$version" in
  [0-9]*.[0-9]*) echo "$version" ;;   # looks like a version string
  *) fail ;;                          # empty, error JSON, or anything unexpected
esac
