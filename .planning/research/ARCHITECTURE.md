# Architecture Patterns

**Domain:** iOS habit tracker -- monetization, paywall, referral, and App Store launch
**Researched:** 2026-03-21

## Current Architecture Baseline

The existing app follows a layered MV pattern: SwiftUI views bind directly to SwiftData models via `@Query`, with singleton service managers (`ProManager`, `CloudKitManager`, `AchievementManager`, etc.) providing business logic through `@ObservedObject`. This is well-established and the new components should integrate into this pattern rather than introducing a new architecture.

**Key existing pieces already in place:**
- `ProManager` -- fully functional StoreKit 2 integration with yearly subscription + lifetime purchase, transaction listener, promo code redemption, restore, and free trial eligibility
- `PaywallView` -- complete paywall UI with plan selection, trial banner, legal section
- `PremiumGateView` + `.premiumGated()` modifier -- feature gating infrastructure
- `CloudKitManager` -- social backend with user profiles, friend requests, challenges
- `InviteFriendsView` -- username search and share link for friend invitations

## Recommended Architecture for New Components

### Component Map

```
+-------------------+     +--------------------+     +-------------------+
|   PaywallView     |     | ReferralView       |     | ASOMetadataFiles  |
|   (existing,      |     | (new)              |     | (new, static)     |
|    polish only)   |     |                    |     |                   |
+--------+----------+     +--------+-----------+     +-------------------+
         |                         |
         v                         v
+--------+----------+     +--------+-----------+
|   ProManager      |     | ReferralManager    |
|   (existing,      |     | (new service)      |
|    minor updates) |     |                    |
+--------+----------+     +--------+-----------+
         |                         |
         v                         v
+--------+----------+     +--------+-----------+
|   StoreKit 2      |     |   CloudKit         |
|   (system)        |     |   Public DB        |
|                   |     |   (new record type) |
+-------------------+     +--------------------+
```

### Component Boundaries

| Component | Responsibility | Communicates With | Status |
|-----------|---------------|-------------------|--------|
| `ProManager` | StoreKit 2 IAP, entitlement tracking, free/pro gating | StoreKit 2, PaywallView, PremiumGateView | Existing -- needs minor updates only |
| `PaywallView` | Purchase UI, plan selection, trial display | ProManager | Existing -- polish for conversion optimization |
| `PremiumGateView` | Feature gating overlay with upgrade CTA | ProManager, PaywallView | Existing -- no changes needed |
| `ReferralManager` | Referral link generation, tracking, reward fulfillment | CloudKit, ProManager, UserDefaults | New service |
| `ReferralView` | Referral dashboard UI, share sheet, progress display | ReferralManager | New screen |
| `ASOMetadata` | App Store listing text, keywords, screenshot specs | None (static assets) | New static files |
| `ReviewManager` | App Store review prompts | StoreKit (existing) | Existing -- possibly tune thresholds |

### Detailed Component Specifications

#### 1. ProManager Updates (Existing -- Minor Changes)

The current `ProManager` is production-ready. Changes needed:

- **Add referral reward method:** `func grantReferralReward()` that extends subscription or unlocks a time-limited Pro trial via UserDefaults-tracked expiry (since StoreKit 2 does not support server-side entitlement grants without a backend)
- **Add subscription status helper:** `var subscriptionExpiryDate: Date?` for displaying status in settings
- **No structural changes** -- the singleton pattern, transaction listener, and verification flow are correct

**Referral reward approach (no backend constraint):**
Since there is no custom server, referral rewards cannot grant actual StoreKit subscriptions. Use a "soft Pro" approach: store a `referralProExpiryDate` in `@AppStorage` that the `isPro` computed property checks alongside StoreKit entitlements. This gives referred users a time-limited free trial (e.g., 7 days) without requiring server-side receipt manipulation.

```swift
// Addition to ProManager
@AppStorage("referralProExpiry") private var referralProExpiryRaw: Double = 0

var referralProExpiry: Date? {
    referralProExpiryRaw > 0 ? Date(timeIntervalSince1970: referralProExpiryRaw) : nil
}

var isPro: Bool {
    // existing checks...
    || (referralProExpiry.map { $0 > Date() } ?? false)
}

func grantReferralReward(days: Int = 7) {
    let expiry = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    referralProExpiryRaw = expiry.timeIntervalSince1970
}
```

#### 2. ReferralManager (New Service)

**Purpose:** Generate unique referral codes, track invitations, and reward users when referrals convert.

**Architecture decision:** Use CloudKit public database for referral tracking. This fits the existing pattern (social features already use CloudKit public DB) and requires no custom backend.

