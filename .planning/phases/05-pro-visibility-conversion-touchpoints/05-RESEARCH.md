# Phase 5: Pro Visibility & Conversion Touchpoints - Research

**Researched:** 2026-03-25
**Domain:** SwiftUI Pro upgrade touchpoints, paywall UX, streak celebrations, tab badges
**Confidence:** HIGH

## Summary

This phase adds Pro upgrade visibility at five natural engagement points: streak milestone celebrations, Sleep tab crown badge, paywall referral link, profile statistics gating, and onboarding Pro offer screen. The codebase already has robust infrastructure for all of these -- `blurredPremiumGate` modifier, `PaywallContext` enum, `ProManager.isPro` checks, `ReferralCodeEntryView`, and a multi-step onboarding flow. No new frameworks, services, or architectural patterns are needed.

The primary work is UI composition using existing components and patterns. The streak celebration modal is the only truly new component (a sheet with confetti and conditional Pro CTA). Everything else extends existing views with small additions: a crown icon overlay on TabBarItem, a "Got a referral?" footer link in PaywallView, a lock icon + paywall trigger on the statistics quickLink, and a new onboarding step for Pro offer.

**Primary recommendation:** Build all touchpoints as thin UI additions on top of existing ProManager/PaywallView/PremiumGateView infrastructure. No new services or managers needed -- UserDefaults for milestone tracking, existing PaywallContext enum for contextual headers.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Full-screen celebration modal (sheet) with confetti when user hits streak milestones. All users see the celebration; free users get a Pro CTA ("Unlock detailed stats with Pro"), Pro users get just the congrats.
- **D-02:** Claude's Discretion on which milestones trigger: 7, 14, 30 days are natural anchors aligned with existing achievement system.
- **D-03:** Show only once per milestone (track shown milestones in UserDefaults to avoid repeat).
- **D-04:** Small crown icon next to "Sleep" text label in TabBarView -- indicates premium content. Only shown for non-Pro users.
- **D-05:** Tapping Sleep tab navigates normally -- existing blurredPremiumGate in ContentView handles the gate. No behavior change needed, just add the visual crown badge.
- **D-06:** "Got a referral?" text link in bottom footer alongside "Restore Purchases" -- secondary action, doesn't distract from purchase buttons.
- **D-07:** Tapping "Got a referral?" opens the existing referral code entry flow (already built in Phase 2).
- **D-08:** Strengthen paywall value proposition with benefit-focused copy (Claude's Discretion on exact copy).
- **D-09:** PersonalStatisticsView link in UserProfileView shows a lock icon for free users. Tapping opens paywall with analytics context.
- **D-10:** Profile itself stays fully visible -- only the detailed statistics are Pro-gated.
- **D-11:** Dedicated full-screen onboarding page after habit selection (before landing on Home). Shows Pro feature highlights.
- **D-12:** Two CTAs: "Start Pro" (opens paywall) and "Maybe Later" (continues to Home). No pressure, soft sell.
- **D-13:** Replaces or extends the existing trial welcome banner logic (hasTrialBeenOffered in ContentView).

### Claude's Discretion
- Exact celebration modal design (confetti animation, colors, layout)
- Milestone trigger pattern (which streak milestones get celebration)
- Paywall copy improvements and value proposition layout
- Crown badge size and positioning in TabBarView
- Onboarding Pro screen illustration/layout

### Deferred Ideas (OUT OF SCOPE)
- Referral system enhancement (1 week pro rewards, activation conditions) -- future milestone
- Time-based or success-based pro upsells -- post-launch based on conversion data
- A/B testing paywall designs -- AGR-02 in future requirements
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PRO-01 | User sees a pro nudge banner when reaching 7-day streak milestone | Streak milestone celebration modal (D-01, D-02, D-03). Existing `CelebrationOverlay` pattern in HomeDashboardView. Track shown milestones via UserDefaults. |
| PRO-02 | Sleep tab shows a lock badge icon in the tab bar for non-Pro users | Crown icon overlay on `TabBarItem` for `.sleep` tab (D-04). `ProManager.shared.isPro` check already available. |
| PRO-03 | Tapping locked Sleep tab shows blurred premium gate overlay | Already implemented -- `SleepDashboardView` has `.blurredPremiumGate()` modifier in ContentView:118. No new work needed (D-05). |
| PRO-04 | Paywall includes "Got a referral?" button for code entry + stronger CTA | Add footer link to `PaywallView` (D-06, D-07). `ReferralCodeEntryView` already exists and is fully functional. |
| PRO-05 | Profile screen statistics section locked behind Pro with upgrade CTA | Modify `quickLinksSection` in `UserProfileView` (D-09, D-10). Add lock icon + open PaywallView with `.analytics` context. |
| PRO-06 | Paywall shows compelling benefit-focused value proposition | Update `headerSection` and `featuresSection` copy in `PaywallView` (D-08). Purely copy/layout improvement. |
| PRO-07 | User sees a Pro offer screen at the end of onboarding flow | New onboarding step in `OnboardingView` (D-11, D-12, D-13). Extends existing `currentStep` state machine. |
</phase_requirements>

## Architecture Patterns

### Existing Infrastructure (No New Architecture Needed)

The codebase already has all the building blocks:

```
Existing:
  ProManager.shared.isPro          -- Central Pro status check
  PaywallView(context:)            -- Contextual paywall with header variants
  PaywallContext enum               -- .sleepTracking, .analytics, etc.
  .blurredPremiumGate() modifier   -- Tab-level premium gating (Sleep tab)
  .premiumGated() modifier         -- Section-level premium gating
  ProBadge component               -- Small "PRO" capsule badge
  ReferralCodeEntryView            -- Full referral code entry flow
  CelebrationOverlay               -- Full-screen celebration with message
  HLSheetContent modifier          -- Consistent sheet presentation
  OnboardingView currentStep       -- Multi-step onboarding state machine (0=pages, 1=theme, 2=trial)
```

### Pattern 1: Streak Milestone Celebration Modal

**What:** A sheet presented from HomeDashboardView when user hits a streak milestone (7, 14, 30). Distinct from the existing inline `CelebrationOverlay` -- this is a full sheet with Pro CTA for free users.

**When to use:** After habit completion triggers a streak milestone.

**Implementation approach:**
```swift
// New file: HabitLand/Screens/Home/StreakMilestoneView.swift
// Presented as .sheet from HomeDashboardView

struct StreakMilestoneView: View {
    let streakDays: Int
    let isPro: Bool
    var onDismiss: () -> Void
    @State private var showPaywall = false

    var body: some View {
        // Full-screen celebration with confetti
        // Crown/flame icon + "X-Day Streak!" title
        // Motivational message
        // If !isPro: Pro CTA card with "Unlock detailed stats"
        // If isPro: Just the congrats
        // Dismiss button
    }
}
```

**Milestone tracking in UserDefaults:**
```swift
// Key: "shownStreakMilestones" -> Set<Int> stored as [Int] array
// Check before showing: if !shownMilestones.contains(newStreak) && [7, 14, 30].contains(newStreak)
// After showing: add to set and persist
```

**Integration point in HomeDashboardView:** The existing streak milestone check at line 927 (`if [7, 14, 30, 50, 100, 365].contains(newStreak)`) already detects milestones and shows a `CelebrationOverlay`. The new modal should replace or supplement this for the 7/14/30 milestones specifically.

### Pattern 2: Crown Badge on Tab Bar

**What:** Small crown icon overlay on the Sleep tab for non-Pro users.

**Where:** `TabBarItem` in `TabBarView.swift`. The `TabBarItem` receives a `tab: HLTab` -- add conditional crown overlay when `tab == .sleep && !ProManager.shared.isPro`.

**Implementation approach:**
```swift
// Inside TabBarItem body, wrap the icon in a ZStack:
ZStack(alignment: .topTrailing) {
    Image(systemName: tab.icon)
        // existing modifiers

    if tab == .sleep && !ProManager.shared.isPro {
        Image(systemName: "crown.fill")
            .font(.system(size: min(crownSize, 10)))
            .foregroundStyle(Color.hlGold)
            .offset(x: 4, y: -4)
    }
}
```

**Note:** `TabBarItem` is a private struct -- needs `@ObservedObject private var proManager = ProManager.shared` added, or pass `isPro` as a parameter.

### Pattern 3: Paywall Referral Link

**What:** "Got a referral?" text button in PaywallView footer, between promoCodeButton and restoreButton.

**Where:** `PaywallView.swift` body -- add between existing `promoCodeButton` and `restoreButton`.

**Implementation approach:**
```swift
// New computed property in PaywallView:
private var referralButton: some View {
    Button {
        showReferralEntry = true
    } label: {
        HStack(spacing: HLSpacing.xs) {
            Image(systemName: "gift.fill")
            Text("Got a referral?")
        }
        .font(HLFont.subheadline())
        .foregroundStyle(Color.hlTextSecondary)
    }
}
// Present ReferralCodeEntryView in a sheet
// Requires @Query for UserProfile to pass to ReferralCodeEntryView
```

**Dependency:** `ReferralCodeEntryView` requires a `@Bindable var profile: UserProfile` parameter. PaywallView will need a `@Query private var profiles: [UserProfile]` to provide this.

### Pattern 4: Profile Statistics Lock

**What:** Show lock icon on "Personal Statistics" quickLink for free users, open paywall instead of statistics.

**Where:** `UserProfileView.quickLinksSection` -- already partially implemented at line 266-269. Current code navigates to `PremiumGateView` for non-Pro users. Per D-09, should show a lock icon on the row and open paywall directly.

**Current code:**
```swift
if ProManager.shared.canAccessAnalytics {
    quickLink(icon: "chart.bar.fill", title: "Personal Statistics", destination: AnyView(PersonalStatisticsView()))
} else {
    quickLink(icon: "chart.bar.fill", title: "Personal Statistics", destination: AnyView(PremiumGateView(...)))
}
```

**Enhancement:** Add a lock icon/ProBadge to the row content and open PaywallView directly via sheet instead of navigating to PremiumGateView (cleaner UX per D-09).

### Pattern 5: Onboarding Pro Offer

**What:** New onboarding step showing Pro feature highlights with "Start Pro" and "Maybe Later" CTAs.

**Where:** `OnboardingView.swift` -- extend `currentStep` state machine. Currently: 0=pages, 1=theme, 2=trial. Per D-11/D-13, this replaces or modifies step 2 (trialWelcomeStep).

**Current flow:** Pages (intro + name) -> Theme selection -> Trial welcome ("Start My Free Trial" -> onComplete)

**New flow:** Pages (intro + name) -> Theme selection -> Pro offer screen ("Start Pro" opens paywall, "Maybe Later" starts trial and goes to Home)

**Key consideration:** The current `trialWelcomeStep` at step 2 auto-starts the trial on "Start My Free Trial". The new Pro offer should:
- "Start Pro" -> Open PaywallView sheet. If purchased, onComplete(). If dismissed, stay on screen.
- "Maybe Later" -> Start trial (via `proManager.startInAppTrial()`) and call `onComplete()`.

This means the trial start logic moves from ContentView's `onComplete` closure into the onboarding Pro offer step itself.

### Anti-Patterns to Avoid
- **Over-engineering milestone tracking:** Don't create a SwiftData model for shown milestones. UserDefaults with a simple `[Int]` array is sufficient.
- **Blocking UI with Pro CTAs:** Celebrations should feel congratulatory first, Pro pitch second. The CTA should be below the fold / secondary.
- **Hard-blocking navigation:** Sleep tab crown badge is informational only -- tapping still navigates. The blurredPremiumGate handles the actual gate.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Confetti animation | Custom particle system | `ConfettiView` from existing `Effects.swift` or simple `Canvas` animation | Existing celebration patterns in codebase |
| Premium gating | New gate logic | Existing `blurredPremiumGate` / `premiumGated` modifiers | Already handles Pro check, screenshot mode, trial state |
| Referral code entry | New referral flow | Existing `ReferralCodeEntryView` | Fully functional with CloudKit validation |
| Contextual paywall | New paywall variant | `PaywallView(context:)` with `PaywallContext` enum | Already supports contextual headers |
| Sheet presentation | Custom modal transition | `.hlSheetContent()` modifier | Consistent spring animation project-wide |

## Common Pitfalls

### Pitfall 1: Double Celebration on Streak Milestones
**What goes wrong:** Both the existing `CelebrationOverlay` (line 927-933) AND the new streak milestone sheet fire simultaneously.
**Why it happens:** The existing code already shows a celebration overlay for milestones 7, 14, 30, 50, 100, 365.
**How to avoid:** For milestones 7/14/30, replace the existing `CelebrationOverlay` trigger with the new sheet. Keep `CelebrationOverlay` for 50, 100, 365.
**Warning signs:** Two overlapping animations on streak milestone.

### Pitfall 2: Trial Start Timing in Onboarding
**What goes wrong:** Trial starts before user finishes onboarding, or doesn't start at all.
**Why it happens:** Current trial start is in ContentView's `onComplete` closure (line 51-53). Moving it to onboarding Pro offer step requires coordinating with the existing `hasTrialBeenOffered` flag.
**How to avoid:** Move trial start logic entirely into the new onboarding Pro step's "Maybe Later" action. Remove the trial start from ContentView's onComplete closure.
**Warning signs:** `hasTrialBeenOffered` being set at wrong time, trial banner showing after onboarding.

### Pitfall 3: ProManager Not Observed in TabBarItem
**What goes wrong:** Crown badge doesn't update when user purchases Pro.
**Why it happens:** `TabBarItem` is a private struct without ProManager observation.
**How to avoid:** Either add `@ObservedObject private var proManager = ProManager.shared` to TabBarItem, or pass `isPro: Bool` from TabBarView which already can observe ProManager.
**Warning signs:** Crown badge persists after purchase until app restart.

### Pitfall 4: ReferralCodeEntryView Requires UserProfile
**What goes wrong:** Crash or missing data when showing referral entry from PaywallView.
**Why it happens:** `ReferralCodeEntryView` needs a `@Bindable var profile: UserProfile`. PaywallView doesn't currently query UserProfile.
**How to avoid:** Add `@Query private var profiles: [UserProfile]` to PaywallView. Guard against empty profiles before showing referral entry.
**Warning signs:** Compile error or nil profile crash.

### Pitfall 5: Onboarding Step Count Mismatch
**What goes wrong:** Progress indicator shows wrong step count after adding/modifying Pro offer step.
**Why it happens:** `stepIndicator(step:)` and progress bar text ("Step X of 4") are hardcoded.
**How to avoid:** Update step count constant when modifying the onboarding flow. Currently shows "Step X of 4" at line 253.
**Warning signs:** Progress bar shows 4/4 but there's a 5th step, or step numbers are off.

## Code Examples

### Streak Milestone Tracking (UserDefaults)
```swift
// Source: Project pattern -- matches existing @AppStorage usage
private static let shownMilestonesKey = "shownStreakMilestones"

private var shownMilestones: Set<Int> {
    Set(UserDefaults.standard.array(forKey: Self.shownMilestonesKey) as? [Int] ?? [])
}

private func markMilestoneShown(_ milestone: Int) {
    var milestones = shownMilestones
    milestones.insert(milestone)
    UserDefaults.standard.set(Array(milestones), forKey: Self.shownMilestonesKey)
}

private func shouldShowMilestoneCelebration(for streak: Int) -> Bool {
    [7, 14, 30].contains(streak) && !shownMilestones.contains(streak)
}
```

### Crown Badge Overlay on Tab
```swift
// Source: Extends existing TabBarItem pattern
@ScaledMetric(relativeTo: .caption2) private var crownSize: CGFloat = 8

// Inside TabBarItem body, wrap icon:
ZStack(alignment: .topTrailing) {
    Image(systemName: tab.icon)
        .font(.system(size: min(tabIconSize, 26), weight: isSelected ? .semibold : .regular))
        .scaleEffect(isSelected ? 1.1 : 1.0)

    if tab.showsCrown && !isPro {
        Image(systemName: "crown.fill")
            .font(.system(size: min(crownSize, 10)))
            .foregroundStyle(Color.hlGold)
            .offset(x: 6, y: -2)
            .accessibilityHidden(true)
    }
}
```

### Referral Footer in PaywallView
```swift
// Source: Matches existing promoCodeButton/restoreButton pattern
@State private var showReferralEntry = false
@Query private var profiles: [UserProfile]

private var referralButton: some View {
    Button {
        showReferralEntry = true
    } label: {
        HStack(spacing: HLSpacing.xs) {
            Image(systemName: "gift.fill")
            Text("Got a referral?")
        }
        .font(HLFont.subheadline())
        .foregroundStyle(Color.hlTextSecondary)
    }
    .sheet(isPresented: $showReferralEntry) {
        if let profile = profiles.first {
            NavigationStack {
                ReferralCodeEntryView(profile: profile) {
                    showReferralEntry = false
                }
                .padding(HLSpacing.lg)
                .navigationTitle("Enter Referral Code")
                .navigationBarTitleDisplayMode(.inline)
            }
            .hlSheetContent()
        }
    }
}
```

### Profile Statistics Lock Row
```swift
// Source: Extends existing quickLinksSection pattern
// Replace current if/else with enhanced version:
Button {
    if proManager.canAccessAnalytics {
        // Navigate to PersonalStatisticsView
    } else {
        showPaywall = true
    }
} label: {
    HStack(spacing: HLSpacing.sm) {
        // icon + title (existing pattern)

        if !proManager.canAccessAnalytics {
            ProBadge()  // or lock icon
        }

        Spacer()
        Image(systemName: "chevron.right")
            .font(.system(size: min(chevronSize, 16)))
            .foregroundColor(.hlTextTertiary)
    }
}
```

## Open Questions

1. **Confetti Animation Source**
   - What we know: `Effects.swift` exists in DesignSystem with `CelebrationOverlay`. Need to verify if it includes confetti-style particles or just a simple overlay.
   - What's unclear: Whether existing celebration animation is sufficient for a "full-screen celebration modal with confetti" per D-01.
   - Recommendation: Check `Effects.swift` during implementation. If no confetti exists, build a simple `Canvas`-based particle effect. Keep it lightweight -- 15-20 shapes falling, 2-second duration.

2. **PaywallView Copy Improvements (PRO-06)**
   - What we know: Current copy is functional but generic ("Unlock your full potential").
   - What's unclear: Exact copy that converts best. D-08 leaves this to Claude's Discretion.
   - Recommendation: Use benefit-focused copy emphasizing outcomes over features. E.g., "Build habits that last" > "Unlock unlimited habits". Social proof angle: "Join 1000+ users building better habits."

## Sources

### Primary (HIGH confidence)
- Project source code: TabBarView.swift, PaywallView.swift, PremiumGateView.swift, ProManager.swift, ContentView.swift, UserProfileView.swift, OnboardingView.swift, ReferralCodeEntryView.swift, HomeDashboardView.swift
- CONTEXT.md: All locked decisions D-01 through D-13

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Pure SwiftUI, no new dependencies, all patterns exist in codebase
- Architecture: HIGH - Extending existing infrastructure only, no new architectural decisions
- Pitfalls: HIGH - Direct code analysis reveals exact integration points and potential conflicts

**Research date:** 2026-03-25
**Valid until:** 2026-04-25 (stable -- no external dependencies)
