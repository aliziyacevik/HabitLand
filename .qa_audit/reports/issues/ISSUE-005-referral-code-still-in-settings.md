# ISSUE-005: "Enter Referral Code" still visible in Settings

**Severity:** Low / Informational
**Category:** UI / Stale Feature
**File:** `HabitLand/Screens/Settings/GeneralSettingsView.swift:104-109`

## Description

"Enter Referral Code" row is visible in Settings for free users. The task context states referral code entry was removed from PaywallView, but it remains accessible from Settings via `ReferralCodeEntryView`.

## Impact

Users can still enter referral codes from Settings. If the referral system is fully functional (extending Pro days), this may be intentional. If referral was supposed to be fully removed, this is stale UI.

## Fix

Confirm whether referral system should remain in Settings or be removed entirely.

## Screenshot

See: `free_04_settings.png` - shows "Enter Referral Code" row
