# Domain Pitfalls

**Domain:** iOS Habit Tracker -- StoreKit 2 IAP, Paywalls, ASO, App Store Review
**Researched:** 2026-03-21

---

## Critical Pitfalls

Mistakes that cause App Store rejection, revenue loss, or major rework.

### Pitfall 1: Not Listening for Unfinished Transactions at App Launch

**What goes wrong:** StoreKit 2's `Transaction.updates` does NOT reliably emit transactions that occurred while the app was not running. Users pay but never receive Pro access. Money is taken, entitlement is not granted. This is the single most common StoreKit 2 bug reported on Apple Developer Forums.

**Why it happens:** Developers rely solely on `Transaction.updates` and assume it will catch everything. In practice, it sometimes misses transactions that completed during background/killed state. The current HabitLand `ProManager` only listens to `Transaction.updates` and calls `updatePurchasedProducts()` at init -- this is correct but needs hardening.

**Consequences:** Users pay and don't get Pro. They leave 1-star reviews. Refund requests spike. Apple may flag the app.

**Warning signs:**
- Users report "I paid but I'm still on free"
- `Transaction.currentEntitlements` returns empty despite successful payment
- StoreKit testing works fine but production fails

**Prevention:**
1. Always call `Transaction.currentEntitlements` on every app launch (HabitLand already does this in `updatePurchasedProducts()` -- good)
2. Add a manual "Restore Purchases" button visible to all users (HabitLand has `restorePurchases()` -- ensure it is surfaced in the UI)
3. Handle the `.pending` case properly -- show a "purchase pending" state, not silence
4. Never have more than one `Transaction.updates` listener (known Apple bug: only one receives updates)
5. Test with StoreKit Configuration file AND sandbox environment before submission

**Phase:** StoreKit 2 integration phase. Verify before App Store submission.

**Confidence:** HIGH -- Apple Developer Forums confirm this is a widespread issue (FB11984421).

---

### Pitfall 2: Paywall Rejected for Unclear Subscription Terms

**What goes wrong:** Apple rejects apps that don't show exact pricing, renewal terms, trial duration, and cancellation info on the paywall screen BEFORE the purchase button. In early 2026, Apple specifically started rejecting toggle-based free trial designs and unclear subscription flows.

**Why it happens:** Developers focus on conversion-optimized design and bury the legally-required text. Or they display price without renewal period ("$29.99" instead of "$29.99/year, auto-renews").

**Consequences:** App Store rejection. Delays launch by days/weeks during resubmission.

**Warning signs:**
- Paywall shows price without "/year" or "/month" suffix
- Free trial mentioned but no "then $X.XX/year" after it
- No cancellation instructions anywhere on paywall
- Subscription terms in tiny, low-contrast text

**Prevention:**
1. Display EXACT price with period: "$29.99/year" not "$29.99"
2. If offering a free trial, show the timeline explicitly: "7-day free trial, then $29.99/year"
3. Include cancellation text: "Cancel anytime in Settings > Subscriptions"
4. Link to Terms of Service and Privacy Policy from the paywall
5. Make all pricing text legible -- no 8pt gray-on-gray
6. Do NOT use toggle switches to select trial vs. no-trial (Apple rejects this pattern as of 2026)
7. Use Apple's `SubscriptionStoreView` or `StoreView` components when possible -- they auto-comply

**Phase:** Paywall design phase. Must be correct before submission.

**Confidence:** HIGH -- Apple's review guidelines 3.1.1, 3.1.2 explicitly require this.

---

### Pitfall 3: Screenshot Mode / Debug Toggle Ships to Production

**What goes wrong:** The `-screenshotMode` argument in HabitLand bypasses Pro checks entirely (`isPro` returns `true`). If this ships, any user who discovers it (or any tool that launches with that argument) gets free Pro access.

**Why it happens:** Debug convenience features added during development are forgotten at release.

**Consequences:** Revenue bypass. If discovered and shared publicly, all Pro revenue is lost.

**Warning signs:**
- `ProcessInfo.processInfo.arguments.contains("-screenshotMode")` in `isPro` getter
- `debugProEnabled` toggle exists in settings (DEBUG only, but still a smell)
- No `#if DEBUG` guard around the screenshotMode check

**Prevention:**
1. Wrap the screenshotMode check in `#if DEBUG`: `#if DEBUG ... #endif`
2. Create a pre-submission checklist item: "Remove/guard all debug bypasses"
3. Add a unit test that verifies `isPro` returns `false` when `purchasedProductIDs` is empty in Release builds
4. Consider using a separate build scheme for screenshots instead of runtime flags

**Phase:** Pre-submission cleanup. Must be done before App Store submission.

**Confidence:** HIGH -- directly observed in `ProManager.swift` line 26.

---

### Pitfall 4: Keyword Stuffing or Wasting ASO Characters

