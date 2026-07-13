# QA Agent Report — manual-pr-test-one-rs-trial (android v7.8.9)

_Generated 2026-07-13T08:11:33Z. Deterministic facts from release-manifest.json; LLM enrichment for flows and code review._

**PRDs in this version:** 1 (ONE-RS-TRIAL)

## ⚠️ Unbundled PRs (from manifest — not LLM)
✅ none

## 🚨 Drift (from manifest — not LLM)
✅ none

## Deployed backends
- nf_node: unknown (unknown)
- nikahforever: unknown (unknown)

---

### ONE-RS-TRIAL — READY ✅

Flutter PRs for ₹1 trial are merged to staging while PHP trial logic is merged to master with deploy SHA unknown, so QA must verify cross-repo alignment in the deployed environment before sign-off.

**Assumptions (confirm with dev):**
- Exact API paths used by Flutter for get/start/dismiss trial are not shown in the prompt; confirm the concrete V1.php endpoint names from lib/utils/network/api_constant_new.dart or request logs before running API-level checks.
- Exact navigation path to the profile card and onboarding ₹1 plan screen is inferred from changed file names one_rs_trial_plan_card.dart and onboarding_one_rs_trial_plan_screen.dart; confirm final tap path with dev if the screen is not directly reachable in QA build.
- Exact minimum app build/version threshold for eligibility is not stated in the spec text; use backend response behavior and compare eligible vs ineligible builds rather than inventing a number.
- Exact ML percent threshold value is hinted by backend PRs around 40 but not stated in the spec block; isolate the ML % gate using backend fixtures or DB setup rather than assuming a hardcoded threshold in expected text.
- Exact recurring charge amount and schedule timestamp formula after the ₹1 trial are not fully specified in the prompt; verify that a deferred recurring record exists and that no immediate full renewal happens during trial, then confirm actual next_payment value against deployed Payment_model behavior.
- No analytics event names for the ₹1 trial flow are provided in the diff/spec excerpt; instrumentation lifecycle category is waived as event identifiers are not available to test precisely.
- No explicit error codes are documented for trial APIs in the prompt; error-path coverage is limited to observable blocked/hidden states and payment failure handling rather than named backend error codes.
- No version-gated response field names are shown; backward-compat coverage is limited to testing eligible vs ineligible app builds and ensuring older build gets no trial UI rather than asserting exact payload schema deltas.
- No storage/S3 write path is shown for this bundle; data verification is DB-only.
- Changed non-trial files under auto dialer, sales target, V2, religious/contact/profile detail, photo cropper, and settings appear in the release diff but are not described by the spec; the plan includes smoke/regression checks for those surfaces without assuming new business behavior.

#### Requirement coverage (deterministic)

**Requirements walked:** 18 total, 18 covered, 0 uncovered.

#### Spec coverage (model self-report)

_Model self-report — not independently verified. The authoritative check is **Requirement coverage (deterministic)** (when a spec was extracted)._

**Spec requirements walked (model claim):** 16 total, 16 covered, 0 uncovered.

#### What to test

**P0 (must test):**
- [ ] **Verify existing paid checkout still works end-to-end and is not replaced by the ₹1 trial for OUT users** — _Payment regression is P0 and must be checked before new trial behavior._
  **Steps:**
  1. Use an OUT-of-cohort account that fails only the member_id > 2818600 gate or an older build gate so the ₹1 trial should not appear.
  2. Open the plans flow from the existing purchase entry point and trigger checkout from lib/core/reusable_widget/plan_buy_now_button.dart.
  3. Complete a normal paid plan purchase in custom_payment_screen.dart / custom_checkout_bottom_sheet.dart.
  4. Confirm premium access is granted and no free trial UI appears on Home or Profile after purchase.
  **Expected:** Normal paid plan purchase still succeeds; the ₹1 trial does not hijack the checkout path for an ineligible user.
  **Regression risk:** Shared payment widgets plan_buy_now_button.dart, plan_buy_now_checkout.dart, custom_payment_screen.dart, and Payment_model.php could break standard monetization.
  **References:** lib/core/reusable_widget/plan_buy_now_button.dart, lib/core/reusable_widget/plan_buy_now_checkout.dart, lib/view/screens/plans/custom_payment_screen.dart, application/models/Payment_model.php

- [ ] **Verify eligible IN cohort sees Home banner via trial_offer_banner_top and synced trial_offer_ends_countdown_line** — _This is the primary acquisition surface for the experiment and a broken banner hides the offer from eligible users._
  **Steps:**
  1. Log in with an eligible IN-cohort Android account on a qualifying build and member_id at or below the cap.
  2. Open Home and confirm the top banner from lib/features/free_trial_start/presentation/widgets/trial_offer_banner_top.dart is visible.
  3. Confirm the countdown line from trial_offer_ends_countdown_line.dart is visible under the banner.
  4. Background/foreground the app and reopen Home to confirm the banner and countdown persist without duplicate rendering.
  **Expected:** Eligible user sees the ₹1 trial home banner and countdown line consistently on Home.
  **Regression risk:** dashboardcontroller.dart, homepage_screen.dart, homepage_header.dart, and offer_banner_new.dart changes can break home rendering or banner placement.
  **References:** lib/features/free_trial_start/presentation/widgets/trial_offer_banner_top.dart, lib/features/free_trial_start/presentation/widgets/trial_offer_ends_countdown_line.dart, lib/controller/dashboardcontroller.dart, lib/controller/header_countdown_view_model.dart

- [ ] **Verify eligible IN cohort sees the home trial popup and can dismiss/reopen consistently** — _A broken popup can spam users or block the acquisition funnel._
  **Steps:**
  1. Using the same eligible account, open Home fresh after login and wait for the popup from trial_experiment_home_popups.dart.
  2. Dismiss the popup once using the app control wired through dismiss_trial_popup_use_case.dart.
  3. Navigate away and back to Home, then relaunch the app to confirm popup state behavior is stable for the same account/session.
  4. If backend allows reset, clear the popup state for the account and confirm the popup can appear again when expected.
  **Expected:** Popup appears for eligible users, dismisses cleanly, and does not flicker or reappear unexpectedly within the same state window.
  **Regression risk:** Popup state bugs were explicitly fixed in backend/Common_model and Flutter BLoC/provider layers.
  **References:** lib/features/free_trial_start/presentation/widgets/trial_experiment_home_popups.dart, lib/features/free_trial_start/domain/use_cases/dismiss_trial_popup_use_case.dart, lib/features/free_trial_start/presentation/bloc/start_trial_bloc.dart, application/models/Common_model.php

