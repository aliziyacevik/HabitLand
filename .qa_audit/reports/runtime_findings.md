# Runtime Findings — HabitLand QA Audit v5

**Date:** 2026-03-25
**Test Method:** XCUITest + Manual Simulator Testing

## Critical Fixes Applied This Session

### 1. CloudKitManager Crash — FIXED
- **Trigger:** Tapping "Start Pro" or "Got a referral?" in PaywallView
- **Root Cause:** `ReferralCodeEntryView` eagerly init'd `CloudKitManager.shared` via `@ObservedObject`. `CKContainer` init crashes without valid CloudKit entitlements in simulator.
- **Fix:** Replaced `ReferralCodeEntryView` reference in PaywallView with inline text field. Zero CloudKit dependency.
- **Crash report:** `HabitLand-2026-03-25-114218.ips` — `EXC_BREAKPOINT` in `CKContainer.__allocating_init`

### 2. Trial System Making All Users Pro — FIXED
- **Trigger:** Completing onboarding
- **Root Cause:** `startInAppTrial()` called in both OnboardingView "Maybe Later" and ContentView `onComplete`. Trial active = isPro true = crown/blur hidden.
- **Fix:** Removed all `startInAppTrial()` calls from onboarding and ContentView. Trial welcome banner removed.

### 3. Nested Sheet Crash — FIXED
- **Trigger:** Opening PaywallView from OnboardingView pro offer
- **Root Cause:** SwiftUI `.sheet` inside `.fullScreenCover` with `@Query` caused crash
- **Fix:** PaywallView shown as inline onboarding step (case 3), not sheet/cover

## XCUITest Results

Test passed (99.7s) but Notifications sheet blocked subsequent navigation. Home dashboard screenshot captured successfully.

## Manual Verification Needed

| Feature | Expected | Status |
|---------|----------|--------|
| Sleep tab crown badge | Crown icon for non-Pro | Needs manual check (screenshotMode = Pro) |
| Sleep tab blur gate | Blurred content + lock overlay | Needs manual check |
| Profile stats lock | Lock icon + ProBadge on statistics | Needs manual check |
| Streak celebration | Confetti modal at 7/14/30 day | Needs streak to reach milestone |
| Referral code entry | Inline text field in paywall | Verified working |
| Onboarding Pro offer | Dedicated screen with Start Pro / Maybe Later | Verified working |
