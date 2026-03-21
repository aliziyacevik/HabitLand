# Phase 1: Monetization & Platform Activation - Research

**Researched:** 2026-03-21
**Domain:** StoreKit 2 IAP, CloudKit sync, HealthKit, Push Notifications, iOS Capabilities
**Confidence:** HIGH

## Summary

This phase converts an existing, well-structured IAP and platform infrastructure from "disabled/stub" mode to production-ready. The codebase already has ProManager (StoreKit 2), PaywallView, PremiumGateModifier, HealthKitManager, NotificationManager, CloudKitManager, and SharedModelContainer -- all functional but with platform capabilities disabled pending Apple Developer account approval.

The work divides into two clear tracks: (1) **Monetization** -- connecting existing StoreKit 2 infrastructure to real App Store Connect products, adding contextual paywall triggers with blurred previews, and adding subscription management in Settings; (2) **Platform Activation** -- removing `#if false` / `.none` guards on CloudKit sync, re-enabling HealthKit authorization, and ensuring push notification registration works. A security hardening pass guards the `-screenshotMode` Pro bypass behind `#if DEBUG` and replaces the single `fatalError()` in SharedModelContainer.

**Primary recommendation:** Work in three waves -- (1) security hardening + screenshotMode guard, (2) contextual paywall improvements + subscription management UI, (3) platform activation (CloudKit, HealthKit, Push). Each wave is independently testable.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- D-01: Soft paywall approach -- free users see value before hitting gate. Never block core habit tracking (up to 3 habits stays free).
- D-02: Contextual triggers at 4 points: 4th habit creation (improved UX with dedicated sheet), Sleep tab (blurred preview), Social tab (blurred preview), Achievement unlock attempt (paywall with achievements message).
- D-03: No time-based or success-based upsells for v1.
- D-04: PaywallView contextual header: show triggering feature's icon and description at top of paywall.
- D-05: Add "Manage Subscription" row in Settings deep-linking to `itms-apps://apps.apple.com/account/subscriptions`.
- D-06: Show current plan status in Settings: "Pro (Yearly)", "Pro (Lifetime)", or "Free Plan" with icon.
- D-07: No in-app upgrade flow (yearly to lifetime) for v1.
- D-08: iCloud sync: re-enable CloudKit sync in SharedModelContainer by removing the `.none` guard. Show sync status indicator in Settings.
- D-09: HealthKit: re-enable authorization request. Show "Connected to Apple Health" badge in Settings.
- D-10: Push: enable APNs registration in AppDelegate for future server-triggered notifications, keep local notifications as primary.
- D-11: Update team ID placeholder ("XXXXXXXXXX") to real team ID, enable iCloud and HealthKit capabilities in entitlements.
- D-12: Guard `-screenshotMode` Pro bypass with `#if DEBUG`.
- D-13: Replace `fatalError()` paths in ProManager/SharedModelContainer with graceful fallbacks.

### Claude's Discretion
- Exact blurred preview implementation for gated tabs
- Sync status indicator design in Settings
- HealthKit authorization prompt timing and messaging
- Error handling for failed purchases beyond current alert

