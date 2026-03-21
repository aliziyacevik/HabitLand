# Phase 2: Referral System - Research

**Researched:** 2026-03-21
**Domain:** iOS referral system with CloudKit backend, SwiftUI/SwiftData
**Confidence:** HIGH

## Summary

This phase adds a referral code system where users generate a personal code, share it, and both parties earn 1 week of temporary Pro access. The implementation sits entirely within the existing Apple stack (SwiftUI, SwiftData, CloudKit public DB) with no new dependencies required.

The core technical challenge is extending `ProManager.isPro` to support a time-based referral Pro grant alongside the existing StoreKit purchase check, and adding a new `referralRedemption` record type to CloudKit for tracking. The existing `CloudKitManager` patterns (friend requests, nudges) provide a direct template for the referral record CRUD operations.

**Primary recommendation:** Extend `UserProfile` with referral fields, add `referralProExpiresAt` to `ProManager`, create CloudKit `referralRedemption` record type, and refactor `InviteFriendsView` to show the user's referral code with a ShareLink. Keep abuse prevention minimal per user decisions.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Referral code = 6 character alphanumeric, uppercase, derived from user's UUID. Prefix "HBT-" for brand recognition.
- **D-02:** Code generated automatically when user first opens the referral screen -- stored in `UserProfile.referralCode` (SwiftData) and synced to CloudKit public DB.
- **D-03:** Each user gets exactly one referral code, permanent and reusable.
- **D-04:** Two entry points: Onboarding (optional step after habit selection) and Settings (visible only if not already redeemed).
- **D-05:** One redemption per user ever. `UserProfile.referredByCode` tracks this.
- **D-06:** Reward = 1 week temporary Pro via `ProManager.referralProExpiresAt: Date?`.
- **D-07:** Multiple referrals stack: `referralProExpiresAt` extends by 7 days per successful referral.
- **D-08:** `ProManager.isPro` updated to check `referralProExpiresAt > Date.now`.
- **D-09:** No cap on referral rewards for v1.
- **D-10:** Basic abuse prevention only: one redemption per user, cannot redeem own code, CloudKit validates.
- **D-11:** No device fingerprinting or advanced fraud detection.
- **D-12:** Dedicated "Invite Friends" screen from Settings and Social tab with referral code, ShareLink, and stats.
- **D-13:** Challenge share links append `?ref=[CODE]` to App Store link.
- **D-14:** New CloudKit record type `referralRedemption` in public DB with `referrerCode`, `redeemerUserID`, `redeemedAt`.
- **D-15:** On redemption: create CloudKit record, grant Pro to both parties locally. CloudKit is source of truth.

### Claude's Discretion
- Exact UI layout of the Invite Friends screen
- Animation/feedback when code is successfully redeemed
- Error messages for invalid/expired/own codes
- How referral stats are displayed

### Deferred Ideas (OUT OF SCOPE)
- A/B testing referral reward amount -- post-launch
- Referral leaderboard ("Top Inviters") -- future phase
- Deep linking via Universal Links -- requires web domain
- Referral-specific push notifications ("Your friend just joined!") -- v2
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| GRW-01 | User can generate a referral code and share via share sheet | UUID-derived code generation algorithm, `ShareLink` SwiftUI component (already used in InviteFriendsView), `UserProfile.referralCode` field |
| GRW-02 | User who redeems a referral code gets 1 week Pro free | `ProManager.referralProExpiresAt` date field, `isPro` getter extension, redemption flow with CloudKit validation |
| GRW-03 | User who referred gets 1 week Pro free when friend redeems | CloudKit query to find referrer by code, extend referrer's `referralProExpiresAt` by 7 days, stacking logic |
| GRW-04 | Referral tracking via CloudKit public database | New `referralRedemption` record type in public DB, follows existing CloudKit patterns from friend requests |
| GRW-05 | Social challenge share links include app download link for non-users | Append `?ref=[CODE]` to App Store URL in challenge share messages |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | iOS 17+ | All UI (referral screens, onboarding step) | Already used throughout app |
| SwiftData | iOS 17+ | `UserProfile` model extension with referral fields | Already used for all models |
| CloudKit | iOS 17+ | `referralRedemption` record type in public DB | Already used for social features |
| StoreKit 2 | iOS 17+ | `ProManager` already manages Pro status | Extended with referral Pro check |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| ShareLink (SwiftUI) | iOS 16+ | Native share sheet for referral code | Sharing referral invites |
| UIPasteboard | iOS 2+ | Copy referral code to clipboard | Tap-to-copy on referral code display |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| CloudKit public DB | Firebase/Supabase | Would violate "no third-party deps" constraint |
| UUID-derived code | Random code generation | UUID-derived is deterministic and reproducible |

