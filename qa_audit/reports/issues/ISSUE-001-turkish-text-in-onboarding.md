# ISSUE-001: Turkish Text Hardcoded in Onboarding Referral Sheet

**Category:** Localization / UI
**Severity:** High

## Description

The onboarding referral code entry sheet contains hardcoded Turkish text instead of English. This is the only screen in the app with non-English text, making it jarring and confusing for English-speaking users.

## Steps to Reproduce

1. Fresh install the app (or clear UserDefaults)
2. Complete the 4-page onboarding flow
3. Select starter habits and continue
4. Observe the referral code entry sheet

## Expected Result

All text should be in English (consistent with rest of app):
- "Do you have a referral code?"
- "Enter your friend's code, both of you get 1 week of Pro!"
- "Skip"

## Actual Result

Text appears in Turkish:
- "Davet kodun var mi?"
- "Arkadasinin kodunu gir, ikiniz de 1 hafta Pro kazanin!"
- "Atla"

## File Reference

`HabitLand/Screens/Onboarding/OnboardingView.swift` lines 180, 184, 204

## Recommended Fix

Replace Turkish strings with English equivalents:
- Line 180: `"Do you have a referral code?"`
- Line 184: `"Enter your friend's code - you both get 1 week of Pro!"`
- Line 204: `"Skip"`