### Deferred Ideas (OUT OF SCOPE)
- Time-based upsells (e.g., after 7 days of use)
- Success-based upsells (e.g., after 10 habit completions)
- Rich notifications with custom UI
- Yearly to Lifetime upgrade flow
- Remote push notifications from server (local notifications sufficient for v1)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| MON-01 | User can purchase yearly Pro subscription ($19.99/yr) via StoreKit 2 | ProManager already has purchase flow, product IDs match StoreKit config. Needs real App Store Connect products when account approved. |
| MON-02 | User can purchase lifetime Pro unlock ($39.99) via StoreKit 2 | Same as MON-01 -- NonConsumable product configured in Configuration.storekit. |
| MON-03 | User sees contextual paywall when hitting free tier limits | Current implementation shows plain PaywallView. Needs contextual header (D-04), blurred previews (D-02), achievement gate trigger. |
| MON-04 | User can manage/cancel subscription from Settings via deep link | GeneralSettingsView needs new "Manage Subscription" row with `itms-apps://` deep link and plan status display. |
| MON-05 | User's purchase persists across app reinstall via receipt verification | Already implemented via `Transaction.currentEntitlements` in `updatePurchasedProducts()`. Restore button exists. |
| MON-06 | Pricing strategy finalized as $19.99/yr + $39.99 lifetime | Already configured in Configuration.storekit. No code changes needed. |
| PLT-01 | iCloud sync enabled after Apple Developer account approval | SharedModelContainer has CloudKit code commented out. Change `.none` to `.private("iCloud.azc.HabitLand")`. Add entitlements. |
| PLT-02 | HealthKit permissions activated for real health data access | HealthKitManager fully implemented. Need to add HealthKit entitlement to HabitLand.entitlements. |
| PLT-03 | Push notifications enabled for streak reminders and weekly reports | NotificationManager works with local notifications. Add APNs registration in AppDelegate for future use. |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| StoreKit 2 | iOS 17+ | In-app purchases, subscriptions | Native Apple framework, already integrated |
| SwiftData + CloudKit | iOS 17+ | Data persistence with iCloud sync | Already in use, just needs CloudKit enabled |
| HealthKit | iOS 17+ | Health data integration | Already integrated via HealthKitManager |
| UserNotifications | iOS 17+ | Local + push notifications | Already integrated via NotificationManager |
| CloudKit | iOS 17+ | Social features backend | Already integrated via CloudKitManager |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| StoreKit Testing | Xcode built-in | Local IAP testing | Configuration.storekit already set up for sandbox testing |

### Alternatives Considered
None -- this is a pure Apple stack project with no third-party dependencies. All required frameworks are already integrated.

## Architecture Patterns

### Current Project Structure (relevant files)
```
HabitLand/
├── Services/
│   ├── ProManager.swift           # StoreKit 2 purchases, Pro state
│   ├── SharedModelContainer.swift # SwiftData + CloudKit container
│   ├── HealthKitManager.swift     # Health data sync
│   ├── NotificationManager.swift  # Local notifications
│   └── CloudKitManager.swift      # Social CloudKit features
├── Screens/
│   ├── Premium/
│   │   ├── PaywallView.swift      # Paywall UI
│   │   └── PremiumGateView.swift  # Gate modifier + overlay
│   ├── Settings/
│   │   └── GeneralSettingsView.swift # Settings hub
│   └── Home/
│       └── HomeDashboardView.swift   # Habit limit check
├── HabitLandApp.swift             # App lifecycle
├── ContentView.swift              # Tab bar with premium gating
└── HabitLand.entitlements         # Only App Groups currently
```

### Pattern 1: Contextual Paywall with Feature Context
**What:** PaywallView accepts an optional `context` parameter that customizes the header to show which feature triggered it.
**When to use:** Every paywall trigger point (D-02 defines 4 trigger points).
**Example:**
```swift
enum PaywallContext {
    case habitLimit
    case sleepTracking
    case socialFeatures
    case achievements

    var title: String { /* feature-specific title */ }
    var icon: String { /* feature-specific icon */ }
    var description: String { /* feature-specific description */ }
}

struct PaywallView: View {
    var context: PaywallContext? = nil
    // When context is provided, show contextual header instead of generic crown icon
}
```

### Pattern 2: Blurred Preview Gate
**What:** Instead of showing a lock icon overlay, show the actual content behind a blur + CTA overlay.
**When to use:** Sleep and Social tab gates (D-02 items 2 and 3).
**Example:**
```swift
// Instead of replacing content entirely with PremiumGateView,
// overlay a blur + upgrade CTA on top of the actual view
struct BlurredPremiumGate: ViewModifier {
    @ObservedObject private var proManager = ProManager.shared
    let feature: String
    let icon: String

    func body(content: Content) -> some View {
        if proManager.isPro {
            content
        } else {
            content
                .blur(radius: 8)
                .allowsHitTesting(false)
                .overlay {
                    // Upgrade CTA overlay
                }
        }
    }
}
```

### Pattern 3: Subscription Status Display
**What:** ProManager exposes a computed `currentPlanName` property for UI display.
**When to use:** Settings plan status row (D-06).
**Example:**
```swift
extension ProManager {
    var currentPlanDisplay: (name: String, icon: String) {
        if purchasedProductIDs.contains(Self.lifetimeID) {
            return ("Pro (Lifetime)", "crown.fill")
        } else if purchasedProductIDs.contains(Self.yearlyID) {
            return ("Pro (Yearly)", "crown.fill")
        }
        return ("Free Plan", "person.fill")
    }
}
```

