# HabitLand QA Audit — Master Issue List
**Date:** 2026-03-24 (Updated)
**Previous Audit:** 2026-03-23
**Tester:** QA Audit Agent
**Build:** 1.0.0 (Build 1)

## Summary
| Severity | Total | Fixed (prev) | New | Open |
|----------|-------|-------------|-----|------|
| Critical | 3     | 1           | 2   | 2    |
| High     | 5     | 4           | 1   | 1    |
| Medium   | 7     | 1           | 2   | 6    |
| Low      | 5     | 0           | 1   | 5    |
| **Total**| **20**| **6**       | **6** | **14** |

---

## Critical Issues

### ISSUE-001: Missing modelContext.save() after insert/delete in 10+ files [FIXED prev]
- **Status:** FIXED (Mar 23)

### ISSUE-015: Force unwrap on URL string creation — crash risk
- **Category:** Crash
- **Severity:** Critical
- **Files:**
  - SharedChallengesView.swift:213 — `URL(string: challengeShareURL)!`
  - InviteFriendsView.swift:126 — `URL(string: appStoreURL)!`
- **Impact:** App crash if URL string is malformed
- **Status:** OPEN

### ISSUE-016: Force unwrap on Calendar.date(byAdding:) — crash risk
- **Category:** Crash
- **Severity:** Critical
- **Files:**
  - HabitScheduleView.swift:260 — `Calendar.current.date(byAdding:)!`
  - HabitStatisticsView.swift:414 — `Calendar.current.date(byAdding:)!`
  - HabitHistoryView.swift:192 — `Calendar.current.date(byAdding:)!`
- **Impact:** Potential crash if date arithmetic returns nil
- **Status:** OPEN

---

## High Issues

### ISSUE-002: Achievement popup blocks navigation [FIXED prev partial]
- **Status:** Partially fixed (auto-dismiss added) but still blocks XCUITest navigation. Real user impact reduced but not eliminated.

### ISSUE-003: "White Nois" text truncation [FIXED prev]
- **Status:** FIXED

### ISSUE-004: Demo completion times "00:00" [FIXED prev]
- **Status:** FIXED

### ISSUE-005: "Well Round..." achievement name truncated [FIXED prev]
- **Status:** FIXED

### ISSUE-017: Force unwrap after nil check — fragile pattern
- **Category:** Crash Risk
- **Severity:** High
- **Files:**
  - PersonalStatisticsView.swift:106 — `rate > best!.1`
  - MonthlyAnalyticsView.swift:469 — `profile!.name`
- **Impact:** Crash if logic changes or threading races
- **Status:** OPEN

---

## Medium Issues

### ISSUE-006: Sleep quality emoji render as "?" [Known]
- **Status:** Known (simulator rendering) — verify on real device

### ISSUE-007: "Ha..." avatar badge truncation on Home Dashboard
- **Status:** OPEN

### ISSUE-008: Missing .accessibilityLabel on interactive elements
- **Status:** OPEN

### ISSUE-010: Pomodoro timer overnight/restart edge cases
- **Status:** OPEN

### ISSUE-018: 15+ hardcoded font sizes without @ScaledMetric
- **Category:** Accessibility
- **Severity:** Medium
- **Files:** Effects.swift:625,754, OnboardingView.swift:1361, AchievementsShowcaseView.swift:56, HomeDashboardView.swift:322,847,901,1009, SpotlightCoachingView.swift:89, PersonalStatisticsView.swift:181
- **Impact:** Icons/text don't scale with Dynamic Type accessibility settings
- **Status:** OPEN

### ISSUE-019: Friend profile empty space below action buttons
- **Category:** UX
- **Severity:** Medium
- **Evidence:** 04_friend_profile.png — large empty area below Nudge/Challenge buttons
- **Status:** OPEN

---

## Low Issues

### ISSUE-011: Empty state on Friend Profile — no shared habits
- **Status:** OPEN (merged into ISSUE-019)

### ISSUE-012: Settings gear icon has no text label (discoverable via quick links)
- **Status:** OPEN

### ISSUE-013: Social Feed uses letter avatars instead of actual avatars
- **Status:** OPEN

### ISSUE-014: Sleep History "?" quality icons (same as ISSUE-006)
- **Status:** Known

### ISSUE-020: Home scroll content shallow — mid/bottom/deep identical
- **Category:** UX
- **Severity:** Low
- **Evidence:** 01_home_mid = 01_home_bottom = 01_home_deep (identical content)
- **Description:** Home page content ends at Focus Timer card — feels shallow for a dashboard
- **Status:** OPEN (product decision)
