# Roadmap: HabitLand

## Milestones

- [x] **v1.0 MVP** - Phases 1-4 (shipped 2026-03-21)
- [ ] **v1.1 Pro Growth & Conversion** - Phase 5 (in progress)

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

<details>
<summary>v1.0 MVP (Phases 1-4) - SHIPPED 2026-03-21</summary>

- [x] **Phase 1: Monetization & Platform Activation** - Wire up real StoreKit 2 IAP, harden paywall for Apple review, enable iCloud/HealthKit/Push
- [x] **Phase 2: Referral System** - Build viral growth loop with referral codes, CloudKit tracking, and Pro rewards
- [x] **Phase 3: App Store Readiness** - Create ASO-optimized listing with screenshots, keywords, localization, and custom product pages
- [x] **Phase 4: Quality Hardening & Launch** - Strip debug artifacts, fix crash paths, test free tier, polish UI, and submit

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
- [x] 01-02-PLAN.md -- Blurred premium gates + subscription management UI in Settings
- [x] 01-03-PLAN.md -- Platform activation (iCloud, HealthKit, Push entitlements + APNs registration)

### Phase 2: Referral System
**Goal**: Users can invite friends and both parties earn Pro rewards, creating a viral growth loop
**Depends on**: Phase 1
**Requirements**: GRW-01, GRW-02, GRW-03, GRW-04, GRW-05
**Success Criteria** (what must be TRUE):
  1. User can generate a personal referral code and share it via the iOS share sheet
  2. User who enters a referral code during onboarding or in settings receives 1 week of free Pro access
  3. Original referrer receives 1 week of free Pro access when their friend redeems the code
  4. Social challenge share links include an app download link for non-users
**Plans**: 3 plans

Plans:
- [x] 02-01-PLAN.md -- Data model + ProManager referral Pro + CloudKit tracking + code entry component
- [x] 02-02-PLAN.md -- InviteFriendsView refactor + onboarding/settings entry points + challenge share links
- [x] 02-03-PLAN.md -- Gap closure: referrer Pro grant + max 4 referral cap + on-launch reward check

### Phase 3: App Store Readiness
**Goal**: App Store listing is complete, optimized for discovery, and ready for submission
**Depends on**: Phase 2
**Requirements**: ASR-01, ASR-02, ASR-03, ASR-04, ASR-05, ASR-06
**Success Criteria** (what must be TRUE):
  1. App Store screenshots exist for 6.7" and 5.5" sizes showing key value propositions (habits, streaks, social, sleep)
  2. Title, subtitle (30 chars), keywords (100 chars), and description are ASO-optimized in English and Turkish
  3. Privacy policy and terms of use URLs are accessible and App icon renders correctly at all required sizes
  4. Custom Product Pages are configured targeting distinct audiences (fitness, productivity, sleep)
**Plans**: 2 plans

Plans:
- [x] 03-01-PLAN.md -- ASO metadata (EN+TR), legal URL verification, icon check, CPP configuration
- [x] 03-02-PLAN.md -- Screenshot pipeline Turkish localization + headline updates + visual verification

### Phase 4: Quality Hardening & Launch
**Goal**: App is production-clean, crash-free, and verified from a fresh free-tier perspective before App Store submission
**Depends on**: Phase 3
**Requirements**: QAL-01, QAL-02, QAL-03, QAL-04, QAL-05, QAL-06
**Success Criteria** (what must be TRUE):
  1. All debug bypasses (screenshot mode Pro unlock) are guarded with `#if DEBUG` and no `fatalError()` crash paths exist in production code
  2. Free tier experience works end-to-end on a clean device: 3-habit limit enforced, paywall triggers correctly, every Pro-gated screen shows upsell
  3. No unguarded `print()` statements remain -- all logging uses `os_log` or is removed
  4. UI animations, transitions, and edge cases are polished; launch time and scroll performance meet acceptable thresholds
**Plans**: 3 plans

Plans:
- [x] 04-01-PLAN.md -- HLLogger wrapper + print() replacement + screenshotMode #if DEBUG guards + crash path fix
- [x] 04-02-PLAN.md -- Sheet transition polish (HLSheetContent modifier) + empty states + edge case fixes
- [x] 04-03-PLAN.md -- Automated quality audits + manual free tier QA + performance verification

</details>

### v1.1 Pro Growth & Conversion (In Progress)

**Milestone Goal:** Increase Pro conversion rate by placing compelling upgrade touchpoints at natural engagement moments throughout the app

- [ ] **Phase 5: Pro Visibility & Conversion Touchpoints** - Add streak nudges, tab lock badges, enhanced paywall CTA, and profile upgrade prompts for free users

## Phase Details

### Phase 5: Pro Visibility & Conversion Touchpoints
**Goal**: Free users encounter compelling, contextually relevant Pro upgrade prompts at key engagement moments -- streak milestones, tab navigation, and profile viewing
**Depends on**: Phase 4
**Requirements**: PRO-01, PRO-02, PRO-03, PRO-04, PRO-05, PRO-06, PRO-07
**Success Criteria** (what must be TRUE):
  1. Free user reaching a 7-day streak sees a congratulatory banner that highlights Pro benefits and links to the paywall
  2. Free user sees a lock badge icon on the Sleep tab in the tab bar, clearly indicating premium content
  3. Free user tapping the Sleep tab sees a blurred premium gate overlay with a clear path to upgrade
  4. Paywall includes a "Got a referral?" button that opens the referral code entry flow
  5. Profile screen statistics section is locked behind Pro with an upgrade CTA visible to free users
  6. Paywall displays a compelling value proposition with benefit-focused copy and stronger call-to-action
  7. New user completing onboarding sees a dedicated Pro offer screen with feature highlights and option to proceed or skip
**Plans**: 2 plans
**UI hint**: yes

Plans:
- [ ] 05-01-PLAN.md -- Streak milestone celebration + Sleep tab crown badge + profile statistics lock
- [ ] 05-02-PLAN.md -- Paywall referral link + value proposition copy + onboarding Pro offer screen

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Monetization & Platform Activation | v1.0 | 3/3 | Complete | 2026-03-21 |
| 2. Referral System | v1.0 | 3/3 | Complete | 2026-03-21 |
| 3. App Store Readiness | v1.0 | 2/2 | Complete | 2026-03-21 |
| 4. Quality Hardening & Launch | v1.0 | 3/3 | Complete | 2026-03-21 |
| 5. Pro Visibility & Conversion Touchpoints | v1.1 | 0/2 | In progress | - |
