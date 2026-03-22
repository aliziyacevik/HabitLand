# ISSUE-011: Settings Shows "Free Plan" with "PRO" Badge and "All features unlocked"

**Category:** UI / Logic
**Severity:** Medium

## Description

In screenshot mode (debug), `isPro` returns `true` because of the debug override. This causes the Settings screen to show:
- "Free Plan" (from `currentPlanDisplay` which checks `purchasedProductIDs`)
- "All features unlocked" subtitle
- A "PRO" badge

The "Free Plan" label is misleading because the user actually has Pro access. The issue is that `currentPlanDisplay` checks `purchasedProductIDs` (empty in debug) rather than `isPro`.

## Steps to Reproduce

1. Run in debug mode or screenshot mode
2. Navigate to Profile > Settings
3. Observe "Free Plan" shown with "All features unlocked" and PRO badge

## Expected Result

Should show a consistent status: either "Pro (Debug)" or not show the PRO badge with Free Plan.

## File Reference

`HabitLand/Services/ProManager.swift` lines 37-47: `currentPlanDisplay` doesn't check debug/screenshot overrides.

## Impact

Minor in production (debug-only), but confusing during testing and reviews.

## Recommended Fix

Update `currentPlanDisplay` to check `isPro` first before checking product IDs.