**What goes wrong:** Indie developers either (a) stuff keywords into the title/subtitle, triggering Apple's metadata policy rejection, or (b) waste the 100-character keyword field by repeating words already in the title or including stop-words ("app", "the", "a") that Apple indexes automatically.

**Why it happens:** Developers don't understand that Apple indexes title + subtitle + keyword field as a combined set. Repeating "habit" in all three fields wastes 5 characters each time.

**Consequences:** Lower search visibility than competitors. Or metadata rejection from Apple for keyword stuffing in title.

**Warning signs:**
- App title is "HabitLand - Best Habit Tracker App for Daily Routines & Goals"
- Keyword field contains words already in the title
- Keyword field has commas AND spaces (spaces waste characters)
- Using phrases instead of individual words in the keyword field

**Prevention:**
1. Title: "HabitLand" (brand name only, or "HabitLand: Daily Habit Tracker" max)
2. Subtitle: Use for keywords NOT in title, e.g., "Streak Goals & Routine Builder"
3. Keyword field: Comma-separated single words, no spaces after commas, no words from title/subtitle. Example: "streak,routine,goals,wellness,gamification,challenge,reminder,daily,health,sleep"
4. Create a free Apple Search Ads account to check keyword popularity scores before choosing
5. Plan to update keywords every 4-6 weeks based on Search Ads data

**Phase:** ASO preparation phase. Finalize before submission, iterate after launch.

**Confidence:** HIGH -- Apple's metadata guidelines + multiple ASO audits confirm this pattern.

---

### Pitfall 5: App Store Rejection for Missing Privacy Disclosures

**What goes wrong:** HabitLand collects HealthKit data, stores user profiles in CloudKit public database, and tracks habit data locally. Apple requires EXACT disclosure of all data collected in App Store Connect's privacy nutrition labels. Mismatch between what the app does and what's declared causes rejection.

**Why it happens:** Developers fill out privacy labels quickly without auditing every data point their app touches. HealthKit is especially sensitive -- Apple scrutinizes health data collection.

**Consequences:** Rejection with vague message like "your app's privacy information isn't accurate." Debugging which field is wrong can take multiple resubmission cycles.

**Warning signs:**
- Privacy labels don't mention health data despite HealthKit integration
- CloudKit public database stores user profile data but privacy labels don't list "name" or "user ID"
- No privacy policy URL configured in App Store Connect
- Privacy policy doesn't mention HealthKit data usage

**Prevention:**
1. Audit every data point: habit names (user content), HealthKit data (health), CloudKit profile (name, username), completions (usage data)
2. Declare ALL of them in App Store Connect privacy labels
3. HealthKit requires a dedicated section in your privacy policy explaining what health data is read and why
4. Add `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` with specific, honest descriptions
5. Test the privacy manifest (`PrivacyInfo.xcprivacy`) requirement -- as of iOS 17, Apple requires this for certain API usage

**Phase:** Pre-submission. Must be done alongside App Store Connect metadata.

**Confidence:** HIGH -- Apple's review guidelines section 5.1.

---

### Pitfall 6: Showing Paywall Before User Experiences Value

**What goes wrong:** App shows a hard paywall immediately after onboarding, before the user has created a single habit or experienced the gamification. Conversion rates crater because users have no reason to pay yet.

**Why it happens:** Developers want revenue fast and assume "the sooner they see the paywall, the sooner they pay."

**Consequences:** Low conversion rates (under 2%). High uninstall rates. Apple may flag the paywall as deceptive if free tier is effectively useless.