- [ ] **Verify onboarding_one_rs_trial_plan_screen.dart shows the ₹1 trial path for an eligible new/onboarding user** — _Spec explicitly requires onboarding as a separate user path; if broken, new users cannot acquire the trial._
  **Steps:**
  1. Use an eligible onboarding account and proceed through onboarding until the plan selection step that reaches lib/view/screens/plans/onboarding_one_rs_trial_plan_screen.dart.
  2. Confirm the ₹1 trial plan is shown as a separate onboarding path and is not replaced by the regular registerplan.dart flow.
  3. Tap through the onboarding trial CTA and confirm it routes into the same checkout stack used by plan_buy_now_button.
  4. Return/back out once and re-enter to confirm the screen state does not duplicate or lose the offer.
  **Expected:** Eligible onboarding user sees the dedicated ₹1 trial plan screen and can continue into checkout without navigation errors.
  **Regression risk:** OnboardingBloc, registerplan.dart, and routes changes can break registration monetization.
  **References:** lib/view/screens/plans/onboarding_one_rs_trial_plan_screen.dart, lib/view/screens/plans/registerplan.dart, lib/features/onboarding/presentation/bloc/onboarding_bloc.dart

- [ ] **Verify one_rs_trial_plan_card.dart shows the same ₹1 trial offer state on Profile as Home** — _Spec requires Profile as a separate path; inconsistent state here causes conflicting offers._
  **Steps:**
  1. Log in with an eligible account and open the profile page screen that renders lib/features/profilepage/presentation/screens/components/one_rs_trial_plan_card.dart.
  2. Confirm the ₹1 trial card is visible and not replaced by premium_plan_card.dart for an eligible non-premium user.
  3. Compare the offer text/countdown state with Home banner state for the same account.
  4. Tap the profile card CTA and confirm it routes to the same checkout flow as Home.
  **Expected:** Profile page shows the ₹1 trial card for eligible users and its state matches Home for the same account.
  **Regression risk:** profile_page_cubit.dart and profile_page_screen.dart changes can desync profile monetization from dashboard state.
  **References:** lib/features/profilepage/presentation/screens/components/one_rs_trial_plan_card.dart, lib/features/profilepage/presentation/screens/components/premium_plan_card.dart, lib/features/profilepage/presentation/screens/profile_page_screen.dart

- [ ] **Verify plan_buy_now_button and custom_payment_screen charge ₹1 list price and start trial without breaking normal plan purchase** — _Wrong amount or failed entitlement is a direct payment defect._
  **Steps:**
  1. From any eligible entry point, tap the CTA wired through lib/core/reusable_widget/plan_buy_now_button.dart.
  2. On the checkout UI, confirm the displayed list price is exactly ₹1 and not a rounded or full recurring amount.
  3. Complete the Razorpay/custom UI payment flow and wait for success handling.
  4. After success, reopen Home/Profile and confirm the user is in trial state with premium access unlocked.
  **Expected:** Checkout shows ₹1, payment succeeds, and the account enters trial state immediately.
  **Regression risk:** Price formatting, amount key, and recurring token handling changed across Payment_model.php and Flutter checkout widgets.
  **References:** lib/core/reusable_widget/plan_buy_now_button.dart, lib/view/screens/plans/custom_payment_screen.dart, lib/utils/custom_payment_util/custom_checkout_bottom_sheet.dart, application/models/Payment_model.php

- [ ] **Verify ₹1 trial start creates free_membership_trail state and does not break existing paid checkout** — _This is the core entitlement path and a broken state transition causes revenue leakage or user lockout._
  **Steps:**
  1. Complete a successful ₹1 trial purchase with an eligible account.
  2. Immediately verify in app that premium/trial benefits are active.
  3. Then attempt to open the plans page again and confirm the app reflects active trial state instead of offering duplicate immediate enrollment.
  4. Keep the member_id for the post-flow DB checks in free_membership_trail, active_recurring, and razorpay_payments_recurring.
  **Expected:** Trial starts once, benefits unlock, and the app does not behave as if the user is still unenrolled.
  **Regression risk:** State handoff between V1.php, Common_model.php, Payment_model.php, dashboardcontroller.dart, and dashbaordmodel.dart can fail after payment success.
  **References:** application/controllers/V1.php, application/models/Common_model.php, application/models/Payment_model.php, lib/model/dashbaordmodel.dart

- [ ] **Verify recurring billing is deferred after ₹1 trial and no immediate full renewal is triggered** — _Wrong timing of recurring billing is a P0 overcharge risk._
  **Steps:**
  1. Start a ₹1 trial on an eligible account and capture the created recurring identifiers from DB/logs.
  2. Check the account remains in trial state during the initial period and is not charged the full recurring amount immediately after the ₹1 payment.
  3. Inspect active_recurring and related recurring records to confirm a future next_payment/scheduled state exists rather than an immediate renewal execution.
  4. If cron can be run in QA, trigger the relevant recurring/unpause path only after setting a due timestamp and confirm behavior matches deferred scheduling.
  **Expected:** A deferred recurring schedule exists, but no immediate full renewal happens during the trial window.
  **Regression risk:** Payment_model.php and Cron.php changed around pause/unpause, next payment calculation, and deferred charging.
  **References:** application/models/Payment_model.php, application/controllers/Cron.php, active_recurring, razorpay_payments_recurring

- [ ] **Verify cancel flow clears ₹1 trial state and downgrades access immediately** — _Cancellation bugs can leak premium access or leave billing state inconsistent._
  **Steps:**
  1. Use an account currently in ₹1 trial with recurring state created.
  2. Cancel the subscription using the app/backend path that hits the cancellation logic in Payment_model.php or V1.php.
  3. Refresh Home/Profile and confirm trial UI no longer shows active entitlement and premium-only sections are revoked.
  4. Confirm the account does not remain active in a half-cancelled state after logout/login.
  **Expected:** Cancellation clears trial state, downgrades access immediately, and the account does not retain premium benefits.
  **Regression risk:** Instant downgrade and cancel flags were changed in PRs #3387 and #3401.
  **References:** application/models/Payment_model.php, application/controllers/V1.php, free_membership_trail, active_recurring, member.cancel