**Installation:** No new packages required. Pure Apple stack.

## Architecture Patterns

### Recommended Changes to Existing Structure
```
HabitLand/
├── Models/
│   └── Models.swift              # Add referralCode, referredByCode to UserProfile
├── Services/
│   ├── ProManager.swift          # Add referralProExpiresAt, update isPro
│   └── CloudKitManager.swift     # Add RecordType.referralRedemption, CRUD methods
├── Screens/
│   ├── Onboarding/
│   │   └── OnboardingView.swift  # Insert optional referral code step after StarterHabitsView
│   ├── Social/
│   │   └── InviteFriendsView.swift  # Refactor to show referral code + share + stats
│   └── Settings/
│       └── GeneralSettingsView.swift # Add "Enter Referral Code" row
└── Components/
    └── ReferralCodeEntryView.swift   # Reusable code entry component (onboarding + settings)
```

### Pattern 1: Referral Code Generation from UUID
**What:** Derive a 6-character alphanumeric code from the user's UUID, excluding ambiguous characters (I, l, O, 0).
**When to use:** On first access to referral screen, generated once and stored permanently.
**Example:**
```swift
// Deterministic code from UUID — always produces the same code for the same user
static func generateReferralCode(from uuid: UUID) -> String {
    let allowedChars = "ABCDEFGHJKMNPQRSTUVWXYZ23456789" // No I, L, O, 0, 1
    let hashBytes = Array(uuid.uuidString.utf8)
    var code = ""
    for i in 0..<6 {
        let index = Int(hashBytes[i]) % allowedChars.count
        code.append(allowedChars[allowedChars.index(allowedChars.startIndex, offsetBy: index)])
    }
    return code
}

// Displayed as "HBT-A3K9F2"
var displayCode: String { "HBT-\(referralCode)" }
```

### Pattern 2: ProManager Referral Pro Extension
**What:** Add `referralProExpiresAt` alongside existing StoreKit checks.
**When to use:** Every `isPro` check automatically includes referral Pro.
**Example:**
```swift
// In ProManager
@Published var referralProExpiresAt: Date?

var isPro: Bool {
    #if DEBUG
    if debugProEnabled { return true }
    if ProcessInfo.processInfo.arguments.contains("-screenshotMode") { return true }
    #endif
    if let expiresAt = referralProExpiresAt, expiresAt > Date.now {
        return true
    }
    return !purchasedProductIDs.isEmpty
}

// Stacking: extend by 7 days from current expiry or from now
func extendReferralPro(days: Int = 7) {
    let baseDate = referralProExpiresAt ?? Date.now
    let startDate = max(baseDate, Date.now) // Don't start from expired date
    referralProExpiresAt = Calendar.current.date(byAdding: .day, value: days, to: startDate)
    // Persist to UserDefaults for cross-launch survival
    UserDefaults.standard.set(referralProExpiresAt, forKey: "referralProExpiresAt")
}
```

