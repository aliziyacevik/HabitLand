---
phase: quick
plan: 260324-mf4-p2
subsystem: design-system
tags: [accessibility, dynamic-type, fonts, scaledmetric]
key-files:
  modified:
    - HabitLand/Screens/Home/HomeDashboardView.swift
    - HabitLand/Screens/Home/DailyHabitsOverview.swift
    - HabitLand/Screens/Onboarding/OnboardingView.swift
    - HabitLand/Screens/Habits/HabitListView.swift
    - HabitLand/Screens/Social/LeaderboardView.swift
    - HabitLand/Screens/Onboarding/OnboardingCompleteView.swift
    - HabitLand/DesignSystem/Effects.swift
    - HabitLand/Components/Gamification/MilestoneBadge.swift
    - HabitLand/Components/Gamification/AchievementBadge.swift
    - HabitLand/Components/Gamification/StreakFlame.swift
    - HabitLand/Components/Cards/StreakCard.swift
    - HabitLand/Components/Social/AvatarView.swift
    - HabitLand/Components/Common/HLButton.swift
decisions:
  - "Emoji fonts use @ScaledMetric + min() cap instead of HLFont tokens (emojis have no text style equivalent)"
  - "Proportional font sizes (e.g. size * 0.42) get min() caps rather than @ScaledMetric (already proportional to parent)"
metrics:
  duration: "~10 min"
  completed: "2026-03-24"
  tasks: 4
  files: 13
---

# Plan 2: Hardcoded Font Sizes -> Design System Tokens Summary

Replace all hardcoded `.font(.system(size: N))` with HLFont tokens, @ScaledMetric, or min() caps for Dynamic Type compliance.

## Completed Tasks

| Task | Name | Commit | Key Changes |
|------|------|--------|-------------|
| 2.1 | HomeDashboardView fonts | afd6c83 | 5 hardcoded sizes replaced with existing @ScaledMetric props + min() caps |
| 2.2 | DailyHabitsOverview fonts | 55a2147 | 2 hardcoded sizes (heart icon, HealthKit icon) replaced |
| 2.3 | OnboardingView fonts | d304d59 | 3 emoji sizes replaced; added 3 new @ScaledMetric properties |
| 2.4 | Remaining 10 files | a1e6ae9 | All parameterized font sizes now have min() caps |

## Approach

Three patterns used depending on context:

1. **SF Symbol icons with known sizes** -- Replaced with existing @ScaledMetric properties (e.g., `labelIconSize`, `tinyIconSize`) plus min() cap
2. **Emoji text** -- Added new @ScaledMetric properties (`avatarEmojiSize`, `selectorEmojiSize`, `podiumEmojiSize`) with min() caps, since emojis have no HLFont equivalent
3. **Parameterized/proportional sizes** -- Added min() caps to computed expressions (e.g., `min(lineWidth * 2.5, 24)`, `min(size * 0.42, 36)`)

## Deviations from Plan

None - plan executed exactly as written.

## Verification

- Build: xcodebuild build succeeded with zero errors
- grep for `.font(.system(size: [digit]` returns 0 matches across all 13 modified files
- No visual behavior changes; only Dynamic Type scaling behavior added

## Known Stubs

None.

## Self-Check: PASSED
