---
phase: 02-referral-system
plan: 02
subsystem: ui
tags: [swiftui, referral, sharelink, onboarding, settings, cloudkit]

# Dependency graph
requires:
  - phase: 02-referral-system/01
    provides: "UserProfile referral fields, ReferralCodeEntryView, CloudKitManager referral methods, ProManager referral Pro"
provides:
  - "InviteFriendsView with referral code display, tap-to-copy, ShareLink, and stats"
  - "OnboardingView optional referral code entry sheet after StarterHabitsView"
  - "GeneralSettingsView conditional Enter Referral Code row"
  - "SharedChallengesView challenge share with ?ref= referral parameter"
affects: [03-aso-optimization, 04-quality-polish]

# Tech tracking
tech-stack:
  added: []
  patterns: ["Locale-aware share messages (Turkish/English)", "Conditional UI based on redemption state"]

key-files:
  created: []
  modified:
    - HabitLand/Screens/Social/InviteFriendsView.swift
    - HabitLand/Screens/Onboarding/OnboardingView.swift
    - HabitLand/Screens/Settings/GeneralSettingsView.swift
    - HabitLand/Screens/Social/SharedChallengesView.swift

key-decisions:
  - "Referral entry presented as sheet after StarterHabitsView (not TabView page) per Pitfall 6"
  - "OnComplete called on sheet dismissal to ensure onboarding completes regardless of referral action"
  - "Challenge share URL uses ?ref= parameter for attribution tracking"

patterns-established:
  - "Locale-aware messaging: Locale.current.language.languageCode == .turkish for Turkish/English"
  - "Conditional settings rows: disappear when condition no longer applies (referredByCode != nil)"

requirements-completed: [GRW-01, GRW-02, GRW-03, GRW-04, GRW-05]

# Metrics
duration: 6min
completed: 2026-03-21
---

# Phase 02 Plan 02: Referral UI Summary

**Full referral UI flow with code display, tap-to-copy, localized ShareLink, onboarding/settings entry points, and referral-tagged challenge sharing**

## Performance

- **Duration:** 6 min
- **Started:** 2026-03-21T10:26:04Z
- **Completed:** 2026-03-21T10:31:42Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- InviteFriendsView fully refactored: personal referral code with tap-to-copy toast, ShareLink with localized Turkish/English message, referral stats section, and inline ReferralCodeEntryView for code redemption
- OnboardingView gains optional referral code entry sheet after StarterHabitsView with skip option, properly chaining awardFirstXP and onComplete
- GeneralSettingsView adds "Enter Referral Code" row with gift.fill icon that auto-hides after redemption
- SharedChallengesView challenge cards have ShareLink with App Store URL including ?ref=[referralCode] for attribution

## Task Commits

Each task was committed atomically:

1. **Task 1: Refactor InviteFriendsView and add referral code entry to onboarding and settings** - `97ced7c` (feat)
2. **Task 2: Add referral-tagged share links to challenge sharing** - `d42cf0d` (feat)

## Files Created/Modified
- `HabitLand/Screens/Social/InviteFriendsView.swift` - Full refactor: referral code display, tap-to-copy, ShareLink, stats, code entry section
- `HabitLand/Screens/Onboarding/OnboardingView.swift` - Optional referral entry sheet after StarterHabitsView
- `HabitLand/Screens/Settings/GeneralSettingsView.swift` - Conditional "Enter Referral Code" row in Account section
- `HabitLand/Screens/Social/SharedChallengesView.swift` - ShareLink on challenge cards with ?ref= parameter

## Decisions Made
- Referral entry presented as sheet (not fullScreenCover) to allow easy skip/dismiss
- OnComplete fires on sheet dismissal (onDismiss handler) ensuring onboarding always completes
- Turkish used as primary locale for share messages with English fallback
- Challenge share URL uses ?ref= query parameter with raw referral code (not HBT- prefixed)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Known Stubs
None - all UI wired to real data sources (CloudKit, SwiftData UserProfile).

## Next Phase Readiness
- Referral system fully complete (both Plan 01 backend and Plan 02 UI)
- Ready for Phase 03 ASO optimization
- App Store URL placeholder (id000000000) needs real ID when app is published

---
*Phase: 02-referral-system*
*Completed: 2026-03-21*
