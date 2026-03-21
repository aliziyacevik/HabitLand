# Phase 2: Referral System - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can invite friends via a personal referral code. Both referrer and referred friend earn 1 week of free Pro access. Challenge share links include app download link for non-users. CloudKit public database tracks referral redemptions.

</domain>

<decisions>
## Implementation Decisions

### Referral Code Format & Generation
- **D-01:** Referral code = 6 character alphanumeric, uppercase, derived from user's UUID (e.g., "HBT-A3K9F2"). Prefix "HBT-" for brand recognition.
- **D-02:** Code generated automatically when user first opens the referral screen — stored in `UserProfile.referralCode` (SwiftData) and synced to CloudKit public DB.
- **D-03:** Each user gets exactly one referral code, permanent and reusable.

### Code Entry Points
- **D-04:** Two places to enter a referral code:
  1. **Onboarding** — optional step after habit selection: "Got an invite? Enter code" with skip option
  2. **Settings** — "Enter Referral Code" row, visible only if user hasn't already redeemed one
- **D-05:** A user can only redeem ONE referral code ever (prevent self-referral loops). `UserProfile.referredByCode` tracks this — nil means never redeemed.

### Reward Mechanics
- **D-06:** Reward = 1 week temporary Pro access for both parties. Implemented via `ProManager.referralProExpiresAt: Date?` — not a real StoreKit purchase.
- **D-07:** Multiple referrals stack: if user refers 3 friends, they get 3 weeks Pro. `referralProExpiresAt` extends by 7 days per successful referral.
- **D-08:** `ProManager.isPro` getter updated to check: `purchasedProductIDs.isEmpty == false || referralProExpiresAt > Date.now`
- **D-09:** No cap on referral rewards for v1 — monitor post-launch. If abuse detected, add cap later.

### Abuse Prevention
- **D-10:** Basic abuse prevention only:
  - One redemption per user (D-05)
  - Cannot redeem own code (check `referralCode != enteredCode`)
  - CloudKit validates referral record doesn't already exist for this user
- **D-11:** No device fingerprinting or advanced fraud detection for v1 — keep it simple.

### Sharing UX
- **D-12:** Dedicated "Invite Friends" screen accessible from Settings and Social tab. Shows:
  - User's referral code (large, tappable to copy)
  - ShareLink button with pre-filled message: "Alışkanlıklarını birlikte takip edelim! HabitLand'i indir ve kodumu gir: [CODE] — ikimiz de 1 hafta Pro kazanalım! [App Store link]"
  - Referral stats: "X arkadaş davet edildi, Y hafta Pro kazanıldı"
- **D-13:** Challenge share links: when sharing a challenge, append `?ref=[CODE]` to the App Store link so non-users who download get the referral benefit.

### CloudKit Integration
- **D-14:** New CloudKit record type `referralRedemption` in public database:
  - `referrerCode: String` — the code that was shared
  - `redeemerUserID: String` — who redeemed it
  - `redeemedAt: Date`
- **D-15:** On redemption: create CloudKit record, then grant Pro to both parties locally. CloudKit is the source of truth for "did this user already redeem?"

### Claude's Discretion
- Exact UI layout of the Invite Friends screen
- Animation/feedback when code is successfully redeemed
- Error messages for invalid/expired/own codes
- How referral stats are displayed

</decisions>

<specifics>
## Specific Ideas

- Share mesajı Türkçe olsun (birincil pazar Türkiye) ama İngilizce fallback olsun
- Kod girişi sonrası başarılı redemption'da confetti veya celebration animasyonu
- Referral kodu kolay okunabilir olsun — I/l/O/0 gibi karışabilecek karakterler hariç tutulsun

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Social Infrastructure
- `HabitLand/Services/CloudKitManager.swift` — Friend requests, nudges, user profile sync, public DB patterns
- `HabitLand/Models/Models.swift` — UserProfile model (add referral fields here)

### Pro Access
- `HabitLand/Services/ProManager.swift` — isPro logic, trial eligibility, PaywallContext enum

### Sharing
- `HabitLand/Screens/Social/InviteFriendsView.swift` — Existing invite UI with ShareLink (adapt for referral)
- `HabitLand/Screens/Social/CreateChallengeView.swift` — Challenge sharing pattern

### Onboarding
- `HabitLand/Screens/Onboarding/OnboardingView.swift` — Tab-based carousel, insert referral code step

### Settings
- `HabitLand/Screens/Settings/GeneralSettingsView.swift` — Add "Enter Referral Code" row

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `CloudKitManager` — public DB CRUD, friend request pattern reusable for referral records
- `ShareLink` component — already used in InviteFriendsView, swap content for referral message
- `ProManager.isPro` — extend with `referralProExpiresAt` date check
- Nudge system — can notify referrer when friend redeems their code

### Established Patterns
- CloudKit record types defined in `CloudKitManager.RecordType` enum — add `.referralRedemption`
- `UserProfile` is SwiftData `@Model` — add referral fields directly
- Social features use `@Environment(CloudKitManager.self)` for access

### Integration Points
- `ProManager.isPro` — add referral Pro check alongside StoreKit check
- `OnboardingView` — insert optional referral code page
- `GeneralSettingsView` — add referral code entry row
- `InviteFriendsView` — refactor to show personal referral code + share
- `CloudKitManager` — add referral record CRUD methods

</code_context>

<deferred>
## Deferred Ideas

- A/B testing referral reward amount (1 week vs 1 month) — post-launch
- Referral leaderboard ("Top Inviters") — future phase
- Deep linking via Universal Links — requires web domain, deferred
- Referral-specific push notifications ("Your friend just joined!") — v2

</deferred>

---

*Phase: 02-referral-system*
*Context gathered: 2026-03-21*
