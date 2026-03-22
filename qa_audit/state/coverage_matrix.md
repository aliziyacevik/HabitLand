# Coverage Matrix (Updated 2026-03-22)

## Runtime Testing (QAAuditFullTests)

| Area | Screens | Screenshots | Runtime Tested | Status |
|------|---------|-------------|----------------|--------|
| Home Dashboard | 7 | qa_01_*.png (6) | Yes | **PASS** |
| Habits List/Detail/Create | 10 | qa_02_*.png (10) | Yes | **PASS** |
| Sleep Dashboard/Log/Insights | 5 | qa_03_*.png (6) | Yes | **PASS** |
| Social Hub/Friends/Leaderboard/Feed | 9 | qa_04_*.png (7) | Yes | **PASS** |
| Profile/Settings/Appearance/Privacy | 12 | qa_05_*.png (18) | Yes | **PASS** |
| Habit Completion | 1 | qa_06_*.png (1) | Yes | **PASS** |
| Sheet Transitions | 1 | qa_07_*.png (2) | Yes | **PASS** |
| Onboarding | 7 | qa_08_*.png (5) | Partial | **PASS** (test uses non-screenshotMode) |
| Premium Gates/Paywall | 4 | qa_10_*.png (4) | Yes | **PASS** |

## Coverage Summary
- **Total screens mapped:** 71
- **Screens with screenshots:** 46 unique captures
- **Runtime tested:** 50+ screens (via QAAuditFullTests + QAAuditTests)
- **Premium gate verified:** Sleep + Social gates confirmed
- **Paywall verified:** From gate and from settings
- **Coverage:** ~90% of reachable screens

## Not Testable (Blocked)
- iCloud Sync: Requires Apple Developer account
- HealthKit: Requires Apple Developer account
- Push Notifications: Requires Apple Developer account
- StoreKit real purchases: Requires App Store Connect
- Watch app: Requires watchOS simulator configuration
- Widget: Requires iOS 17 widget testing
