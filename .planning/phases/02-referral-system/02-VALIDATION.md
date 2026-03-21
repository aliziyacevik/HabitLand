---
phase: 2
slug: referral-system
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-21
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest (built-in) |
| **Config file** | `HabitLandTests/` target |
| **Quick run command** | `xcodebuild build -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -quiet` |
| **Full suite command** | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16 Pro'` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Build verification
- **After every plan wave:** Full build
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | GRW-01 | grep | `grep 'referralCode' HabitLand/Models/Models.swift` | N/A | ⬜ pending |
| 02-01-02 | 01 | 1 | GRW-01 | grep | `grep 'referralRedemption' HabitLand/Services/CloudKitManager.swift` | N/A | ⬜ pending |
| 02-02-01 | 02 | 2 | GRW-01, GRW-02, GRW-03 | manual | Referral code share + redeem flow | N/A | ⬜ pending |
| 02-02-02 | 02 | 2 | GRW-05 | grep | `grep 'ref=' HabitLand/Screens/Social/` | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements. No new test framework needed.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Referral code generation | GRW-01 | UI interaction | Open Invite Friends, verify code displayed |
| Referral code redemption | GRW-02, GRW-03 | Two-device flow | Enter code on second device, verify both get Pro |
| CloudKit referral tracking | GRW-04 | Requires iCloud | Redeem code, check CloudKit Dashboard for record |
| Challenge share link | GRW-05 | UI interaction | Share challenge, verify link contains ref code |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