### Anti-Patterns to Avoid
- **Direct URL construction for subscription management:** Always use the `itms-apps://` scheme, never construct App Store URLs manually. Use `URL(string: "itms-apps://apps.apple.com/account/subscriptions")`.
- **Checking `isPro` without considering `-screenshotMode`:** After D-12 fix, screenshotMode should only bypass in DEBUG builds. Never add new production-mode screenshotMode checks.
- **Requesting HealthKit authorization at app launch:** Only request when user has health-synced habits. The existing `syncHealthKitHabits()` in HabitLandApp.swift handles this correctly.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Subscription status tracking | Custom receipt parsing | `Transaction.currentEntitlements` | Already implemented in ProManager, handles edge cases like revocation |
| Trial eligibility | Manual date tracking | `subscription.isEligibleForIntroOffer` | Apple manages trial state server-side |
| Purchase restoration | Custom sync logic | `AppStore.sync()` | Already implemented in `restorePurchases()` |
| Subscription management UI | In-app cancel/modify flow | `itms-apps://` deep link to iOS Settings | Apple requirement, they handle the UI |
| CloudKit sync | Manual record syncing for private data | SwiftData's `cloudKitDatabase: .private(...)` | Automatic sync built into the framework |
| Push notification token management | Manual token registration | UIKit's `registerForRemoteNotifications()` | Standard iOS pattern, AppDelegate handles token |

**Key insight:** The existing ProManager, HealthKitManager, and NotificationManager are already well-architected. This phase is primarily about enabling/connecting existing infrastructure, not building new systems.

## Common Pitfalls

### Pitfall 1: screenshotMode Bypass in Production
**What goes wrong:** `ProManager.isPro` currently returns `true` when `-screenshotMode` launch argument is present, regardless of build configuration. A user could theoretically exploit this.
**Why it happens:** The `-screenshotMode` argument was added for screenshot automation and the check was placed without `#if DEBUG` guard.
**How to avoid:** D-12 explicitly requires wrapping the screenshotMode check in `#if DEBUG`. Change line 26 of ProManager.swift.
**Warning signs:** `ProcessInfo.processInfo.arguments.contains("-screenshotMode")` appearing outside `#if DEBUG` blocks.

### Pitfall 2: CloudKit Sync Breaking Existing Local Data
**What goes wrong:** Enabling CloudKit sync on an existing SwiftData store can trigger schema migration issues if the CloudKit schema hasn't been properly initialized.
**Why it happens:** SwiftData + CloudKit requires the CloudKit schema to be deployed first via Xcode's CloudKit Console.
**How to avoid:** Use `initializeCloudKitSchema()` during development, deploy schema before release. The existing fallback code in SharedModelContainer already handles CloudKit failure gracefully.
**Warning signs:** "CloudKit ModelContainer failed" in console logs.

### Pitfall 3: Entitlements Not Matching Capabilities
**What goes wrong:** App crashes or silently fails when trying to use CloudKit/HealthKit/Push without proper entitlements.
**Why it happens:** Current HabitLand.entitlements only has App Groups. iCloud, HealthKit, and Push capabilities need to be added both in entitlements file and in Xcode project capabilities.
**How to avoid:** Must add: `com.apple.developer.icloud-container-identifiers`, `com.apple.developer.healthkit`, `aps-environment` to entitlements. Also enable in Xcode Signing & Capabilities tab.
**Warning signs:** "Code Signing Entitlements" build errors, or silent permission denials at runtime.

### Pitfall 4: PaywallView Context Breaking Existing Callers
**What goes wrong:** Adding a required `context` parameter to PaywallView breaks all existing call sites.
**Why it happens:** PaywallView is referenced in HomeDashboardView, PremiumGateView, GeneralSettingsView, and potentially more places.
**How to avoid:** Make context optional with default nil. Existing callers keep working, new contextual callers pass the context.
**Warning signs:** Compile errors in multiple files after PaywallView signature change.

### Pitfall 5: StoreKit Configuration Team ID
**What goes wrong:** StoreKit testing fails or products don't load in sandbox because `_developerTeamID` is set to `"XXXXXXXXXX"` placeholder.
**Why it happens:** Placeholder was intentionally used while Apple Developer account was pending (D-11).
**How to avoid:** Replace with real team ID once account is approved. The Configuration.storekit file at `HabitLand/Configuration.storekit` needs updating.
**Warning signs:** `Failed to load products` in console, empty products array in ProManager.