### Pattern 3: CloudKit Referral Record (follows existing friend request pattern)
**What:** New record type in public DB for tracking redemptions.
**When to use:** On every referral code redemption.
**Example:**
```swift
// In CloudKitManager.RecordType
static let referralRedemption = "ReferralRedemption"

// Save referral redemption
func saveReferralRedemption(referrerCode: String, redeemerUserID: String) async -> Bool {
    let record = CKRecord(recordType: RecordType.referralRedemption)
    record["referrerCode"] = referrerCode as CKRecordValue
    record["redeemerUserID"] = redeemerUserID as CKRecordValue
    record["redeemedAt"] = Date() as CKRecordValue

    do {
        try await publicDB.save(record)
        return true
    } catch {
        print("Failed to save referral redemption: \(error)")
        return false
    }
}

// Check if user already redeemed any code
func hasUserRedeemedReferral(userID: String) async -> Bool {
    let predicate = NSPredicate(format: "redeemerUserID == %@", userID)
    let query = CKQuery(recordType: RecordType.referralRedemption, predicate: predicate)
    do {
        let (results, _) = try await publicDB.records(matching: query, resultsLimit: 1)
        return !results.isEmpty
    } catch {
        return false
    }
}
```

### Pattern 4: Referral Code Entry (reusable component)
**What:** A shared view for entering referral codes, used in both onboarding and settings.
**When to use:** Any screen that needs code entry.
**Example:**
```swift
struct ReferralCodeEntryView: View {
    @State private var codeText = ""
    @State private var isValidating = false
    @State private var errorMessage: String?
    @State private var isRedeemed = false
    var onRedeemed: (() -> Void)?

    var body: some View {
        VStack(spacing: HLSpacing.md) {
            TextField("HBT-XXXXXX", text: $codeText)
                .font(HLFont.title3(.bold))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .multilineTextAlignment(.center)

            if let error = errorMessage {
                Text(error)
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlError)
            }

            HLButton("Kodu Kullan", style: .primary, isFullWidth: true) {
                Task { await redeemCode() }
            }
            .disabled(codeText.count < 6 || isValidating)
        }
    }
}
```

### Anti-Patterns to Avoid
- **Storing referral Pro state only in SwiftData:** `referralProExpiresAt` must also be persisted in UserDefaults so ProManager can check it on launch before SwiftData queries resolve. ProManager is a singleton initialized before views load.
- **Generating referral codes on every access:** Code must be generated once, stored in `UserProfile.referralCode`, and reused forever. Regeneration would invalidate previously shared codes.
- **Checking CloudKit before every isPro call:** Only check CloudKit during redemption flow. The local `referralProExpiresAt` date is the runtime source of truth for Pro status.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Share sheet | Custom share dialog | `ShareLink` (SwiftUI built-in) | Native feel, handles all share targets automatically |
| Clipboard copy | Custom pasteboard logic | `UIPasteboard.general.string = code` | One-liner, standard iOS |
| Date arithmetic | Manual TimeInterval math | `Calendar.current.date(byAdding:)` | Handles DST, leap seconds, edge cases |
| Code validation format | Regex parser | Simple string length + character set check | Referral codes are fixed format (6 chars after prefix) |

**Key insight:** The entire referral system uses existing patterns from the social features (CloudKit records, SwiftData models, SwiftUI views). No new architectural concepts needed.

## Common Pitfalls

### Pitfall 1: Referral Pro Expiry Not Persisted Across App Launches
**What goes wrong:** User gets referral Pro, kills app, reopens, Pro is gone because `referralProExpiresAt` was only in memory.
**Why it happens:** `ProManager` is a class singleton, not a SwiftData model. Its state resets on app restart.
**How to avoid:** Persist `referralProExpiresAt` to `UserDefaults` (or `@AppStorage`). Load it in `ProManager.init()`.
**Warning signs:** Pro status flickers or disappears after app restart.

### Pitfall 2: Self-Referral Not Blocked
**What goes wrong:** User enters their own code and gets free Pro.
**Why it happens:** Only checking code format, not ownership.
**How to avoid:** Compare entered code against `UserProfile.referralCode` before CloudKit call. Also validate on CloudKit side that `redeemerUserID != referrerUserID`.
**Warning signs:** Same user appears as both referrer and redeemer in CloudKit records.

