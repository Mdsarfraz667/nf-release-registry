# nf-release-registry

Canonical home for **release Bundle IDs** (PRD ↔ cross-repo PR join keys).

This repo holds **no application code and is never deployed.** It exists so that
every PRD gets exactly one auto-incrementing, org-visible Bundle ID that developers
carry across `nf-app-flutter`, `nf_node`, and `nikahforever`.

See the workspace-root [`RELEASE_PLAYBOOK.md`](../RELEASE_PLAYBOOK.md) for the full
release-traceability design.

---

## Bundle ID format

```
<DOMAIN>-<4-digit issue number>      e.g. ONB-0043
```

- The number is the **GitHub issue number** in this repo, zero-padded to 4 digits.
  The issue number is the uniqueness source — no PM, no spreadsheet.
- **Domain codes:** `ONB PAY ACT CHT SRCH PROF SUP ADM ML`
  (onboarding, payment, activity, chat, search, profile, support, admin, ml).

## Carry it everywhere (all 3 app repos)

| Where     | Form                                   |
|-----------|----------------------------------------|
| Branch    | `feature/onb_0043_<free-text>`         |
| PR title  | `[ONB-0043] <what changed>`            |
| Label     | `bundle:ONB-0043` (auto-applied by CI) |

## Check-then-create rule

**One PRD = one Bundle ID.** Before minting a new ID, check for an existing open
bundle in the same domain and **join** it instead:

```bash
export BUNDLE_ORG=akhlaquekarim
export SLACK_WEBHOOK_QA='https://hooks.slack.com/...'   # #qa-releases (optional)

scripts/new-bundle.sh onb "Onboarding revamp — phone-first signup"   # first person
scripts/join-bundle.sh ONB-0043                                      # everyone else
```

`new-bundle.sh` lists existing open bundles for the domain and asks for confirmation
before creating (unless `--force`), then announces the new ID to `#qa-releases` so
teammates can claim/join instead of duplicating.

> **Duplicate-bundle race is NOT fully solved.** Two people creating an ID for the
> same PRD within the same claim window still produces two IDs. Mitigations: the
> Slack announcement + a short claim window, plus a periodic dedup review (warn when
> two OPEN issues share a domain and overlapping APIs). A hard lock is out of scope.

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/new-bundle.sh <domain> "<desc>" [--force]` | Mint a new Bundle ID (issue + label + Slack announce). |
| `scripts/join-bundle.sh <ID>` | Validate an existing bundle and announce that you joined. |

All scripts are `bash`, `set -euo pipefail`, with a config block for `ORG`/repos at the top.

## Daily unbundled report

`.github/workflows/daily-unbundled-report.yml` scans all 3 app repos for merged PRs
without a `bundle:*` label and posts to `#qa-releases` if any are found.
Requires `SLACK_WEBHOOK_QA` and `RELEASE_BOT_PAT` secrets on this repo.
