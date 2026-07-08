#!/usr/bin/env bash
# Shared config for nf-release-registry scripts. Sourced by the others.
# Override via environment; placeholders must be replaced before use.

# GitHub org/owner that hosts all repos. e.g. akhlaquekarim
ORG="${BUNDLE_ORG:-REPLACE_ME_ORG}"

# Repos.
REGISTRY_REPO="${BUNDLE_REGISTRY_REPO:-nf-release-registry}"
FLUTTER_REPO="${BUNDLE_FLUTTER_REPO:-nf-app-flutter}"
NODE_REPO="${BUNDLE_NODE_REPO:-nf_node}"
PHP_REPO="${BUNDLE_PHP_REPO:-nikahforever}"

# Slack incoming webhook. Single-channel setup: everything posts to #qa-releases.
# SLACK_WEBHOOK_PRD falls back to SLACK_WEBHOOK_QA so ONE webhook drives all posts.
# (Set a separate SLACK_WEBHOOK_PRD only if you later split bundle notifications
# into their own channel.)
SLACK_WEBHOOK_QA="${SLACK_WEBHOOK_QA:-}"                      # #qa-releases
SLACK_WEBHOOK_PRD="${SLACK_WEBHOOK_PRD:-${SLACK_WEBHOOK_QA:-}}"

VALID_DOMAINS="onb pay act cht srch prof sup adm ml"

_require_org() {
  if [[ "$ORG" == "REPLACE_ME_ORG" || -z "$ORG" ]]; then
    echo "ERROR: set BUNDLE_ORG (e.g. export BUNDLE_ORG=akhlaquekarim)." >&2
    exit 2
  fi
}

# Post a plain-text message to a Slack webhook. No-op (prints) if webhook unset.
_slack() {
  local webhook="$1"; shift
  local text="$1"
  if [[ -z "$webhook" || "$webhook" == *"REPLACE_ME"* ]]; then
    echo "[slack skipped — webhook unset] $text" >&2
    return 0
  fi
  local payload
  payload="$(jq -n --arg t "$text" '{text:$t}')"
  curl -fsS -X POST -H 'Content-type: application/json' --data "$payload" "$webhook" >/dev/null \
    && echo "[slack posted]" >&2 || echo "[slack post failed]" >&2
}

# Print the branch/PR/label conventions for a given Bundle ID.
_print_conventions() {
  local id="$1"
  local domain_lc num
  domain_lc="$(echo "${id%%-*}" | tr '[:upper:]' '[:lower:]')"
  num="${id##*-}"
  cat <<EOF

  Use $id consistently across every repo you touch for this PRD:
    • Branch    : feature/${domain_lc}_${num}_<free-text>
    • PR title  : [$id] <what you changed>
    • Label     : bundle:$id   (auto-applied by CI — do not add by hand)

  Teammates JOIN this PRD by reusing $id (scripts/join-bundle.sh $id).
EOF
}
