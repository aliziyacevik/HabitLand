# Roadmap: HabitLand

## Overview

HabitLand is a feature-complete iOS habit tracker that needs monetization, growth mechanics, App Store metadata, and launch polish to ship. The work progresses from revenue foundation (StoreKit 2 IAP + platform activation) through viral growth (referral system), App Store presence (ASO, screenshots, localization), and final quality hardening before submission. Apple Developer account approval is the critical external gate -- it unlocks sandbox IAP testing, CloudKit, HealthKit, and push notifications.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Monetization & Platform Activation** - Wire up real StoreKit 2 IAP, harden paywall for Apple review, enable iCloud/HealthKit/Push
- [ ] **Phase 2: Referral System** - Build viral growth loop with referral codes, CloudKit tracking, and Pro rewards
- [ ] **Phase 3: App Store Readiness** - Create ASO-optimized listing with screenshots, keywords, localization, and custom product pages
- [ ] **Phase 4: Quality Hardening & Launch** - Strip debug artifacts, fix crash paths, test free tier, polish UI, and submit

## Phase Details

### Phase 1: Monetization & Platform Activation
**Goal**: Users can purchase Pro via real IAP and the app runs with all platform capabilities (iCloud, HealthKit, Push) enabled
**Depends on**: Nothing (first phase)
**Requirements**: MON-01, MON-02, MON-03, MON-04, MON-05, MON-06, PLT-01, PLT-02, PLT-03
**Success Criteria** (what must be TRUE):
  1. User can purchase yearly subscription ($19.99/yr) and lifetime unlock ($39.99) through the paywall and receive Pro access immediately
  2. User sees a contextual paywall with clear pricing, trial terms, and cancellation info when hitting free tier limits (4th habit, analytics, challenge join)
  3. User can manage or cancel subscription from Settings, and purchases persist across app reinstall
  4. App syncs data via iCloud, reads real HealthKit data, and delivers push notifications for streak reminders
**Plans**: 3 plans

Plans:
- [x] 01-01-PLAN.md -- Security hardening + PaywallContext enum + contextual PaywallView header
- [ ] 01-02-PLAN.md -- Blurred premium gates + subscription management UI in Settings
- [ ] 01-03-PLAN.md -- Platform activation (iCloud, HealthKit, Push entitlements + APNs registration)

### Phase 2: Referral System
**Goal**: Users can invite friends and both parties earn Pro rewards, creating a viral growth loop
**Depends on**: Phase 1
**Requirements**: GRW-01, GRW-02, GRW-03, GRW-04, GRW-05
**Success Criteria** (what must be TRUE):
  1. User can generate a personal referral code and share it via the iOS share sheet
  2. User who enters a referral code during onboarding or in settings receives 1 week of free Pro access
  3. Original referrer receives 1 week of free Pro access when their friend redeems the code
  4. Social challenge share links include an app download link for non-users
**Plans**: TBD

Plans:
- [ ] 02-01: TBD

### Phase 3: App Store Readiness
**Goal**: App Store listing is complete, optimized for discovery, and ready for submission
**Depends on**: Phase 2
**Requirements**: ASR-01, ASR-02, ASR-03, ASR-04, ASR-05, ASR-06
**Success Criteria** (what must be TRUE):
  1. App Store screenshots exist for 6.7" and 5.5" sizes showing key value propositions (habits, streaks, social, sleep)
  2. Title, subtitle (30 chars), keywords (100 chars), and description are ASO-optimized in English and Turkish
  3. Privacy policy and terms of use URLs are accessible and App icon renders correctly at all required sizes
  4. Custom Product Pages are configured targeting distinct audiences (fitness, productivity, sleep)
**Plans**: TBD

Plans:
- [ ] 03-01: TBD

### Phase 4: Quality Hardening & Launch
**Goal**: App is production-clean, crash-free, and verified from a fresh free-tier perspective before App Store submission
**Depends on**: Phase 3
**Requirements**: QAL-01, QAL-02, QAL-03, QAL-04, QAL-05, QAL-06
**Success Criteria** (what must be TRUE):
  1. All debug bypasses (screenshot mode Pro unlock) are guarded with `#if DEBUG` and no `fatalError()` crash paths exist in production code
  2. Free tier experience works end-to-end on a clean device: 3-habit limit enforced, paywall triggers correctly, every Pro-gated screen shows upsell
  3. No unguarded `print()` statements remain -- all logging uses `os_log` or is removed
  4. UI animations, transitions, and edge cases are polished; launch time and scroll performance meet acceptable thresholds
**Plans**: TBD

Plans:
- [ ] 04-01: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Monetization & Platform Activation | 0/3 | Planning complete | - |
| 2. Referral System | 0/0 | Not started | - |
| 3. App Store Readiness | 0/0 | Not started | - |
| 4. Quality Hardening & Launch | 0/0 | Not started | - |
