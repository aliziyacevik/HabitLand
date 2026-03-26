# ISSUE-001: Stale Trial System References

**Severity**: Low (Cosmetic / Dead Code)
**Category**: Code Cleanup
**Status**: Open

## Description
The trial system was reportedly removed, but several references remain:
- `ContentView.swift`: `TrialExpiryPaywallView`, `showTrialExpiryPaywall`, `shouldShowTrialExpiryPaywall`
- `ProManager.swift`: `startInAppTrial()`, `hasTrialExpired`, trial notification scheduling
- `PaywallView.swift`: `isTrialEligible`, `trialBanner`, trial-related UI elements

## Impact
Benign — `hasTrialExpired` returns false if no trial was ever started, so the paywall never shows.
However, this is dead code that adds maintenance burden.

## Recommendation
Remove trial-related code from ContentView.swift and ProManager.swift, or keep it if trial feature is planned for future.