- [ ] **Force only the ML % gate to fail and confirm no trial_offer_banner_top, no home popup, and no one_rs_trial_plan_card** — _Spec requires isolated gate testing; a leak here contaminates the experiment/control split._
  **Steps:**
  1. Prepare an account that passes build and member_id gates but fails only the ML % eligibility condition in backend data.
  2. Log in on Android and open Home and Profile.
  3. Confirm trial_offer_banner_top, trial_experiment_home_popups, and one_rs_trial_plan_card are all absent.
  4. Open the plans flow and confirm no ₹1 checkout path is exposed.
  **Expected:** Failing only ML % removes all ₹1 trial UI while the rest of the app remains usable.
  **Regression risk:** Eligibility logic is split across Flutter_api.php, V1.php, Common_model.php, and dashboard parsing.
  **References:** application/controllers/Flutter_api.php, application/controllers/V1.php, application/models/Common_model.php

- [ ] **Force only the app build gate to fail and confirm V1/Flutter_api return no ₹1 trial UI for the older build** — _Version gating errors either hide the feature from all users or expose it to unsupported clients._
  **Steps:**
  1. Use an account that passes ML % and member_id gates, but run the app on a build below the deployed eligibility threshold.
  2. Log in and load dashboard/home data from V1.php / Flutter_api.php.
  3. Confirm no home banner, no popup, no onboarding trial screen, and no profile card are shown.
  4. Repeat with the qualifying build for the same account and confirm the trial UI appears, proving the build gate is the only difference.
  **Expected:** Older build gets no ₹1 trial UI; qualifying build for the same eligible account gets the offer.
  **Regression risk:** Build gating was changed multiple times in backend PRs and can easily drift from Flutter expectations.
  **References:** application/controllers/V1.php, application/controllers/Flutter_api.php, PR #3326, PR #3351, PR #3532, PR #3557

- [ ] **Force only the member_id > 2818600 cohort cap to fail and confirm new enrollment is blocked everywhere** — _Spec explicitly calls out the cap; leaking beyond the cap is a P0 experiment integrity issue._
  **Steps:**
  1. Prepare two otherwise identical eligible Android accounts: one with member_id at or below 2818600 and one with member_id above 2818600.
  2. Open Home, Profile, and onboarding/plan entry points for both accounts.
  3. Confirm the lower member_id account sees the ₹1 trial UI while the higher member_id account sees none of the trial surfaces.
  4. Attempt direct checkout on the higher member_id account and confirm backend blocks new enrollment.
  **Expected:** The cohort cap blocks all new ₹1 trial exposure and enrollment for member_id > 2818600.
  **Regression risk:** Cap logic was added late and may be enforced on some surfaces but not others.
  **References:** application/controllers/V1.php, application/controllers/Flutter_api.php, PR #3590

- [ ] **Attempt to claim the ₹1 trial twice and confirm free_membership_trail / active_recurring are not extended or duplicated** — _Idempotency failure can double-grant benefits or corrupt billing state._
  **Steps:**
  1. Use an eligible account and complete one successful ₹1 trial purchase.
  2. Immediately retry the same CTA from Home/Profile or repeat the start-trial API call from the app/network tool before state fully settles.
  3. Observe the app response and then inspect DB rows for free_membership_trail, active_recurring, package_payment_recurring, and razorpay_payments_recurring.
  4. Compare timestamps/row counts before and after the second attempt.
  **Expected:** Second claim does not create a second trial, does not extend the trial window, and does not duplicate recurring records.
  **Regression risk:** Multiple insert/update paths exist across V1.php, Common_model.php, and Payment_model.php.
  **References:** free_membership_trail, active_recurring, package_payment_recurring, razorpay_payments_recurring

- [ ] **Force concurrent ₹1 trial starts from two sessions and confirm only one enrollment wins atomically** — _Concurrency bugs in payment enrollment are P0 because they can double-charge or double-grant._
  **Steps:**
  1. Log in to the same eligible account on two devices or one device plus API replay tooling.
  2. Trigger the ₹1 trial start from both sessions as close together as possible.
  3. Observe both client responses and then inspect free_membership_trail and recurring tables.
  4. Refresh both clients and confirm they converge to one consistent trial state.
  **Expected:** Only one trial enrollment is persisted; no split-brain state, duplicate recurring rows, or conflicting UI states remain.
  **Regression risk:** Shared V1.php/Common_model.php/Payment_model.php write paths are vulnerable to race conditions.
  **References:** application/controllers/V1.php, application/models/Common_model.php, application/models/Payment_model.php

**P1 (should test):**
- [ ] **Verify Home navigation, bottom navigation, and dashboard load still work when trial widgets are present or absent** — _This is a broad regression area but not as severe as payment failure._
  **Steps:**
  1. Log in with one eligible account and one ineligible account.
  2. Navigate across Home, Profile, and other bottom-nav tabs using new_bottom_navigation_bar.dart and bottom_nav_selected_tab_indicator.dart.
  3. Return to Home repeatedly and confirm dashboard data, header, and offer areas render without blank states or crashes.
  4. Confirm navigation.dart does not duplicate popup/banner overlays.
  **Expected:** Core navigation and dashboard rendering work for both trial-visible and trial-hidden users.
  **Regression risk:** dashboardcontroller.dart, navigation.dart, homepage_screen.dart, and navigation_provider.dart were all touched.

- [ ] **Verify header_countdown_view_model keeps header countdown in sync with plan page and home countdown** — _Countdown mismatch confuses users and can cause false urgency or expired offers._
  **Steps:**
  1. Use an eligible account with visible trial countdown.
  2. Compare the countdown shown in the homepage header, trial_offer_ends_countdown_line, and the plan/profile surfaces.
  3. Background the app for a few minutes, reopen it, and compare all countdowns again.
  4. If possible, change device time only in a controlled QA environment and confirm the app re-syncs from backend state rather than drifting permanently.
  **Expected:** All visible countdowns stay aligned for the same account and recover cleanly after app resume.
  **Regression risk:** Timer fixes were made in both Flutter and Common_model backend logic.

- [ ] **Verify trial_offer_banner_top, home popup, onboarding_one_rs_trial_plan_screen, and one_rs_trial_plan_card show matching ₹1 offer details for the same account** — _Inconsistent acquisition surfaces create support issues and broken funnels._
  **Steps:**
  1. Use one eligible account and visit Home banner, Home popup, onboarding plan screen if reachable, and Profile card.
  2. Compare price text, trial wording, CTA intent, and countdown state across all four entry points.
  3. Trigger checkout from two different entry points and confirm both land in the same ₹1 checkout behavior.
  4. Note any mismatch in copy, price, or active/expired state.
  **Expected:** All user paths present the same ₹1 offer semantics and route to the same checkout outcome.
  **Regression risk:** Spec explicitly says not to collapse paths; separate widgets may drift.

