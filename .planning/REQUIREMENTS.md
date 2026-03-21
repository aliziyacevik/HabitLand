# Requirements: HabitLand

**Defined:** 2026-03-21
**Core Value:** Kullanıcıların alışkanlıklarını eğlenceli ve sosyal bir deneyimle kalıcı hale getirmesi

## v1 Requirements

Requirements for App Store launch milestone. Each maps to roadmap phases.

### Monetization

- [x] **MON-01**: User can purchase yearly Pro subscription ($19.99/yr) via StoreKit 2
- [x] **MON-02**: User can purchase lifetime Pro unlock ($39.99) via StoreKit 2
- [x] **MON-03**: User sees contextual paywall when hitting free tier limits (4th habit, analytics, challenge join)
- [x] **MON-04**: User can manage/cancel subscription from Settings via deep link to iOS subscription management
- [x] **MON-05**: User's purchase persists across app reinstall via receipt verification
- [x] **MON-06**: Pricing strategy finalized as $19.99/yr + $39.99 lifetime

### App Store Readiness

- [x] **ASR-01**: App Store screenshots created for 6.7" and 5.5" device sizes
- [x] **ASR-02**: App Store description, subtitle (30 chars), and keyword field (100 chars) optimized for ASO
- [x] **ASR-03**: Privacy policy and terms of use URLs set and accessible
- [x] **ASR-04**: App icon verified at all required sizes (1024x1024 down to 40x40)
- [x] **ASR-05**: Turkish localization for App Store listing (description, keywords, screenshots)
- [x] **ASR-06**: Custom Product Pages configured for different audiences (fitness, productivity, sleep)

### Quality & Polish

- [ ] **QAL-01**: Debug bypass (`-screenshotMode` Pro unlock) guarded with `#if DEBUG`
- [ ] **QAL-02**: All `fatalError()` crash paths replaced with graceful error handling
- [ ] **QAL-03**: All unguarded `print()` statements removed or replaced with `os_log`
- [ ] **QAL-04**: Free tier experience tested end-to-end on clean device
- [ ] **QAL-05**: General UI/UX polish pass (animations, transitions, edge cases)
- [ ] **QAL-06**: Performance optimization (launch time, scroll smoothness, memory)

### Growth

- [x] **GRW-01**: User can generate a referral code and share via share sheet
- [x] **GRW-02**: User who redeems a referral code gets 1 week Pro free
- [x] **GRW-03**: User who referred gets 1 week Pro free when friend redeems
- [x] **GRW-04**: Referral tracking via CloudKit public database
- [x] **GRW-05**: Social challenge share links include app download link for non-users

### Platform Activation

- [x] **PLT-01**: iCloud sync enabled after Apple Developer account approval
- [x] **PLT-02**: HealthKit permissions activated for real health data access
- [x] **PLT-03**: Push notifications enabled for streak reminders and weekly reports

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Engagement

- **ENG-01**: Weekly/monthly progress report push notifications
- **ENG-02**: App Store In-App Events for seasonal campaigns
- **ENG-03**: Achievement teasers for free users ("almost unlocked" progress bars)

### Advanced Growth

- **AGR-01**: Apple Search Ads integration for targeted acquisition
- **AGR-02**: A/B testing for paywall designs and pricing
- **AGR-03**: Landing page for universal link referrals

## Out of Scope

| Feature | Reason |
|---------|--------|
| AI habit coaching | API costs, complexity, market saturation with mediocre AI features |
| Banner/ad monetization | Hostile UX for daily-use app, ruins premium feel |
| Monthly subscription plan | Causes decision paralysis, 60%+ churn within 3 months |
| Hard paywall on core tracking | Kills funnel -- users must experience value before paying |
| External payment links | Complexity, server-side validation needed, not worth for indie |
| Complex referral backend | CloudKit-only constraint -- keep referrals simple |
| Android version | iOS-first, future milestone |
| Enterprise/white-label | Distraction from consumer product-market fit |
| 7-day free trial | Not selected for v1, can add post-launch |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| MON-01 | Phase 1 | Complete |
| MON-02 | Phase 1 | Complete |
| MON-03 | Phase 1 | Complete |
| MON-04 | Phase 1 | Complete |
| MON-05 | Phase 1 | Complete |
| MON-06 | Phase 1 | Complete |
| ASR-01 | Phase 3 | Complete |
| ASR-02 | Phase 3 | Complete |
| ASR-03 | Phase 3 | Complete |
| ASR-04 | Phase 3 | Complete |
| ASR-05 | Phase 3 | Complete |
| ASR-06 | Phase 3 | Complete |
| QAL-01 | Phase 4 | Pending |
| QAL-02 | Phase 4 | Pending |
| QAL-03 | Phase 4 | Pending |
| QAL-04 | Phase 4 | Pending |
| QAL-05 | Phase 4 | Pending |
| QAL-06 | Phase 4 | Pending |
| GRW-01 | Phase 2 | Complete |
| GRW-02 | Phase 2 | Complete |
| GRW-03 | Phase 2 | Complete |
| GRW-04 | Phase 2 | Complete |
| GRW-05 | Phase 2 | Complete |
| PLT-01 | Phase 1 | Complete |
| PLT-02 | Phase 1 | Complete |
| PLT-03 | Phase 1 | Complete |

**Coverage:**
- v1 requirements: 26 total
- Mapped to phases: 26
- Unmapped: 0

---
*Requirements defined: 2026-03-21*
*Last updated: 2026-03-21 after roadmap creation*