**Warning signs:**
- Paywall appears on first app launch or right after onboarding
- Free tier has 3-habit limit (HabitLand's current limit) but user hasn't created any habits yet
- No "aha moment" before paywall trigger

**Prevention:**
1. Let users create their first 3 habits and use the app for 2-3 days before any paywall
2. Trigger paywall at the moment of DESIRE, not randomly: when user tries to create 4th habit, when they try to access sleep analytics, when they try social features
3. Show paywall as a "you've hit the limit" gate, not a "pay to enter" gate
4. RevenueCat's 2025 data: top apps achieve 20%+ trial-to-paid by timing paywall after value demonstration
5. Consider a soft paywall (dismissible) for discovery, hard paywall only at actual feature limits

**Phase:** Paywall design phase. Critical UX decision.

**Confidence:** HIGH -- RevenueCat data + Adapty paywall research.

---

## Moderate Pitfalls

### Pitfall 7: Not Testing Free Tier Experience End-to-End

**What goes wrong:** HabitLand's QA tests use `-screenshotMode` and `debugProEnabled` to bypass Pro checks. The actual free tier (3 habits, 5 achievements, no sleep/social) has never been tested as a real user would experience it.

**Why it happens:** It's easier to test with Pro enabled. Free tier testing is tedious.

**Prevention:**
1. Add a QA test that creates exactly 3 habits, tries to create a 4th, and verifies the paywall appears
2. Test every Pro-gated screen shows appropriate upsell when accessed as free user
3. Remove debug Pro toggle from Release builds before submission
4. Test the upgrade flow: free -> paywall -> purchase -> Pro features unlock

**Warning signs:**
- `canCreateHabit()` not tested without debug override
- Free users can access sleep dashboard, social features (should they be gated?)
- No paywall trigger tests exist

**Phase:** Pre-submission QA. Must verify before App Store submission.

**Confidence:** HIGH -- directly observed in CONCERNS.md.

---

### Pitfall 8: App Store Screenshots That Don't Convert

**What goes wrong:** Screenshots show the app's UI but don't communicate the VALUE proposition. "Here's the home screen" doesn't tell a potential user why they should download HabitLand over Streaks or Habitica.

**Why it happens:** Developers screenshot their app and upload. No copywriting, no value framing, no competitive positioning.

**Prevention:**
1. First screenshot must communicate the core value proposition in 2 seconds: "Never break a streak again" with a visual of the gamification system
2. Show the emotional benefit, not the feature: "Watch your habits grow" not "Calendar view"
3. Use device frames with caption text above each screenshot
4. Localize screenshots for Turkish market (since developer is Turkish, this is a near-free localization win)
5. Use all 10 screenshot slots
6. Add an App Preview video showing the satisfying animations and gamification

**Warning signs:**
- Screenshots are just raw app UI without context text
- First screenshot doesn't communicate what the app does
- Screenshots don't show the gamification (HabitLand's differentiator)

**Phase:** ASO / App Store metadata phase.

**Confidence:** HIGH -- standard ASO knowledge.

---

### Pitfall 9: Subscription Grace Period and Billing Retry Not Configured

**What goes wrong:** A user's subscription renewal fails (expired credit card, insufficient funds). Without grace period enabled in App Store Connect, they immediately lose Pro access. They get frustrated, leave a bad review, and never re-subscribe.

**Why it happens:** Grace period and billing retry are opt-in settings in App Store Connect that developers don't know about.

**Prevention:**
1. Enable "Billing Grace Period" in App Store Connect (gives 6-16 days for payment retry)
2. Enable "Billing Retry" to let Apple automatically retry failed payments
3. Check `transaction.expirationDate` and `transaction.isUpgraded` in entitlement checks
4. Show a "subscription expiring" banner rather than immediately removing access

**Warning signs:**
- Users report "my Pro disappeared"
- No grace period handling in `updatePurchasedProducts()`
- Subscription status only checks `revocationDate`, not `expirationDate`

**Phase:** StoreKit 2 integration phase.

**Confidence:** MEDIUM -- App Store Connect settings; verify exact options during implementation.

---

### Pitfall 10: fatalError() Crashes During App Store Review

**What goes wrong:** HabitLand has a `fatalError()` in `SharedModelContainer.swift` if both primary and fallback container creation fail. If this triggers during Apple's review (different device, different state), the app crashes and gets rejected.

**Why it happens:** Developers use fatalError() as a "this should never happen" guard but App Store review environments are unpredictable.

**Prevention:**
1. Replace `fatalError()` with in-memory fallback container
2. Show a user-friendly error sheet instead of crashing
3. Test on a clean device with no iCloud account signed in
4. Test with low storage / airplane mode

**Warning signs:**
- `fatalError()` calls anywhere in the codebase
- Untested error paths in container initialization

**Phase:** Bug cleanup / pre-submission. Must fix before submission.

**Confidence:** HIGH -- directly observed in CONCERNS.md.

---

### Pitfall 11: Not Localizing for Turkish Market First

**What goes wrong:** Developer is Turkish, app likely has natural Turkish-speaking audience, but app is English-only. Date formatting is hardcoded to English format ("EEEE, MMM d"). Missing an easy localization win.

**Why it happens:** Developers build in English and plan to "add localization later." Later never comes.

**Prevention:**
1. Add Turkish localization before launch (developer speaks Turkish natively -- near-zero cost)
2. Fix hardcoded date formatting to use `Locale.current` (known bug in CONCERNS.md)
3. Localize App Store metadata (title, subtitle, keywords, description) for Turkish market
4. Turkish App Store is less competitive for habit trackers -- easier to rank

**Warning signs:**
- `DateFormatter` with hardcoded format strings
- No `.lproj` folders for Turkish
- App Store Connect only has English metadata

**Phase:** ASO / localization phase. Do before or immediately after launch.

**Confidence:** MEDIUM -- based on project context (developer is Turkish speaker).

---

## Minor Pitfalls

### Pitfall 12: Forgetting the "Restore Purchases" Button

