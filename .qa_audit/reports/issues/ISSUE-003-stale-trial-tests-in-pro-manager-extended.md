# ISSUE-003: Stale trial-related unit tests cause build failure

**Severity:** Critical (blocks all test runs)
**Category:** Build / Test
**File:** `HabitLandTests/ProManagerExtendedTests.swift:147-211`

## Description

ProManagerExtendedTests references removed trial-related members:
- `trialRemainingDays`
- `shouldShowTrialExpiryPaywall`
- `hasTrialExpired`
- `hasTrialBeenOffered`
- `startInAppTrial()`

These properties/methods were removed from ProManager when the trial system was removed, but the tests were not updated.

## Impact

All test runs fail at build time. This blocks CI and prevents running any unit or UI tests.

## Fix

Remove the 4 stale test functions:
- `trialRemainingDaysCalculation()`
- `shouldShowTrialExpiryPaywallWhenExpired()`
- `trialExpiryPaywallNotShownTwice()`
- `hasTrialBeenOfferedTracksCorrectly()`

**Status: FIXED in this audit**
