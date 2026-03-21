---
phase: 1
slug: monetization-platform-activation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-21
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest / XCUITest (built-in) |
| **Config file** | `HabitLandTests/` and `HabitLandUITests/` targets |
| **Quick run command** | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:HabitLandTests` |
| **Full suite command** | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16 Pro'` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick unit tests
- **After every plan wave:** Run full suite
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | MON-01, MON-02 | manual | StoreKit sandbox purchase | N/A | ⬜ pending |
| 01-01-02 | 01 | 1 | MON-05 | manual | Reinstall + verify Pro | N/A | ⬜ pending |
| 01-01-03 | 01 | 1 | MON-04 | manual | Settings deep link | N/A | ⬜ pending |
| 01-02-01 | 02 | 1 | MON-03 | unit | Build verification | N/A | ⬜ pending |
| 01-02-02 | 02 | 1 | QAL-01 | grep | `grep -r 'screenshotMode' --include='*.swift'` | N/A | ⬜ pending |
| 01-03-01 | 03 | 2 | PLT-01 | manual | iCloud sync test | N/A | ⬜ pending |
| 01-03-02 | 03 | 2 | PLT-02 | manual | HealthKit authorization | N/A | ⬜ pending |
| 01-03-03 | 03 | 2 | PLT-03 | manual | Push notification delivery | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements. No new test framework needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| StoreKit purchase flow | MON-01, MON-02 | Requires StoreKit sandbox environment | Purchase yearly and lifetime in Simulator, verify Pro access |
| Purchase persistence | MON-05 | Requires app reinstall | Delete and reinstall app, verify Pro status restored |
| Subscription management | MON-04 | Requires iOS Settings deep link | Tap "Manage Subscription" in Settings, verify redirect |
| Contextual paywall triggers | MON-03 | UI interaction flow | Create 4th habit as free user, verify paywall appears |
| iCloud sync | PLT-01 | Requires real iCloud account | Sign in, create habit, verify sync on second device |
| HealthKit data | PLT-02 | Requires HealthKit permissions | Authorize, verify health data appears in app |
| Push notifications | PLT-03 | Requires notification permission | Enable, verify streak reminder delivered |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
