# QA Brief — manual-pr-test-one-rs-trial (android v7.8.9)

_Generated 2026-07-13T08:14:50Z. Bundle label = primary scope; endpoint hints are advisory._
_Full detail: `release-manifest.json`._

**PRDs in this version:** 1 (ONE-RS-TRIAL)

## ✅ Scope complete — every merged Flutter PR is bundled

## Deployed backends
- nf_node: unknown (unknown)
- nikahforever: unknown (unknown)

## Bundles

### ONE-RS-TRIAL — READY ✅
- in-scope Flutter PRs: 5 | bundle PRs total: 126 | drift: unknown

**P0 (must test):**
  - [ ] Buy a plan end-to-end (Razorpay + UPI + IAP): price, order, success, entitlement unlocked
  - [ ] Fresh signup + OTP + WhatsApp login; existing-user login; forgot password
  - [ ] Exercise every screen whose API constant changed; confirm request/response contract
**P1 (should test):**
  - [ ] Open own + other profile, edit fields, premium upsell card renders
  - [ ] New-user onboarding + homepage best-match scroll/pagination
**P2 (nice to have):**
  - [ ] Proofread changed copy/labels
  - [ ] Visual check: light/dark, spacing, no overflow
**Code concerns:**
  - [ ] Check api_constant/api.dart for hardcoded URLs/IPs (several http://IP defaults exist)
  - [ ] Verify payment error handling + no double-charge on retry

## 15-minute regression smoke (every release)
- [ ] Login (password + OTP)
- [ ] Dashboard loads (matches, recommendations)
- [ ] Send/accept an interest
- [ ] Open a chat and send a message
- [ ] Open plans + start a payment (sandbox)
- [ ] Logout
