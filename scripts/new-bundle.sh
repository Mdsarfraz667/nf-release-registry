#!/usr/bin/env bash
#
# new-bundle.sh — mint a canonical release Bundle ID in nf-release-registry.
#
# The GitHub issue number (zero-padded to 4) is the uniqueness source.
# Announces to #prd-releases BEFORE creating so teammates can claim/join instead
# of duplicating (the duplicate-bundle race is mitigated, not fully solved).
#
# Usage:
#   scripts/new-bundle.sh <domain> "<short description>" [--force]
#   e.g. scripts/new-bundle.sh onb "Onboarding revamp — phone-first signup"
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_config.sh
source "$SCRIPT_DIR/_config.sh"

FORCE=0
DOMAIN=""
DESC=""
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    *) if [[ -z "$DOMAIN" ]]; then DOMAIN="$arg"; elif [[ -z "$DESC" ]]; then DESC="$arg"; fi ;;
  esac
done

if [[ -z "$DOMAIN" || -z "$DESC" ]]; then
  echo "Usage: scripts/new-bundle.sh <domain> \"<short description>\" [--force]" >&2
  echo "Domains: $VALID_DOMAINS" >&2
  exit 2
fi
_require_org

DOMAIN="$(echo "$DOMAIN" | tr '[:upper:]' '[:lower:]')"
if ! echo " $VALID_DOMAINS " | grep -q " $DOMAIN "; then
  echo "ERROR: '$DOMAIN' is not a valid domain. Use one of: $VALID_DOMAINS" >&2
  exit 2
fi
DOMAIN_UPPER="$(echo "$DOMAIN" | tr '[:lower:]' '[:upper:]')"

# Check-then-create: show existing OPEN bundles in this domain.
echo "Existing OPEN $DOMAIN_UPPER bundles (join one of these if your PRD already has an ID):" >&2
EXISTING="$(gh issue list --repo "$ORG/$REGISTRY_REPO" --label bundle-registry --state open \
  --search "in:title [$DOMAIN_UPPER-" --json number,title,url \
  --jq '.[] | "  #\(.number)  \(.title)  \(.url)"' 2>/dev/null || true)"
if [[ -n "$EXISTING" ]]; then echo "$EXISTING" >&2; else echo "  (none)" >&2; fi
echo "" >&2

if [[ "$FORCE" -ne 1 ]]; then
  read -r -p "Create a NEW $DOMAIN_UPPER bundle for: \"$DESC\" ? [y/N] " ans
  case "$ans" in
    y|Y|yes|YES) ;;
    *) echo "Aborted. Use scripts/join-bundle.sh <ID> to join an existing bundle." >&2; exit 0 ;;
  esac
fi

# Announce claim window to #prd-releases BEFORE creating (dedup mitigation).
_slack "$SLACK_WEBHOOK_PRD" "🟡 Claiming a new *$DOMAIN_UPPER* bundle: \"$DESC\" — if this PRD already has a Bundle ID, reply now."

# Create the issue; its number becomes the bundle number.
ISSUE_URL="$(gh issue create --repo "$ORG/$REGISTRY_REPO" \
  --title "TEMP new bundle: $DESC" \
  --label "bundle-registry" \
  --body "Domain: $DOMAIN_UPPER
Description: $DESC
(Bundle ID is derived from this issue number.)")"

ISSUE_NUM="$(basename "$ISSUE_URL")"
BUNDLE_NUM="$(printf '%04d' "$ISSUE_NUM")"
BUNDLE_ID="${DOMAIN_UPPER}-${BUNDLE_NUM}"

# Canonical title + a self-label so collectors can find it by bundle:<ID>.
gh issue edit "$ISSUE_NUM" --repo "$ORG/$REGISTRY_REPO" \
  --title "[$BUNDLE_ID] $DESC" \
  --add-label "bundle:$BUNDLE_ID" >/dev/null 2>&1 || \
  gh issue edit "$ISSUE_NUM" --repo "$ORG/$REGISTRY_REPO" --title "[$BUNDLE_ID] $DESC" >/dev/null

_slack "$SLACK_WEBHOOK_PRD" "✅ Bundle *$BUNDLE_ID* created: $DESC — $ISSUE_URL"

echo ""
echo "  ✅ Bundle created: $BUNDLE_ID   ($ISSUE_URL)"
_print_conventions "$BUNDLE_ID"