```
ReferralManager
├── Properties
│   ├── @Published referralCode: String        // User's unique code
│   ├── @Published referralCount: Int          // Successful referrals
│   ├── @Published pendingReferrals: Int       // Invited but not converted
│   └── @Published rewardsClaimed: Int         // Rewards already claimed
├── Methods
│   ├── generateReferralCode() async           // Create/fetch user's code
│   ├── shareReferralLink() -> URL             // Build share URL
│   ├── trackReferral(code:) async             // Record that someone used a code
│   ├── checkAndClaimRewards() async           // Check if new rewards available
│   └── fetchReferralStats() async             // Load dashboard data
└── CloudKit Records
    └── "Referral" record type
        ├── referrerID: CKRecord.Reference     // Who shared
        ├── referredID: CKRecord.Reference     // Who signed up
        ├── code: String                       // Referral code
        ├── status: String                     // "pending" | "converted"
        └── createdAt: Date                    // When shared
```

**Referral flow:**
1. User taps "Invite Friends" in ReferralView
2. ReferralManager generates a unique code (based on CloudKit user record ID hash)
3. Share sheet opens with a universal link or plain text containing the code
4. New user installs app, enters code during onboarding (or on a referral screen)
5. ReferralManager.trackReferral() creates a CloudKit record
6. Referrer's app polls on launch or periodically via checkAndClaimRewards()
7. Both users get "soft Pro" trial days via ProManager.grantReferralReward()

**Why not deep links / universal links:** These require a registered domain with an apple-app-site-association file hosted on a web server. Since the constraint is CloudKit-only (no custom backend), use simple referral codes entered manually. If a web presence is later added, universal links can be layered on.

#### 3. ReferralView (New Screen)

**Location:** `HabitLand/Screens/Social/ReferralView.swift`

**Sections:**
- Referral code display with copy button
- Share button (UIActivityViewController)
- Stats: invited count, converted count, rewards earned
- Reward tiers visualization (e.g., "Invite 3 friends = 1 month Pro")
- List of referred friends with status

**Navigation:** Accessible from Settings and from Social Hub.

#### 4. Paywall Polish (Existing -- UI Refinement Only)

The existing PaywallView is complete. Refinements for conversion optimization:

- **Social proof:** Add "Join 1,000+ users" or review count (can be static initially)
- **Urgency element:** Limited-time pricing badge (optional, can be A/B tested)
- **Before/after comparison:** Show free vs Pro feature comparison more prominently
- **Contextual paywall triggers:** When user hits free habit limit (already works via PremiumGateModifier), add contextual messaging about what they are missing

No architectural changes needed -- these are purely view-layer updates.

#### 5. ASO Metadata (New Static Assets)

**Not code architecture** -- these are files and configurations:

| Asset | Format | Location |
|-------|--------|----------|
| App title | 30 chars max | App Store Connect |
| Subtitle | 30 chars max | App Store Connect |
| Keywords | 100 chars, comma-separated | App Store Connect |
| Description | 4000 chars max | App Store Connect |
| Promotional text | 170 chars | App Store Connect |
| Screenshots | 6.7" (1290x2796), 6.5" (1284x2778), 5.5" (1242x2208) | App Store Connect |
| App Preview video | Optional, 15-30 sec | App Store Connect |

**Store in repo:** Create `.planning/aso/` directory with `keywords.md`, `description.md`, `screenshot-specs.md` for version control of ASO text. These are not compiled into the app.

## Data Flow

### Purchase Flow (Existing, No Changes)

```
User taps plan → PaywallView.handlePurchase()
  → ProManager.purchase(product)
    → StoreKit 2 Product.purchase()
      → Apple payment sheet
        → Transaction.updates listener fires
          → ProManager.updatePurchasedProducts()
            → @Published purchasedProductIDs updates
              → All views observing ProManager.isPro re-render
```

### Referral Flow (New)

```
REFERRER SIDE:
ReferralView → ReferralManager.shareReferralLink()
  → UIActivityViewController (share code via Messages, WhatsApp, etc.)

REFERRED USER SIDE:
Onboarding or Settings → Enter referral code
  → ReferralManager.trackReferral(code:)
    → CloudKit: Create "Referral" record (status: "converted")
    → ProManager.grantReferralReward(days: 7)  // referred user gets trial

REFERRER REWARD:
App launch → ReferralManager.checkAndClaimRewards()
  → CloudKit: Query "Referral" records where referrerID == me AND status == "converted"
    → If new conversions found:
      → ProManager.grantReferralReward(days: 7)  // referrer gets trial extension
      → Update @Published referralCount
```

### Feature Gating Flow (Existing, No Changes)

```
Any view with .premiumGated(feature:icon:)
  → PremiumGateModifier checks ProManager.isPro
    → true: Show content
    → false: Show PremiumGateView with "Upgrade to Pro" CTA
      → User taps → PaywallView sheet
```

### Pro Status Resolution (Updated)

```
ProManager.isPro checks (in order):
  1. DEBUG mode + debugProEnabled → true
  2. -screenshotMode argument → true
  3. purchasedProductIDs not empty (StoreKit entitlement) → true
  4. referralProExpiry > Date.now (referral reward active) → true  // NEW
  5. Otherwise → false
```

## Patterns to Follow