## Code Examples

### Contextual PaywallView Header
```swift
// Add to PaywallView.swift
var context: PaywallContext? = nil

// In headerSection, conditionally show context-specific header:
private var headerSection: some View {
    VStack(spacing: HLSpacing.md) {
        if let context {
            // Contextual header
            ZStack {
                Circle()
                    .fill(Color.hlPrimary.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: context.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(Color.hlPrimary)
            }
            .padding(.top, HLSpacing.xl)

            Text(context.title)
                .font(HLFont.title1(.bold))
                .foregroundStyle(Color.hlTextPrimary)
            Text(context.description)
                .font(HLFont.body())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HLSpacing.lg)
        } else {
            // Generic header (existing code)
            // ... crown icon + "HabitLand Pro" + "Unlock your full potential"
        }
    }
}
```

### Security: screenshotMode Guard Fix
```swift
// ProManager.swift line 22-27, change isPro:
var isPro: Bool {
    #if DEBUG
    if debugProEnabled { return true }
    if ProcessInfo.processInfo.arguments.contains("-screenshotMode") { return true }
    #endif
    return !purchasedProductIDs.isEmpty
}
```

### SharedModelContainer: Replace fatalError
```swift
// SharedModelContainer.swift line 49, replace fatalError:
do {
    return try ModelContainer(for: schema, configurations: [fallbackConfig])
} catch {
    print("CRITICAL: ModelContainer creation failed completely: \(error)")
    // Return in-memory container as absolute last resort
    let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try! ModelContainer(for: schema, configurations: [inMemoryConfig])
}
```

### CloudKit Sync Enable
```swift
// SharedModelContainer.swift -- change cloudKitDatabase parameter:
config = ModelConfiguration(
    schema: schema,
    url: url,
    cloudKitDatabase: .private("iCloud.azc.HabitLand")
)
```

### Subscription Management Deep Link
```swift
// In GeneralSettingsView, add to Account section:
if proManager.isPro {
    Button {
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    } label: {
        settingsRow(icon: "creditcard.fill", color: .hlPrimary, title: "Manage Subscription")
    }
}
```

### Blurred Preview for Gated Tabs
```swift
// Recommended: new ViewModifier in PremiumGateView.swift
struct BlurredPremiumGateModifier: ViewModifier {
    let feature: String
    let icon: String
    @ObservedObject private var proManager = ProManager.shared
    @State private var showPaywall = false

    func body(content: Content) -> some View {
        if proManager.isPro {
            content
        } else {
            ZStack {
                content
                    .blur(radius: 10)
                    .allowsHitTesting(false)

                VStack(spacing: HLSpacing.md) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.hlPrimary)

                    Text("Unlock \(feature)")
                        .font(HLFont.title2(.bold))
                        .foregroundStyle(Color.hlTextPrimary)

                    Button {
                        showPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Pro")
                        }
                        .font(HLFont.headline())
                        .foregroundStyle(.white)
                        .padding(.horizontal, HLSpacing.xl)
                        .padding(.vertical, HLSpacing.md)
                        .background(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(HLRadius.lg)
                    }
                }
                .padding(HLSpacing.xl)
                .hlCard()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: feature == "Sleep Tracking"
                    ? .sleepTracking : .socialFeatures)
            }
        }
    }
}

extension View {
    func blurredPremiumGate(feature: String, icon: String) -> some View {
        modifier(BlurredPremiumGateModifier(feature: feature, icon: icon))
    }
}
```

### Entitlements File (target state)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.azc.HabitLand</string>
    </array>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.azc.HabitLand</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
        <string>CloudDocuments</string>
    </array>
    <key>com.apple.developer.healthkit</key>
    <true/>
    <key>com.apple.developer.healthkit.access</key>
    <array/>
    <key>aps-environment</key>
    <string>development</string>
</dict>
</plist>
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| StoreKit 1 (SKPaymentQueue) | StoreKit 2 (Product, Transaction) | iOS 15+ | Already using StoreKit 2 -- no migration needed |
| Manual receipt validation | Transaction.currentEntitlements | iOS 15+ | Already using modern approach |
| NSPersistentCloudKitContainer | SwiftData + CloudKit | iOS 17+ | Already using SwiftData, just needs CloudKit enabled |