- [ ] **Verify the home popup dismiss state survives logout/login and does not leak between accounts** — _State leakage is a common regression in account-scoped experiments._
  **Steps:**
  1. Dismiss the popup for eligible Account A.
  2. Log out using lib/utils/logout.dart, then log back into Account A and confirm the popup state matches expected persisted behavior.
  3. Log into eligible Account B on the same device and confirm Account A's dismissed state does not suppress Account B's popup incorrectly.
  4. Return to Account A and confirm its state is unchanged.
  **Expected:** Popup state is account-scoped and stable across logout/login.
  **Regression risk:** singleton.dart, logout.dart, and popup state handling changed.

- [ ] **Verify OUT-of-cohort control users get nothing even when they otherwise look eligible except for the isolated failed gate** — _Control contamination makes the rollout unmeasurable and invalidates cohort gating._
  **Steps:**
  1. Prepare separate accounts that each fail exactly one gate: ML %, build, and member_id cap.
  2. For each account, open Home, Profile, and plan entry points.
  3. Confirm no banner, no popup, no onboarding trial screen, and no profile card appear.
  4. Confirm the rest of the dashboard and plan pages still load normally.
  **Expected:** Control/off-arm users receive no ₹1 trial UI or enrollment path, with no collateral breakage.
  **Regression risk:** Experiment integrity can be broken by one surface still reading stale eligibility.

- [ ] **Verify the member_id boundary at 2818600 behaves correctly on both sides of the cap** — _Boundary bugs are common and directly affect who gets the experiment._
  **Steps:**
  1. Use one account with member_id exactly 2818600 and one with 2818601, keeping other eligibility factors equal.
  2. Open Home and Profile for both accounts.
  3. Attempt to reach checkout from any exposed CTA.
  4. Record whether the exact-boundary account is allowed and the above-boundary account is blocked.
  **Expected:** Boundary behavior is deterministic and matches the cap rule without off-by-one leakage.
  **Regression risk:** Late cap changes are prone to > vs >= mistakes.

- [ ] **Verify trial expiry/teardown behavior after the countdown ends and confirm UI removes active trial surfaces** — _Expiry bugs create entitlement leakage or stale UI._
  **Steps:**
  1. Use a trial account whose timer_end/countdown_end can be shortened in QA or wait for a naturally expiring test account.
  2. Observe Home/Profile before expiry, then after expiry refresh dashboard data.
  3. Confirm premium access and active trial messaging are removed or replaced appropriately.
  4. Confirm the app does not keep showing an expired countdown or active CTA.
  **Expected:** Expired trial state tears down cleanly in UI and access state.
  **Regression risk:** Timer and state fields were changed in Common_model.php and header_countdown_view_model.dart.

- [ ] **Verify start_trial_remote_data_source.dart and trial_plan_response models handle missing trial data without crashing ineligible users** — _This is a core stability regression for all non-eligible users._
  **Steps:**
  1. Use an ineligible account where backend should return no trial payload.
  2. Open Home, Profile, and plan-related screens that parse dashbaordmodel.dart and trial_plan_response.dart.
  3. Watch logs for parsing exceptions and confirm the app remains usable.
  4. Repeat after clearing app state to ensure no cached trial payload is required.
  **Expected:** No null/parsing crash occurs when trial data is absent.
  **Regression risk:** New models and repository code can assume trial fields always exist.

- [ ] **Verify shared V1.php/Common_model.php changes did not break dashboard_information and homepage rendering for non-trial users** — _Shared API regressions are high-frequency even when the feature is unrelated._
  **Steps:**
  1. Use a normal non-trial account and load the app fresh.
  2. Confirm dashboard counts, homepage header, and offer_banner_new/homepage_header areas render normally.
  3. Open Profile and another profile detail page to ensure shared member payload still parses.
  4. Check logs for backend 5xx or missing-key errors.
  **Expected:** Non-trial users can still load dashboard and profile surfaces without trial-related API breakage.
  **Regression risk:** V1.php and Common_model.php are shared surfaces with broad blast radius.

- [ ] **Verify profile detail and otherprofile screens still render religious/contact sections after shared model changes** — _Profile viewing is core app behavior and a likely collateral regression._
  **Steps:**
  1. Open another member's profile detail page from search or a known entry point.
  2. Scroll through profile_detail_list_page.dart and confirm relegious_section.dart and contact_section.dart render normally.
  3. Repeat with a trial-active account and a non-trial account.
  4. Watch for layout or null-data issues.
  **Expected:** Other profile detail screens still work and are unaffected by dashboard/user model changes.
  **Regression risk:** usermodel.dart and shared profile files changed in the same release.

- [ ] **Verify onboarding_bloc and complete_status_profile_model changes did not break photo-upload-to-plan progression** — _This is a core funnel regression, but not a direct payment correctness issue._
  **Steps:**
  1. Use a fresh onboarding account and proceed through onboarding until photo upload and plan selection.
  2. Upload a photo via upload_single_photo_screen.dart and continue forward.
  3. Confirm the flow reaches either onboarding_one_rs_trial_plan_screen.dart for eligible users or the normal plan path for ineligible users.
  4. Ensure no dead-end or repeated step occurs.
  **Expected:** Onboarding progression from photo upload into plan selection still works.
  **Regression risk:** Onboarding and photo-upload files changed alongside the trial plan insertion.

- [ ] **Verify settings/logout/login cycle does not leave stale ₹1 trial UI cached in singleton.dart** — _Session leakage causes false eligibility exposure._
  **Steps:**
  1. Log in with an eligible account and confirm trial UI is visible.
  2. Log out from settings.dart using the normal logout path.
  3. Log in with an ineligible account on the same device.
  4. Confirm no stale banner/popup/profile card from the previous account remains.
  **Expected:** Trial UI is recalculated per account and not cached across sessions.
  **Regression risk:** singleton.dart and logout.dart changed; stale singleton state is plausible.

