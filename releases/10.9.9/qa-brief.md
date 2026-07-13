# QA Brief — manual-pr-test-female-free-premium (android v10.9.9)

_Generated 2026-07-13T07:57:49Z. Bundle label = primary scope; endpoint hints are advisory._
_Full detail: `release-manifest.json`._

**PRDs in this version:** 1 (FEMALE-FREE-PREMIUM)

## ✅ Scope complete — every merged Flutter PR is bundled

## Deployed backends
- nf_node: unknown (unknown)
- nikahforever: unknown (unknown)

## Bundles

### FEMALE-FREE-PREMIUM — READY ✅
- in-scope Flutter PRs: 2 | bundle PRs total: 4 | drift: unknown

**P0 (must test):**
  - [ ] Buy a plan end-to-end (Razorpay + UPI + IAP): price, order, success, entitlement unlocked
  - [ ] Exercise every screen whose API constant changed; confirm request/response contract
**P1 (should test):**
  - [ ] Open own + other profile, edit fields, premium upsell card renders
  - [ ] New-user onboarding + homepage best-match scroll/pagination
**P2 (nice to have):**
  - [ ] Confirm analytics/Meta events fire (spot check, non-blocking)
  - [ ] Proofread changed copy/labels
  - [ ] Visual check: light/dark, spacing, no overflow
**Code concerns:**
  - [ ] Check api_constant/api.dart for hardcoded URLs/IPs (several http://IP defaults exist)
  - [ ] Verify payment error handling + no double-charge on retry
  - [ ] shared surface: nikahforever #3710 touches shared surface: application/controllers/V1.php (dashboard_information_post)

## 15-minute regression smoke (every release)
- [ ] Login (password + OTP)
- [ ] Dashboard loads (matches, recommendations)
- [ ] Send/accept an interest
- [ ] Open a chat and send a message
- [ ] Open plans + start a payment (sandbox)
- [ ] Logout