### Pattern 1: Singleton Service Manager
**What:** All service managers are `@MainActor final class` singletons with `@Published` properties.
**When:** For any new cross-cutting service (ReferralManager follows this).
**Why:** Consistent with ProManager, CloudKitManager, AchievementManager pattern. Views observe via `@StateObject` or `@ObservedObject`.

### Pattern 2: PremiumGateModifier for Feature Gating
**What:** Use `.premiumGated(feature:icon:)` view modifier to gate Pro-only content.
**When:** Any view or section that should be locked for free users.
**Why:** Already established pattern. Keeps gating logic out of individual views.

### Pattern 3: CloudKit Public Database for Shared Data
**What:** Use CloudKit public DB for data that needs to be shared between users (referrals, social).
**When:** Referral tracking, friend connections, challenges.
**Why:** No custom backend. CloudKit public DB is free (within generous limits) and already used for social features.

### Pattern 4: Graceful Degradation
**What:** Every external dependency (CloudKit, StoreKit, HealthKit) has a fallback path.
**When:** Always. Network failures, permission denials, account issues.
**Why:** Existing pattern throughout the codebase. Referral system should work offline (cache code locally, sync when online).

## Anti-Patterns to Avoid

### Anti-Pattern 1: Server-Side Receipt Validation
**What:** Sending App Store receipts to a custom server for validation.
**Why bad:** No custom backend exists. Adds complexity, cost, and a single point of failure.
**Instead:** Use StoreKit 2's on-device Transaction.currentEntitlements which handles verification locally with JWS signatures. This is already implemented correctly in ProManager.

### Anti-Pattern 2: Deep Link Referrals Without a Domain
**What:** Trying to implement universal links for referral without a registered web domain.
**Why bad:** Requires hosting an apple-app-site-association file on a HTTPS domain. No web presence exists.
**Instead:** Use simple referral codes. Can upgrade to universal links later if a landing page is added.

### Anti-Pattern 3: Storing Purchase State in SwiftData
**What:** Persisting purchase/entitlement status in the local SwiftData database.
**Why bad:** StoreKit 2 is the source of truth for purchases. Duplicating state creates sync issues, especially with family sharing and subscription management.
**Instead:** Always query `Transaction.currentEntitlements` (already implemented). Only store referral reward expiry in UserDefaults since that is app-managed state, not Apple-managed.

### Anti-Pattern 4: Over-Engineering the Paywall
**What:** Building a custom subscription management UI, cancellation flow, or billing dashboard.
**Why bad:** Apple handles all subscription management in Settings > Subscriptions. Duplicating this violates App Store guidelines and wastes effort.
**Instead:** Link to `manageSubscriptions` URL for subscription management. Focus paywall on conversion, not administration.

## Suggested Build Order

Build order is driven by dependencies between components:

```
Phase 1: StoreKit 2 Finalization
  └── ProManager updates (referral reward method, subscription status)
  └── PaywallView polish (conversion optimization)
  └── StoreKit Configuration verification with App Store Connect
  └── Dependency: Apple Developer account must be approved

Phase 2: Referral System
  └── ReferralManager service (CloudKit records, code generation)
  └── ReferralView screen (dashboard, share, stats)
  └── Onboarding referral code entry point
  └── Dependency: Phase 1 (needs ProManager.grantReferralReward)
  └── Dependency: CloudKit must be enabled (Apple Developer account)

Phase 3: ASO & App Store Preparation
  └── Keyword research and metadata
  └── Screenshot generation (existing -screenshotMode helps)
  └── App description and promotional text
  └── Dependency: Phase 1 (paywall must be finalized for screenshots)
  └── Can partially run in parallel with Phase 2

Phase 4: Final Polish & Submission
  └── Performance audit
  └── Edge case testing
  └── App Store submission
  └── Dependency: All above phases
```

**Critical dependency:** Apple Developer account approval gates Phase 1 (real StoreKit testing in sandbox) and Phase 2 (CloudKit for referrals). ASO metadata work (Phase 3) can begin in parallel since it is mostly text/asset work.

## Scalability Considerations

| Concern | At Launch | At 10K Users | At 100K Users |
|---------|-----------|--------------|---------------|
| StoreKit 2 | On-device, no scaling concern | Same | Same -- Apple handles |
| Referral CloudKit records | Minimal reads | Public DB has 250MB asset storage, 100 requests/sec | May need to index referral code field, add rate limiting |
| Feature gating checks | In-memory, instant | Same | Same -- local check |
| Paywall display | Standard view | Same | Consider A/B testing via Remote Config |

CloudKit public database is generous for this use case. At 100K users, the main concern would be query performance on the Referral record type -- ensure the `code` field is indexed for lookups.

## Sources

- Existing codebase analysis (ProManager.swift, PaywallView.swift, PremiumGateView.swift, CloudKitManager.swift, Configuration.storekit)
- StoreKit 2 documentation (Apple Developer -- on-device entitlement verification, Transaction API)
- CloudKit documentation (Apple Developer -- public database limits, record types)
- App Store Review Guidelines Section 3.1 (In-App Purchase requirements)

---

*Architecture analysis: 2026-03-21*