**What goes wrong:** Apple rejects apps that don't have a visible "Restore Purchases" button for non-consumable and subscription IAPs.

**Prevention:**
1. Add a clearly labeled "Restore Purchases" button in Settings AND on the paywall
2. HabitLand has `restorePurchases()` method -- just ensure it's wired to a visible UI element
3. The button must actually work (calls `AppStore.sync()`)

**Phase:** Paywall design phase.

**Confidence:** HIGH -- Apple review guideline 3.1.1.

---

### Pitfall 13: Not Setting Up StoreKit Configuration File for Testing

**What goes wrong:** Developer tests IAP only in sandbox, which is slow and unreliable. Misses edge cases that StoreKit Testing in Xcode catches (renewal, cancellation, refund, ask-to-buy).

**Prevention:**
1. Create a `.storekit` configuration file in Xcode with both products (yearly + lifetime)
2. Configure introductory offer (free trial) in the config file
3. Test all flows: purchase, cancel, renew, refund, ask-to-buy, interrupted purchase
4. Use `SKTestSession` in unit tests to automate purchase flow testing

**Phase:** StoreKit 2 integration phase.

**Confidence:** HIGH -- Apple documentation recommends this workflow.

---

### Pitfall 14: Submitting Without Testing on a Clean Device

**What goes wrong:** App works perfectly on the developer's device (with data, signed into iCloud, HealthKit authorized) but crashes or shows empty/broken states on Apple's review device (clean install, no iCloud, no HealthKit).

**Prevention:**
1. Test on a completely clean device or reset the simulator
2. Test with iCloud signed out (critical for HabitLand since CloudKit is disabled)
3. Test with HealthKit permissions denied
4. Test the onboarding flow from scratch
5. Ensure empty states look intentional, not broken

**Phase:** Pre-submission QA.

**Confidence:** HIGH -- common first-time submission issue.

---

### Pitfall 15: Print Statements in Production Build

**What goes wrong:** HabitLand has 24 `print()` calls in service layer. While not a rejection cause, Apple reviewers can see console output and it looks unprofessional. More importantly, print statements can leak sensitive information.

**Prevention:**
1. Replace all `print()` with `os.Logger` with appropriate log levels
2. Configure `.debug` level to be stripped in Release builds
3. Audit for any print statements that output user data or tokens

**Phase:** Pre-submission cleanup.

**Confidence:** HIGH -- directly observed in CONCERNS.md.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| StoreKit 2 Integration | Unfinished transactions not delivered (#1), Grace period not configured (#9) | Test with StoreKit config file; enable grace period in ASC |
| Paywall Design | Rejection for unclear terms (#2), Paywall too early (#6), Missing restore button (#12) | Follow Apple's exact pricing display requirements; trigger at feature limits |
| ASO / Metadata | Keyword waste (#4), Bad screenshots (#8), No localization (#11) | Use individual keywords; value-proposition screenshots; add Turkish |
| App Store Submission | Privacy disclosure gaps (#5), fatalError crash (#10), Debug mode shipped (#3) | Audit all data points; replace fatalError; guard debug code |
| Pre-submission QA | Free tier untested (#7), Clean device issues (#14), Print statements (#15) | Full free-tier test pass; test on clean device; replace print() |

---

## Sources

- [Apple Developer Forums - StoreKit unfinished transactions](https://developer.apple.com/forums/thread/722222)
- [Apple Developer Forums - StoreKit 2 purchase issues](https://developer.apple.com/forums/thread/802832)
- [App Store Review Guidelines 2026](https://theapplaunchpad.com/blog/app-store-review-guidelines)
- [App Store Review Guidelines Checklist 2025](https://nextnative.dev/blog/app-store-review-guidelines)
- [Adapty - iOS Paywall Design Guide](https://adapty.io/blog/how-to-design-ios-paywall/)
- [RevenueCat - Guide to Mobile Paywalls](https://www.revenuecat.com/blog/growth/guide-to-mobile-paywalls-subscription-apps/)
- [RevenueFlo - Common iOS Paywall Rejections](https://revenueflo.com/blog/common-ios-paywall-rejections-and-the-fixes-that-work)
- [Applyra - 10 ASO Mistakes Indie Developers Make](https://www.applyra.io/blog/aso-mistakes-indie-developers)
- [MobileAction - ASO Mistakes 2026](https://www.mobileaction.co/blog/aso-mistakes/)
- [Medium - I Audited 200+ Indie Apps ASO](https://medium.com/@a.weiss_97627/i-audited-200-indie-apps-for-free-80-make-the-same-aso-mistakes-657ca25a24e0)
- [How to Pass App Store Review for IAP 2025](https://capgo.app/blog/how-to-pass-app-store-review-iap/)
- [Apple - StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)

---

*Pitfalls audit: 2026-03-21*
