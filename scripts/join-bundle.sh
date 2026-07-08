#!/usr/bin/env bash
#
# join-bundle.sh — validate an existing Bundle ID and announce that you joined it.
#
# Usage:  scripts/join-bundle.sh <ID>        e.g. scripts/join-bundle.sh ONB-0043
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_config.sh
source "$SCRIPT_DIR/_config.sh"

ID="${1:-}"
if [[ -z "$ID" ]]; then
  echo "Usage: scripts/join-bundle.sh <ID>   e.g. ONB-0043" >&2
  exit 2
fi
_require_org

ID="$(echo "$ID" | tr '[:lower:]' '[:upper:]')"
if ! echo "$ID" | grep -Eq '^[A-Z]+-[0-9]{3,}$'; then
  echo "ERROR: '$ID' is not a valid Bundle ID (expected e.g. ONB-0043)." >&2
  exit 2
fi

# Validate: an OPEN or CLOSED registry issue whose title carries [ID].
MATCH="$(gh issue list --repo "$ORG/$REGISTRY_REPO" --label bundle-registry --state all \
  --search "in:title [$ID]" --json number,title,url,state \
  --jq ".[] | select(.title | startswith(\"[$ID]\")) | \"\(.url)\t\(.state)\"" 2>/dev/null | head -n1 || true)"

if [[ -z "$MATCH" ]]; then
  echo "ERROR: no registry bundle found for $ID." >&2
  echo "Create it first: scripts/new-bundle.sh <domain> \"<desc>\"" >&2
  exit 1
fi

URL="${MATCH%%$'\t'*}"
STATE="${MATCH##*$'\t'}"
echo "  ✔ Found bundle $ID ($STATE): $URL"

WHO="$(gh api user --jq .login 2>/dev/null || echo "someone")"
_slack "$SLACK_WEBHOOK_PRD" "👥 @$WHO joined bundle *$ID* — $URL"

_print_conventions "$ID"