**Deprecated/outdated:**
- StoreKit 1 APIs (SKProduct, SKPaymentQueue) -- not used in this project, good.
- Original receipt validation (receipt file parsing) -- not used, using Transaction API instead.

## Open Questions

1. **Apple Developer Account Status**
   - What we know: Account is pending approval (documented in STATE.md and project memory)
   - What's unclear: When it will be approved, blocking sandbox IAP testing and CloudKit schema deployment
   - Recommendation: Implement all code changes now using local StoreKit testing. Platform activation code can be written but will need real-device testing when account is approved. The existing Configuration.storekit allows full local testing of purchase flows.

2. **CloudKit Schema Deployment**
   - What we know: CloudKitManager uses record types (SocialProfile, FriendRequest, etc.) that need to exist in CloudKit Console
   - What's unclear: Whether these schemas have been deployed or only exist in code
   - Recommendation: After account approval, use Xcode's CloudKit schema initialization to deploy. The existing fallback in SharedModelContainer handles failures gracefully.

3. **Info.plist HealthKit Usage Description**
   - What we know: HealthKit requires `NSHealthShareUsageDescription` in Info.plist
   - What's unclear: Whether this key already exists
   - Recommendation: Verify and add if missing. Required for App Store submission.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Swift Testing (iOS 17+, @Test macro) + XCTest for UI tests |
| Config file | Built into Xcode project |
| Quick run command | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing HabitLandTests` |
| Full suite command | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16'` |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| MON-01 | Yearly purchase flow | manual-only | StoreKit sandbox testing required | N/A |
| MON-02 | Lifetime purchase flow | manual-only | StoreKit sandbox testing required | N/A |
| MON-03 | Contextual paywall appears at limit | unit | Test `canCreateHabit` with count >= 3 | Partial (HabitLandTests.swift) |
| MON-04 | Manage subscription deep link | manual-only | Requires real device with active subscription | N/A |
| MON-05 | Purchase persists across reinstall | manual-only | StoreKit sandbox reinstall test | N/A |
| MON-06 | Pricing is $19.99/yr + $39.99 | unit | Verify Configuration.storekit values | No -- Wave 0 |
| PLT-01 | iCloud sync works | manual-only | Requires Apple Developer account + real device | N/A |
| PLT-02 | HealthKit reads real data | manual-only | Requires real device with Health data | N/A |
| PLT-03 | Push notifications fire | manual-only | Local notifications testable in Simulator | N/A |

### Sampling Rate
- **Per task commit:** Build succeeds (`xcodebuild build -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16'`)
- **Per wave merge:** Unit tests pass + manual paywall verification
- **Phase gate:** Full build + unit tests green, manual StoreKit sandbox purchase test

### Wave 0 Gaps
- [ ] `HabitLandTests/ProManagerTests.swift` -- covers MON-03 (canCreateHabit logic), MON-06 (product ID constants match config)
- [ ] Verify `NSHealthShareUsageDescription` exists in Info.plist

*(Most requirements are manual-only due to StoreKit sandbox/real device dependencies. Unit tests cover the gating logic.)*

## Sources

### Primary (HIGH confidence)
- Codebase analysis -- ProManager.swift, PaywallView.swift, PremiumGateView.swift, SharedModelContainer.swift, GeneralSettingsView.swift, ContentView.swift, HealthKitManager.swift, NotificationManager.swift, HabitLandApp.swift, Configuration.storekit, HabitLand.entitlements
- CONTEXT.md -- 13 locked decisions, 4 discretion areas, 5 deferred items

### Secondary (MEDIUM confidence)
- Apple Developer documentation for StoreKit 2, SwiftData+CloudKit, HealthKit entitlements -- standard patterns verified against codebase usage

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all frameworks already integrated, just need enabling
- Architecture: HIGH -- existing patterns are clear and well-structured, changes are incremental
- Pitfalls: HIGH -- identified from direct codebase analysis (screenshotMode bypass, fatalError, entitlements gap, CloudKit schema)

**Research date:** 2026-03-21
**Valid until:** 2026-04-21 (stable Apple frameworks, no fast-moving dependencies)
