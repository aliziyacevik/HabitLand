# ISSUE-001: Stale "friends connected" text in Premium Gate

**Severity:** Low
**Category:** UI / Stale Reference
**Screen:** Sleep tab premium gate (PremiumGateView)
**File:** `HabitLand/Screens/Premium/PremiumGateView.swift:258-263`

## Description

PremiumGateView queries `@Query private var friends: [Friend]` and conditionally shows "{N} friends connected" text in the "Don't lose your progress" section. Since social features have been removed, this text references a non-functional feature.

## Impact

- If Friend data exists in the database (e.g., from seeded data or previous versions), the text appears and references social features that don't exist in the app.
- Fresh installs won't show this (friends.count == 0), but users upgrading from older versions might see it.

## Fix

Remove the `friends.count > 0` block or remove the `@Query private var friends` entirely from PremiumGateView.

## Screenshot

See: `free_01_sleep_premium_gate.png` - shows "9 friends connected" text
