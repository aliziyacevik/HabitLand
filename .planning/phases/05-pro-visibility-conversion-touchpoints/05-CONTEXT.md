# Phase 5: Pro Visibility & Conversion Touchpoints - Context

**Gathered:** 2026-03-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Add compelling Pro upgrade touchpoints at natural engagement moments for free users: streak milestone celebrations, Sleep tab lock badge, enhanced paywall with referral entry, profile statistics gating, and onboarding Pro offer. Does NOT change Pro/Free tier limits or add new premium features — only surfaces existing Pro value more effectively.

</domain>

<decisions>
## Implementation Decisions

### Streak Milestone Celebration
- **D-01:** Full-screen celebration modal (sheet) with confetti when user hits streak milestones. All users see the celebration; free users get a Pro CTA ("Unlock detailed stats with Pro"), Pro users get just the congrats.
- **D-02:** Claude's Discretion on which milestones trigger: 7, 14, 30 days are natural anchors aligned with existing achievement system ("On Fire" = 7, "Committed" = 14, "Unstoppable" = 30).
- **D-03:** Show only once per milestone (track shown milestones in UserDefaults to avoid repeat).

### Sleep Tab Lock Badge
- **D-04:** Small crown icon next to "Sleep" text label in TabBarView — indicates premium content. Only shown for non-Pro users.
- **D-05:** Tapping Sleep tab navigates normally — existing `blurredPremiumGate` modifier in ContentView handles the gate. No behavior change needed, just add the visual crown badge.

### Paywall Improvements
- **D-06:** "Got a referral?" text link in bottom footer alongside "Restore Purchases" — secondary action, doesn't distract from purchase buttons.
- **D-07:** Tapping "Got a referral?" opens the existing referral code entry flow (already built in Phase 2).
- **D-08:** Strengthen paywall value proposition with benefit-focused copy (Claude's Discretion on exact copy).

### Profile Statistics Gate
- **D-09:** PersonalStatisticsView link in UserProfileView shows a lock icon for free users. Tapping opens paywall with analytics context.
- **D-10:** Profile itself stays fully visible — only the detailed statistics are Pro-gated.

### Onboarding Pro Offer
- **D-11:** Dedicated full-screen onboarding page after habit selection (before landing on Home). Shows Pro feature highlights: unlimited habits, sleep tracking, detailed analytics, all achievements.
- **D-12:** Two CTAs: "Start Pro" (opens paywall) and "Maybe Later" (continues to Home). No pressure, soft sell.
- **D-13:** Replaces or extends the existing trial welcome banner logic (`hasTrialBeenOffered` in ContentView).

### Claude's Discretion
- Exact celebration modal design (confetti animation, colors, layout)
- Milestone trigger pattern (which streak milestones get celebration)
- Paywall copy improvements and value proposition layout
- Crown badge size and positioning in TabBarView
- Onboarding Pro screen illustration/layout

</decisions>

<canonical_refs>
## Canonical References

No external specs — requirements are fully captured in decisions above.

### Key source files
- `HabitLand/Components/Navigation/TabBarView.swift` — Custom tab bar where crown badge will be added
- `HabitLand/ContentView.swift` — Root navigation, Sleep tab blurredPremiumGate, trial banner logic
- `HabitLand/Screens/Premium/PaywallView.swift` — Paywall with contextual headers, pricing
- `HabitLand/Screens/Premium/PremiumGateView.swift` — blurredPremiumGate modifier, ProBadge component
- `HabitLand/Screens/Profile/UserProfileView.swift` — Profile with quickLinks to PersonalStatisticsView
- `HabitLand/Screens/Onboarding/OnboardingView.swift` — Onboarding flow
- `HabitLand/Services/ProManager.swift` — isPro, referral logic, PaywallContext enum
- `HabitLand/Models/Models.swift` — Habit.currentStreak, achievement definitions

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `blurredPremiumGate(feature:icon:context:)` — Already on Sleep tab in ContentView:118, reusable for any gated content
- `ProBadge` component — Small capsule "PRO" badge with gradient, can be adapted for crown badge
- `PaywallContext` enum — Existing contexts (.sleepTracking, .achievements, .analytics) for contextual paywall headers
- `PaywallView(context:)` — Already supports contextual display based on PaywallContext
- `HLAnimation.spring` — Established animation pattern for tab interactions

### Established Patterns
- Tab bar: Custom `TabBarView` with `HLTab` enum and `TabBarItem` — icon + text label per tab
- Premium gating: `.blurredPremiumGate()` modifier for tab-level gating, `.premiumGated()` for section-level
- Sheet presentation: `HLSheetContent` modifier for consistent spring transitions on all sheets
- Onboarding: Multi-step flow in `OnboardingView` with page-based navigation

### Integration Points
- `TabBarView` — Add crown badge next to Sleep tab label for non-Pro users
- `ContentView` — Trial banner logic can be extended/replaced with onboarding Pro offer
- `PaywallView` — Add "Got a referral?" footer link
- `UserProfileView` — Modify quickLink for PersonalStatisticsView to show lock + paywall
- `HomeDashboardView` — Trigger streak celebration modal based on currentStreak values

</code_context>

<specifics>
## Specific Ideas

- Crown badge on Sleep tab, not lock icon — premium feel, not "blocked" feel
- Celebration modal for all users (not just free) — Pro users get congrats without CTA
- "Got a referral?" is a subtle footer link, not a prominent button — don't distract from purchase
- Onboarding Pro offer is a dedicated screen (not sheet/banner) — full commitment to the pitch

</specifics>

<deferred>
## Deferred Ideas

- Referral system enhancement (1 week pro rewards, activation conditions) — future milestone if organic retention insufficient
- Time-based or success-based pro upsells — post-launch based on conversion data
- A/B testing paywall designs — AGR-02 in future requirements

</deferred>

---

*Phase: 05-pro-visibility-conversion-touchpoints*
*Context gathered: 2026-03-25*