### Pitfall 3: Race Condition on Stacking Referral Pro
**What goes wrong:** Two friends redeem simultaneously, only one extension is applied.
**Why it happens:** Both reads of `referralProExpiresAt` see the same value before either write.
**How to avoid:** This is a local-only operation on `@MainActor`, so no real race condition in practice. CloudKit records are the audit trail; local date is best-effort.
**Warning signs:** User reports missing referral weeks.

### Pitfall 4: CloudKit Unavailable During Redemption
**What goes wrong:** User enters valid code but CloudKit is down, redemption fails silently.
**Why it happens:** CloudKit has occasional outages; user may not have iCloud signed in.
**How to avoid:** Check `CloudKitManager.iCloudAvailable` before attempting redemption. Show clear error: "iCloud bağlantısı gerekli" (iCloud connection required). Do NOT grant Pro locally without CloudKit confirmation.
**Warning signs:** Users report codes not working intermittently.

### Pitfall 5: Referral Code Collision
**What goes wrong:** Two different UUIDs produce the same 6-character code.
**Why it happens:** 6 chars from a limited alphabet = ~729 million combinations, collision possible with large user base.
**How to avoid:** For v1 with expected user count, collision risk is negligible. Before saving to CloudKit, query for existing code. If collision, append a digit or regenerate with a salt.
**Warning signs:** CloudKit save fails with duplicate record error.

### Pitfall 6: Onboarding Flow Disruption
**What goes wrong:** Adding referral step breaks the existing onboarding carousel/flow.
**Why it happens:** OnboardingView uses `TabView` with `currentPage` index. Inserting a step between habit selection and completion changes the flow.
**How to avoid:** The referral code entry should be shown AFTER `StarterHabitsView` completes (in the `.onDisappear` flow or as a separate sheet), not as an additional TabView page. This keeps the existing onboarding intact.
**Warning signs:** Page indicators are off, skip button behavior changes.

## Code Examples

### UserProfile Model Extension
```swift
// Add to UserProfile in Models.swift
var referralCode: String?      // "A3K9F2" (without HBT- prefix)
var referredByCode: String?    // Code this user redeemed (nil = never redeemed)
var referralCount: Int = 0     // Number of friends who redeemed this user's code
```

### ProManager currentPlanDisplay Update
```swift
var currentPlanDisplay: (name: String, icon: String) {
    if purchasedProductIDs.contains(Self.lifetimeID) {
        return ("Pro (Lifetime)", "crown.fill")
    } else if purchasedProductIDs.contains(Self.yearlyID) {
        return ("Pro (Yearly)", "crown.fill")
    } else if let expiresAt = referralProExpiresAt, expiresAt > Date.now {
        let days = Calendar.current.dateComponents([.day], from: Date.now, to: expiresAt).day ?? 0
        return ("Pro (Referral - \(days)d left)", "gift.fill")
    }
    return ("Free Plan", "person.fill")
}
```

### Ambiguous Character Exclusion for Codes
```swift
// Characters excluded from referral codes per user request:
// I (looks like l/1), L (looks like I/1), O (looks like 0), 0 (looks like O), 1 (looks like I/l)
let allowedCharacters = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
```

### Localized Share Message
```swift
// Turkish (primary market)
let shareMessageTR = "Alışkanlıklarını birlikte takip edelim! HabitLand'i indir ve kodumu gir: \(displayCode) — ikimiz de 1 hafta Pro kazanalım! \(appStoreURL)"

// English fallback
let shareMessageEN = "Let's track habits together! Download HabitLand and enter my code: \(displayCode) — we both get 1 week of Pro! \(appStoreURL)"

// Use device locale to pick
let shareMessage = Locale.current.language.languageCode == .turkish ? shareMessageTR : shareMessageEN
```