- [ ] **Verify [Backend QA tool] application/controllers/Test.php compare endpoint logic for forced recurring does not regress trial backend routes** — _Backend QA tooling is useful here and shared controller changes deserve a smoke check._
  **Steps:**
  1. Open the deployed backend path /test/check_forced_recurring_assisted/{member_id} for a known Android India member and a known ineligible member.
  2. Confirm the endpoint returns plain 1 or 0 and does not error.
  3. Then open the app and verify normal ₹1 trial dashboard/home APIs still work for a trial test account.
  4. Check that adding Test.php changes did not break shared controller routing or auth middleware.
  **Expected:** Test.php endpoint works as documented and shared backend routing remains healthy for the app.
  **Regression risk:** Test.php changed in the same backend bundle and can expose routing/config regressions.

- [ ] **Verify application/controllers/V2.php changes did not break the app by accidentally switching plan/trial calls away from V1.php** — _Versioning regressions are important but secondary to direct payment correctness._
  **Steps:**
  1. Run the app through Home, Profile, and checkout entry points while capturing network traffic.
  2. Confirm the ₹1 trial and dashboard calls still hit the expected V1/legacy endpoints rather than failing due to V2 changes.
  3. Open a non-trial screen that may use shared auth/session state and confirm it still works.
  4. Note any unexpected 404/401/schema mismatch tied to V2.php.
  **Expected:** The app continues to function with its expected API versioning and no accidental V2 contract break.
  **Regression risk:** V2.php and shared API docs changed in the same release.

- [ ] **Verify auto-dialer and sales-target backend additions did not degrade app login/home performance or error rate** — _Broad release bundles often fail outside the target feature; this is a prudent smoke check._
  **Steps:**
  1. Log in and load Home several times while watching backend logs for unrelated fatal errors from A3b1.php, Ml.php, Cron.php, Sales_target_service.php, or Home.php.
  2. Confirm no 500s are emitted during normal app use.
  3. If admin QA access exists, open one sales target page and one web dialer page to confirm they at least render.
  4. Return to the app and confirm no session impact.
  **Expected:** Unrelated backend additions do not introduce global errors that affect the app.
  **Regression risk:** Large backend bundle includes many non-trial controllers and models.

**P2 (nice to have):**
- [ ] **Verify ₹1 trial copy is consistent across app_home_trial_text.dart, banner, popup, profile card, and checkout strike-price widgets** — _Copy issues are lower severity but likely in this bundle._
  **Steps:**
  1. Open all visible ₹1 trial surfaces for one eligible account.
  2. Compare the wording in app_home_trial_text.dart-driven labels, popup text, profile card, and diagonal_strike_price_text.dart/mini_plan_figma_bottom_sheet.dart.
  3. Check for 'trail' vs 'trial', inconsistent duration wording, or mismatched CTA labels.
  4. Capture screenshots of any copy mismatch.
  **Expected:** Copy is consistent and user-facing text does not contradict itself across surfaces.
  **Regression risk:** Several PRs explicitly changed text and headings.

- [ ] **Verify one_rs_trial_plan_card_shimmer and loading states do not flash indefinitely** — _This is polish unless it blocks interaction._
  **Steps:**
  1. Throttle network on an eligible account and open the profile page.
  2. Observe one_rs_trial_plan_card_shimmer.dart while data loads.
  3. Confirm the shimmer resolves to the real card or disappears cleanly when ineligible.
  4. Repeat after app resume.
  **Expected:** Loading placeholders resolve correctly and do not remain stuck.
  **Regression risk:** New profile card loading state was added.

- [ ] **Verify custom_premium_popup and offer_banner_new styling does not overlap the ₹1 trial banner/popup on small screens** — _Visual issues are P2 unless they block checkout._
  **Steps:**
  1. Use a smaller Android device or emulator.
  2. Open Home with an eligible account and trigger any premium popup/banner combinations reachable in QA.
  3. Check for overlap, clipped text, or inaccessible CTA buttons.
  4. Rotate if supported and recheck layout.
  **Expected:** Trial UI remains readable and tappable without layout collisions.
  **Regression risk:** Multiple home/profile popup widgets changed together.

- [ ] **Verify multi_image_cropper.dart and upload photo screen still present expected UI after onboarding trial insertion** — _This is a non-blocking visual/surface regression check._
  **Steps:**
  1. Open the photo upload flow from onboarding or profile edit.
  2. Crop/select a photo and confirm the cropper UI still behaves normally.
  3. Proceed back to the next step and ensure no trial-related overlay appears unexpectedly.
  4. Check for any obvious styling regressions.
  **Expected:** Photo cropper UI remains intact and unaffected by nearby onboarding changes.
  **Regression risk:** Photo upload files changed in the same release.

#### Data flow

