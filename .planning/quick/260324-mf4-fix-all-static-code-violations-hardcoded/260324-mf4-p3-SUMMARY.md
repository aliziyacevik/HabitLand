---
phase: quick
plan: 260324-mf4-p3
subsystem: ui-accessibility
tags: [scaledmetric, dynamic-type, frame-sizes, accessibility]
key-files:
  modified:
    - HabitLand/Screens/Habits/EditHabitView.swift
    - HabitLand/Screens/Habits/CreateHabitView.swift
    - HabitLand/Screens/Home/HabitTimerView.swift
    - HabitLand/Screens/Home/PomodoroView.swift
    - HabitLand/Screens/Home/HomeDashboardView.swift
    - HabitLand/Screens/Onboarding/OnboardingView.swift
    - HabitLand/Screens/Analytics/WeeklyAnalyticsView.swift
    - HabitLand/Screens/Home/HabitChainView.swift
decisions:
  - "Used min() cap at ~1.3x base value for all @ScaledMetric frame sizes"
  - "Left 100pt progress ring and 60pt progress bar as-is (visual indicators, not interactive)"
metrics:
  duration: 687s
  completed: "2026-03-24"
  tasks: 4
  files: 8
---

# Plan 3: Hardcoded Frame Sizes to @ScaledMetric Summary

Wrapped all hardcoded frame sizes >= 40pt with @ScaledMetric instance properties and min() caps to support Dynamic Type scaling while preventing excessive growth at Accessibility XXL sizes.

## Tasks Completed

| Task | Description | Commit | Files |
|------|------------|--------|-------|
| 3.1 | EditHabitView frame sizes | 773340c | EditHabitView.swift |
| 3.2 | CreateHabitView frame sizes | d63c414 | CreateHabitView.swift |
| 3.3 | Timer/control frame sizes | 7c4e615 | HabitTimerView.swift, PomodoroView.swift |
| 3.4 | Remaining frame sizes | ca6bb3b | HomeDashboardView.swift, OnboardingView.swift, WeeklyAnalyticsView.swift, HabitChainView.swift |

## Changes Summary

### @ScaledMetric Properties Added

| File | Property | Base | Cap | Usage |
|------|----------|------|-----|-------|
| EditHabitView | iconButtonSize | 40 | 56 | Icon, color, day selectors |
| CreateHabitView | iconButtonSize | 40 | 56 | Color, day, template selectors |
| HabitTimerView | controlButtonSize | 56 | 72 | Cancel/skip buttons |
| HabitTimerView | playButtonSize | 72 | 96 | Play/pause button |
| HabitTimerView | timerRingSize | 240 | 300 | Timer ring |
| PomodoroView | closeButtonSize | 40 | 56 | Close button |
| PomodoroView | controlButtonSize | 56 | 72 | Reset/skip buttons |
| PomodoroView | playButtonSize | 72 | 96 | Play/pause button |
| PomodoroView | timerRingSize | 260 | 320 | Timer ring |
| HomeDashboardView | iconButtonSize | 40 | 56 | Habit row icons |
| HomeDashboardView | touchTargetSize | 44 | 56 | Dismiss buttons |
| HomeDashboardView | streakCircleSize | 52 | 68 | Streak flame circle |
| HomeDashboardView | fabSize | 56 | 72 | FAB button |
| OnboardingView | iconButtonSize | 40 | 56 | Preview content icon |
| OnboardingView | avatarPickerSize | 48 | 64 | Avatar picker items |
| OnboardingView | avatarDisplaySize | 96 | 128 | Avatar display circle |
| LevelUpPreviewPage | badgeSize | 44 | 56 | Achievement badges |
| LevelUpPreviewPage | celebrationCircleSize | 140 | 180 | Hero circle |
| StreakPreviewContent | iconButtonSize | 40 | 56 | Habit card icon |
| WeeklyAnalyticsView | chartRingSize | 160 | 200 | Completion ring |
| HabitChainView | closeButtonSize | 40 | 56 | Close button + spacer |
| HabitChainView | habitCircleSize | 120 | 160 | Habit display circle |
| HabitChainView | celebrationCircleSize | 140 | 180 | Chain complete circle |

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None.

## Verification

- Build: SUCCEEDED (xcodebuild build)
- No hardcoded frame sizes >= 40pt remain in modified files (except 100pt progress ring and 60pt progress bar which are visual-only indicators)