### Challenge Share Link with Referral
```swift
// When sharing a challenge, append ref code
let baseURL = "https://apps.apple.com/app/habitland/id000000000"
let shareURL = "\(baseURL)?ref=\(profile.referralCode ?? "")"
```

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Swift Testing (Xcode 16+, `import Testing`) |
| Config file | None -- uses Xcode scheme |
| Quick run command | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing HabitLandTests -quiet` |
| Full suite command | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16' -quiet` |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| GRW-01 | Referral code generation from UUID produces valid 6-char code | unit | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing HabitLandTests -quiet` | No -- Wave 0 |
| GRW-01 | Code excludes ambiguous characters (I, L, O, 0, 1) | unit | same | No -- Wave 0 |
| GRW-02 | Redeeming code sets referralProExpiresAt to 7 days from now | unit | same | No -- Wave 0 |
| GRW-02 | isPro returns true when referralProExpiresAt is in the future | unit | same | No -- Wave 0 |
| GRW-02 | isPro returns false when referralProExpiresAt is in the past | unit | same | No -- Wave 0 |
| GRW-03 | Referral Pro stacks: existing 7 days + new 7 days = 14 days | unit | same | No -- Wave 0 |
| GRW-04 | CloudKit referral record CRUD | manual-only | N/A -- requires live CloudKit | N/A |
| GRW-05 | Challenge share URL includes ?ref= parameter | unit | same | No -- Wave 0 |

### Sampling Rate
- **Per task commit:** `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing HabitLandTests -quiet`
- **Per wave merge:** `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16' -quiet`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] Add referral code generation tests to `HabitLandTests/HabitLandTests.swift` (or new file `ReferralTests.swift`)
- [ ] Add ProManager referral Pro logic tests (isPro with referralProExpiresAt, stacking)
- [ ] Add code validation tests (self-referral block, ambiguous char exclusion)

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Server-side referral tracking | CloudKit public DB (serverless) | N/A (project constraint) | No custom backend needed |
| Deep links for referrals | Simple code entry (no Universal Links) | Deferred to v2 | Simpler implementation, manual code entry |

**Deprecated/outdated:**
- Universal Links for referral codes: Deferred -- requires Apple Developer account + web domain setup. Manual code entry is v1 approach.

## Open Questions

1. **App Store URL placeholder**
   - What we know: Current code uses `https://apps.apple.com/app/habitland/id000000000` (placeholder)
   - What's unclear: Real App Store ID not available until app is submitted
   - Recommendation: Keep placeholder, update after first App Store submission. Define as a constant (`AppConstants.appStoreURL`) for easy update.

2. **Referral Pro persistence strategy**
   - What we know: ProManager uses `@Published` properties and StoreKit Transaction API
   - What's unclear: Whether to use UserDefaults or a UserProfile SwiftData field for `referralProExpiresAt`
   - Recommendation: Use both -- UserDefaults for ProManager fast access on init, SwiftData UserProfile for data model consistency. UserDefaults is primary for `isPro` checks.

3. **CloudKit record type registration**
   - What we know: Existing record types (SocialProfile, FriendRequest, etc.) work in public DB
   - What's unclear: Whether new record type `ReferralRedemption` needs CloudKit Dashboard setup first
   - Recommendation: CloudKit auto-creates record types on first save in development environment. In production, the schema must be deployed via CloudKit Dashboard. Since Developer account is pending, this works for now.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: `ProManager.swift`, `CloudKitManager.swift`, `Models.swift`, `InviteFriendsView.swift`, `OnboardingView.swift`, `GeneralSettingsView.swift`
- CONTEXT.md decisions (D-01 through D-15)
- Existing CloudKit patterns (friend requests, nudges) as direct template

### Secondary (MEDIUM confidence)
- Apple CloudKit documentation for public database record types
- SwiftUI ShareLink API (already used in codebase)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- pure Apple stack already in use, no new dependencies
- Architecture: HIGH -- follows existing CloudKit + SwiftData patterns exactly
- Pitfalls: HIGH -- derived from direct code analysis of ProManager lifecycle and CloudKit patterns
- Code examples: HIGH -- modeled directly on existing codebase patterns

**Research date:** 2026-03-21
**Valid until:** 2026-04-21 (stable -- Apple frameworks, no fast-moving dependencies)