_DB tables: `API_key_logs` (incidental — from PR #3392), `active_recurring` (incidental — from PR #3274), `admin` (incidental — from PR #3390), `agent` (incidental — from PR #3390), `api_log` (incidental — from PR #3392), `assign` (incidental — from PR #3390), `auto_dialer_agent_analystics` (incidental — from PR #3390), `autodialer_agent` (incidental — from PR #3390), `bakra` (incidental — from PR #3390), `call_queue` (incidental — from PR #3390), `free_membership_trail` (PR #3274), `keys` (incidental — from PR #3392), `member` (PR #3387), `member_expire_premium` (incidental — from PR #3387), `member_sales_state` (incidental — from PR #3390), `package_payment_recurring` (incidental — from PR #3274), `razorpay_payments_recurring` (incidental — from PR #3274), `webrtc_exotel_call_logs` (incidental — from PR #3390), `webrtc_exotel_call_logs_with_last_login` (incidental — from PR #3390). Detailed verification steps are in **Data to verify** below (LLM-generated from diff facts)._

#### Data to verify

- [ ] **Confirm a successful ₹1 trial enrollment creates and updates the free_membership_trail row for the same member_id** — _This table is the core persistence layer for trial visibility and lifecycle._
  **Steps:**
  1. After one successful ₹1 trial purchase, query free_membership_trail for the test member_id.
  2. Confirm there is a row for that member_id and that status is populated.
  3. Check whether key, response, message, state, timer_end, and countdown_end are populated when the flow reaches those states.
  4. Compare the row to what the app shows as active trial state.
  **Expected:** free_membership_trail contains one coherent trial record for the enrolled member and its fields match the app's active trial state.
  **References:** free_membership_trail, application/models/Common_model.php, application/controllers/V1.php

- [ ] **Confirm recurring records are created for the ₹1 trial in active_recurring and razorpay_payments_recurring** — _Recurring setup must persist correctly or later billing/cancel flows will fail._
  **Steps:**
  1. After successful trial start, query active_recurring by member_id and order_id/customer_id if available from logs.
  2. Query razorpay_payments_recurring for the same member_id/order_id/customer_id.
  3. Confirm token_id is present where the flow has progressed far enough to store it.
  4. Verify the app's active trial state corresponds to these recurring records.
  **Expected:** The same enrollment is represented consistently in active_recurring and razorpay_payments_recurring for the enrolled member.
  **References:** active_recurring, razorpay_payments_recurring, application/models/Payment_model.php, application/controllers/V1.php

- [ ] **Confirm package_payment_recurring is written once for the ₹1 trial enrollment and not duplicated on retry** — _Duplicate recurring package rows indicate idempotency failure in billing setup._
  **Steps:**
  1. Capture row count in package_payment_recurring for the test member before retrying the same trial action.
  2. Retry the trial start or duplicate-submit scenario.
  3. Query package_payment_recurring again for the same member/order context.
  4. Confirm no duplicate row was added by the retry.
  **Expected:** package_payment_recurring reflects the enrollment once and is not duplicated by a second submit.
  **References:** package_payment_recurring, application/models/Payment_model.php

- [ ] **Confirm cancellation updates free_membership_trail, active_recurring, and member state together** — _Cancellation must clear entitlement and billing state consistently._
  **Steps:**
  1. Cancel a live ₹1 trial subscription for a test member.
  2. Query free_membership_trail and confirm status/active/cancel fields reflect cancellation.
  3. Query active_recurring and confirm active/cancel fields are updated.
  4. Query member and confirm membership/active/cancel fields match the downgraded app state.
  **Expected:** All three tables reflect the same cancelled state and the app no longer shows active trial entitlement.
  **References:** free_membership_trail, active_recurring, member, application/models/Payment_model.php

- [ ] **Confirm member_expire_premium is written when the ₹1 trial cancellation/downgrade path records expiry history** — _Expiry history is needed for auditability and later entitlement debugging._
  **Steps:**
  1. Run the cancel flow on a ₹1 trial account.
  2. Query member_expire_premium for the member_id.
  3. Confirm expire_on and identifying fields such as member_profile_id, name, email, mobile, and last_package_info are populated if the row is created by this path.
  4. Cross-check that the recorded expiry aligns with the app's downgraded state.
  **Expected:** If the downgrade path writes history, member_expire_premium contains a coherent expiry record for the cancelled trial member.
  **References:** member_expire_premium, application/models/Payment_model.php

- [ ] **Confirm Cron consumers can read the new trial state without leaving orphaned rows** — _Background jobs are listed as known consumers and can surface hidden data integrity issues._
  **Steps:**
  1. After creating a trial row, inspect any relevant Cron.php read path in QA by running the scheduled job manually if allowed.
  2. Confirm free_membership_trail rows are processed without SQL errors and active_recurring rows remain linked to the same member.
  3. After a failed or retried enrollment test, verify there is no orphan free_membership_trail row with no corresponding usable recurring state when the app shows no active trial.
  4. Review logs for Cron.php warnings tied to free_membership_trail or active_recurring.
  **Expected:** Cron consumers read the persisted trial data cleanly and retries do not leave orphaned or contradictory records.
  **References:** application/controllers/Cron.php, free_membership_trail, active_recurring

- [ ] **Confirm `bakra` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `bakra` for the test user after completing the flow
  2. Verify expected columns are populated: timer
  **Expected:** Row exists in `bakra` with the expected column values
  **References:** table: bakra, pr: #3390

- [ ] **Confirm `admin` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `admin` for the test user after completing the flow
  2. Verify expected columns are populated: (columns not visible in diff)
  **Expected:** Row exists in `admin` with the expected column values
  **References:** table: admin, pr: #3390

- [ ] **Confirm `agent` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `agent` for the test user after completing the flow
  2. Verify expected columns are populated: (columns not visible in diff)
  **Expected:** Row exists in `agent` with the expected column values
  **References:** table: agent, pr: #3390

- [ ] **Confirm `call_queue` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `call_queue` for the test user after completing the flow
  2. Verify expected columns are populated: call_status, response
  **Expected:** Row exists in `call_queue` with the expected column values
  **References:** table: call_queue, pr: #3390

- [ ] **Confirm `assign` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `assign` for the test user after completing the flow
  2. Verify expected columns are populated: (columns not visible in diff)
  **Expected:** Row exists in `assign` with the expected column values
  **References:** table: assign, pr: #3390

- [ ] **Confirm `webrtc_exotel_call_logs` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `webrtc_exotel_call_logs` for the test user after completing the flow
  2. Verify expected columns are populated: (columns not visible in diff)
  **Expected:** Row exists in `webrtc_exotel_call_logs` with the expected column values
  **References:** table: webrtc_exotel_call_logs, pr: #3390

- [ ] **Confirm `webrtc_exotel_call_logs_with_last_login` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `webrtc_exotel_call_logs_with_last_login` for the test user after completing the flow
  2. Verify expected columns are populated: (columns not visible in diff)
  **Expected:** Row exists in `webrtc_exotel_call_logs_with_last_login` with the expected column values
  **References:** table: webrtc_exotel_call_logs_with_last_login, pr: #3390

- [ ] **Confirm `auto_dialer_agent_analystics` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `auto_dialer_agent_analystics` for the test user after completing the flow
  2. Verify expected columns are populated: (columns not visible in diff)
  **Expected:** Row exists in `auto_dialer_agent_analystics` with the expected column values
  **References:** table: auto_dialer_agent_analystics, pr: #3390

- [ ] **Confirm `member_sales_state` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `member_sales_state` for the test user after completing the flow
  2. Verify expected columns are populated: stack_blocked, block_reason, block_note
  **Expected:** Row exists in `member_sales_state` with the expected column values
  **References:** table: member_sales_state, pr: #3390

- [ ] **Confirm `autodialer_agent` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `autodialer_agent` for the test user after completing the flow
  2. Verify expected columns are populated: (columns not visible in diff)
  **Expected:** Row exists in `autodialer_agent` with the expected column values
  **References:** table: autodialer_agent, pr: #3390

- [ ] **Confirm `api_log` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `api_log` for the test user after completing the flow
  2. Verify expected columns are populated: (columns not visible in diff)
  **Expected:** Row exists in `api_log` with the expected column values
  **References:** table: api_log, pr: #3392

- [ ] **Confirm `API_key_logs` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `API_key_logs` for the test user after completing the flow
  2. Verify expected columns are populated: member_id
  **Expected:** Row exists in `API_key_logs` with the expected column values
  **References:** table: API_key_logs, pr: #3392

- [ ] **Confirm `keys` row reflects the write** — _DB write detected in diff — verify persistence layer directly_
  **Steps:**
  1. Query `keys` for the test user after completing the flow
  2. Verify expected columns are populated: (columns not visible in diff)
  **Expected:** Row exists in `keys` with the expected column values
  **References:** table: keys, pr: #3392

#### QA tools

- [ ] **[Backend QA tool] Check forced recurring eligibility helper output** — _Confirms Test.php changes are deployed and shared eligibility helper logic is healthy._
  **Steps:**
  1. Open the deployed backend URL path /test/check_forced_recurring_assisted/{member_id}.
  2. Run it for one known eligible Android India member with ml_percent >= 50 and one known ineligible member.
  3. Record whether the endpoint returns plain 1 or 0 as documented.
  **Expected:** Endpoint responds successfully with 1 for eligible and 0 for ineligible members, with no PHP error output.

- [ ] **[Backend QA tool] Insert forced recurring snapshot rows in batches** — _This verifies the new Test.php and Database_operation.php QA utilities included in the backend bundle._
  **Steps:**
  1. First open /database_operation/create_forced_recurring_eligible_users_table if the table does not already exist.
  2. Then open /test/insert_forced_recurring_users or /test/insert_forced_recurring_users/2628296/2695296/500.
  3. Watch the HTML summary for candidates scanned, inserted, skipped existing, and skipped not eligible.
  **Expected:** Tool runs without fatal errors, respects the batch range, and prints a coherent summary.

**Code concerns:**
- [ ] [high] Payment and recurring behavior for the ₹1 trial spans many merged and open PRs (#3398, #3400, #3411, #3412, #3525, #3527 remain open nearby), increasing risk that deployed master behavior differs from the intended final flow. (application/models/Payment_model.php) — _Before sign-off, verify deployed endpoints with DB state and request logs for one full enroll/cancel cycle; do not rely only on merged PR titles._
- [ ] [high] V1.php is a shared controller with repeated trial eligibility edits across many PRs, including build gating, ML %, recurring conditions, timer fixes, and member_id caps; this is a high blast-radius surface for unrelated app APIs. (application/controllers/V1.php) — _Run targeted regression on dashboard/home/profile payloads for both eligible and ineligible users and add automated contract coverage around trial fields being absent/present._
- [ ] [high] Architecture docs note legacy direct Dio() usage in lib/utils/network/api.dart parallel to ApiClient, so trial/payment calls may bypass shared interceptors, timeout handling, and standardized error mapping. (lib/utils/network/api.dart) — _Consolidate trial/payment endpoints onto ApiClient or explicitly mirror interceptor/error behavior for these calls._
- [ ] [medium] Shared API constants changed in the same release; a wrong constant or path drift can silently break multiple screens beyond the ₹1 trial. (lib/utils/network/api_constant_new.dart) — _Add a smoke test matrix for all consumers of changed constants and centralize endpoint contract tests._
- [ ] [medium] free_membership_trail is inserted and updated from multiple code paths with overlapping fields (status, state, timer_end, countdown_end, key, response, message), which raises race-condition and partial-update risk. (application/models/Common_model.php) — _Wrap trial state transitions in a single service method with explicit state machine rules and transaction boundaries._
- [ ] [medium] Countdown logic is split across Flutter view model and backend timer fields, making drift likely after app resume, clock skew, or stale cache. (lib/controller/header_countdown_view_model.dart) — _Prefer one backend-derived expiry source and compute all UI countdowns from that single timestamp._
- [ ] [medium] New Test.php endpoints perform batch inserts and eligibility checks directly on production-like tables without obvious auth/rate guard in the prompt. (application/controllers/Test.php) — _Restrict Test.php tools to QA/admin environments or add explicit access controls and environment checks._
- [ ] [low] A Kotlin compiler session artifact appears in changed files and should not be part of a release review surface. (android/.kotlin/sessions/kotlin-compiler-632441429195445057.salive) — _Remove IDE/build session artifacts from version control and add ignore rules._
- [ ] [low] Schema creation via controller endpoints is operationally risky if exposed beyond controlled environments. (application/controllers/Database_operation.php) — _Move one-off table creation to migrations and keep controller-based schema utilities disabled outside QA/dev._
- [ ] [high] Blast radius: Shared API constants file -- every screen/service importing these constants is a potential consumer of this change. (lib/utils/network/api_constant_new.dart) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared data model -- every feature that reads or writes this model is a potential consumer of this change. (application/models/Common_model.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._
- [ ] [high] Blast radius: Shared PHP API controller (V1.php) -- every client request routed through V1 is a potential consumer of this change, not just the feature this PR targets. (application/controllers/V1.php) — _Regression-test known consumers of this shared surface before sign-off._

**Refactor suggestions (advisory):**
- [p1] Eligibility rules are spread across V1.php, Flutter_api.php, Common_model.php, and Payment_model.php. → Extract one canonical eligibility service returning named reasons for allow/deny, then consume it from all entry points. (Trial eligibility)
- [p1] free_membership_trail is mutated by multiple insert/update branches with overlapping semantics. → Introduce a dedicated repository/service with transactional upsert methods and explicit status/state enums. (Trial state persistence)
- [p2] Banner, popup, onboarding screen, and profile card each appear to own parts of the same offer presentation. → Create a shared view model/presenter for ₹1 trial content so price, countdown, and CTA text cannot drift. (Flutter acquisition surfaces)
- [p2] Legacy Dio calls coexist with ApiClient-based calls. → Migrate trial/payment endpoints to ApiClient and remove duplicate request plumbing from lib/utils/network/api.dart. (Network stack)

**Blockers:** none

#### References
- Flutter PR: #543 (`free_trail_start_1rs` → staging), #569 (`fix/1rs_plan` → staging), #588 (`1_rupee_trail` → staging), #601 (`feat/one_rupees_trail_new` → staging), #604 (`fix/one_rs_plan_for_rec` → staging)
- Backend PRs (nikahforever): #3274 (`free_trail_code_revert` → master), #3279 (`make_function_for_decide_whom_to_give_free_trail` → master), #3287 (`free_trail_access_give` → master), #3298 (`start_free_trail` → master), #3315 (`fix_max_amount_issue` → master), #3316 (`fix/firebase-sender-ids-prefix` → master), #3317 (`condition_add_change` → master), #3318 (`odd_even_condition_remove` → master), #3319 (`free_trail_pop_up_gender_2` → master), #3320 (`fix_days_1` → master), #3321 (`fix_state_issue` → master), #3322 (`make_cron_of_pic_request_without_sorting_order` → master), #3323 (`free_trail_pop_up` → master), #3324 (`view_my_profile_less_change` → master), #3325 (`refill-on-behalf-gender` → master), #3326 (`add_app_version_1055` → master), #3336 (`fix_timer_issue_for_trail_plan` → master), #3344 (`fixed_1rs_trail_issue_in_expire_time` → master), #3351 (`free_trail_version_1060` → master), #3387 (`downgrade_premium_1rs` → master), #3388 (`paused-cron-for-making-user-active-again` → master), #3389 (`set_membership_trail` → master), #3390 (`auto-dialer-itr-1` → master), #3391 (`dropped_photo_request_column` → master), #3392 (`V2-mini-plan` → master), #3393 (`updaet_cron_for_free_trail_member` → master), #3394 (`Live-Sales-Target-&-Completion-System` → master), #3395 (`best_match_limit` → master), #3396 (`user_pic_request_migrate_from_old_2_to_user_pic_request` → master), #3397 (`live_for_female_user_last_7_days` → master), #3398 (`fix_active_recurring_amount` → master), #3399 (`fix_1rs_plan_new` → master), #3400 (`fix_trail_1rs_hjjk` → master), #3401 (`fix_cancel_subscription_of_1rs_trail` → master), #3402 (`return_time_approved_of_1days` → master), #3403 (`revert-3402-return_time_approved_of_1days` → master), #3404 (`mini-plan-headings` → master), #3405 (`fix-timer-new-plan` → master), #3406 (`new-plan-timer-override` → master), #3407 (`recurring-only` → master), #3408 (`round-off-amount` → master), #3409 (`minimum-amount-key` → master), #3410 (`fix-validity-type` → master), #3411 (`boost-amount-fix` → master), #3412 (`fix_paused_Recurring_payments` → master), #3413 (`fix_met_capi` → master), #3414 (`fix_active_recurring` → master), #3415 (`get-dynamic-boost` → master), #3416 (`amount_cut_at_that_time` → master), #3417 (`add-mini-plan-name` → master), #3418 (`optimised-mini-plan` → master), #3419 (`sending-plan-name-name` → master), #3420 (`Live-Sales-Target-&-Completion-System` → master), #3421 (`meta_capi_event_handle` → master), #3422 (`replace_order_of_phone_pay_and_google_pay` → master), #3423 (`adding-intenational-slash` → master), #3424 (`otp_bypass_number_added` → master), #3425 (`add-slash-for-rec` → master), #3426 (`log_jjjj` → master), #3427 (`mini-plan-override` → master), #3428 (`show-minimum-plan-international` → master), #3429 (`free_trail_token_validity_on_the_base-of_24hr` → master), #3430 (`type-cast-plan-ui-variant` → master), #3431 (`show-upi-option` → master), #3432 (`pakistan-rec-false` → master), #3433 (`live-discount-mini-plan` → master), #3434 (`cron_for_process_users_payment_assisted_prediction_logs` → master), #3435 (`dashboard_info_chanege` → master), #3436 (`insert_caste_id_from_given_seat` → master), #3437 (`fix_text_of_rs` → master), #3438 (`fix_text` → master), #3514 (`pause_one_rs_trail_for_all_user` → master), #3515 (`profiles_not_coming_web_issue_fix` → master), #3516 (`backfill_campaign_id` → master), #3517 (`app_version_condition_added` → master), #3518 (`add-version-new-plan` → master), #3519 (`one_rs_trail_test_number` → master), #3520 (`apple_app_version_condition` → master), #3521 (`make_recurring_true` → master), #3522 (`add_recurring_condition` → master), #3523 (`ml_percent_added` → master), #3524 (`make_1rs_trail-condition_for_ml_percent_40` → master), #3525 (`free_member_ship_trail_controlled` → master), #3526 (`meta_event_fix` → master), #3527 (`ml_percent_30` → master), #3528 (`hardcode-ph-otp` → master), #3529 (`refactor_free_trail_version` → master), #3530 (`verify-otp-hardcode` → master), #3531 (`lwb_logs_fix` → master), #3532 (`update_build_number_condition` → master), #3533 (`fixes_lwb_logs` → master), #3534 (`fix_issue` → master), #3535 (`otp-abu-hammad` → master), #3536 (`one-rp-plan-vrnt-1` → master), #3537 (`backend_one_rs_trail` → master), #3538 (`best_match_wrong_profile_logs` → master), #3539 (`silver-plan-new` → master), #3540 (`add_membership_condition_while_showing_header_offfer` → master), #3541 (`after_member_2809275` → master), #3542 (`report_test` → master), #3543 (`fix_membe_conditon` → master), #3544 (`fix_ml_percent` → master), #3545 (`increase_limit` → master), #3546 (`remove_upsert_meta` → master), #3547 (`whne_user_login_at_android_and_open_in_ios` → master), #3548 (`optimize-otp-api` → master), #3549 (`insert_payload_of_meta_event` → master), #3550 (`meta_fix_system_generated` → master), #3551 (`increase_otp_limit` → master), #3552 (`plan-mini-plan-ui` → master), #3553 (`strict-filter-popup-feature` → master), #3554 (`refactor-delete-account-cron` → master), #3555 (`v2-mini-plan-malayalam` → master), #3556 (`build_meta_event_for_this` → master), #3557 (`ios_device_fixed` → master), #3565 (`now_not_checking_for_1day_case` → master), #3573 (`pause_at_a_time_subscrpiton` → master), #3579 (`free_trail_token` → master), #3582 (`active_fix_date` → master), #3584 (`free_trail_active_recurring_debug` → master), #3590 (`stop-1-rs-trial` → master)
- nf_node PR: none

---

## 10-minute regression smoke (every release)
- [ ] Login (password + OTP)
- [ ] Dashboard loads (matches, recommendations)
- [ ] Send/accept an interest
- [ ] Open a chat and send a message
- [ ] Open plans + start a payment (sandbox)
- [ ] Logout
