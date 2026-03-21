# Phase 1: Monetization & Platform Activation - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can purchase Pro via real IAP ($19.99/yr + $39.99 lifetime) and the app runs with all platform capabilities (iCloud, HealthKit, Push) enabled. StoreKit 2 infrastructure (ProManager, PaywallView, PremiumGateModifier) already exists — this phase connects to real products and adds contextual paywall triggers.

</domain>

<decisions>
## Implementation Decisions

### Contextual Paywall Triggers
- **D-01:** Soft paywall approach — free users see value before hitting gate. Never block core habit tracking (up to 3 habits stays free).
- **D-02:** Contextual triggers at these 4 points:
  1. **4th habit creation** — existing `canCreateHabit()` check, but improve UX: show a dedicated "Upgrade" sheet with message "You've been tracking 3 habits — unlock unlimited to keep growing" instead of plain alert
  2. **Sleep tab access** — keep existing `.premiumGated()` but add feature preview: show blurred sleep data behind the gate so users see what they're missing
  3. **Social tab access** — same blurred preview approach as sleep
  4. **Achievement unlock attempt** — when free user taps a locked achievement, show paywall with "Unlock all 20+ achievements with Pro"
- **D-03:** No time-based or success-based upsells for v1 — keep it simple, add post-launch
- **D-04:** PaywallView contextual header: when triggered from a specific feature, show that feature's icon and description at top of paywall (e.g., "Unlock Sleep Tracking" with moon icon)

### Subscription Management
- **D-05:** Add "Manage Subscription" row in Settings (GeneralSettingsView) that deep-links to `itms-apps://apps.apple.com/account/subscriptions` — Apple handles the actual management UI
- **D-06:** Show current plan status in Settings: "Pro (Yearly)", "Pro (Lifetime)", or "Free Plan" with corresponding icon
- **D-07:** No in-app upgrade flow (yearly→lifetime) for v1 — Apple's subscription management handles plan changes

### Platform Activation
- **D-08:** iCloud sync: re-enable CloudKit sync in SharedModelContainer by removing the `#if false` guard. Show sync status indicator in Settings (syncing/synced/error)
- **D-09:** HealthKit: re-enable authorization request on first launch when user has health-synced habits. Show "Connected to Apple Health" badge in Settings when authorized
- **D-10:** Push notifications: already working as local notifications. Enable remote push (APNs) registration in AppDelegate for future server-triggered notifications, but keep current local notifications as primary
- **D-11:** Developer account activation: update team ID placeholder ("XXXXXXXXXX") to real team ID, enable iCloud and HealthKit capabilities in Xcode project

### Security Hardening
- **D-12:** Guard `-screenshotMode` Pro bypass with `#if DEBUG` — this is a production security risk
- **D-13:** Ensure `fatalError()` paths in ProManager are replaced with graceful fallbacks

### Claude's Discretion
- Exact blurred preview implementation for gated tabs
- Sync status indicator design in Settings
- HealthKit authorization prompt timing and messaging
- Error handling for failed purchases beyond current alert

</decisions>

<specifics>
## Specific Ideas

- Paywall should feel premium but not aggressive — user should feel like they're unlocking value, not being nagged
- When triggered contextually, paywall header should show the specific feature that triggered it (not generic "Upgrade to Pro")
- Fiyatlama: $19.99/yr + $39.99 lifetime — lifetime marked as "BEST DEAL" (already configured)
- Free trial: 7-day on yearly plan (already configured in StoreKit)

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Monetization
- `HabitLand/Services/ProManager.swift` — Purchase flow, product IDs, free tier limits, trial eligibility
- `HabitLand/Screens/Premium/PaywallView.swift` — Current paywall UI, plan cards, legal section
- `HabitLand/Screens/Premium/PremiumGateView.swift` — PremiumGateModifier, gate overlay, ProBadge
- `HabitLand/Configuration.storekit` — StoreKit product configuration, pricing, trial setup

### Feature Gating
- `HabitLand/Screens/ContentView.swift` — Tab-level `.premiumGated()` usage for Sleep and Social
- `HabitLand/Screens/Home/HomeDashboardView.swift` — Habit creation limit check
- `HabitLand/Screens/Habits/HabitListView.swift` — Free tier notification banner
- `HabitLand/Screens/Settings/AppearanceSettingsView.swift` — Theme gating

### Platform Services
- `HabitLand/Services/CloudKitManager.swift` — iCloud social features, container ID, sync logic
- `HabitLand/Services/SharedModelContainer.swift` — SwiftData container, CloudKit sync toggle
- `HabitLand/Services/HealthKitManager.swift` — Health data integration, metric types, auto-completion
- `HabitLand/Services/NotificationManager.swift` — Local notifications, streak alerts, weekly summary
- `HabitLand/HabitLandApp.swift` — App lifecycle, service initialization, capability setup

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ProManager.shared` — Singleton, already handles purchase flow, restore, promo codes
- `PaywallView` — Complete paywall UI with plan cards, trial banner, legal section
- `.premiumGated(feature:icon:)` — View modifier for gating entire views
- `ProBadge` — Small Pro indicator label component
- `PremiumGateView` — Full overlay with lock icon, feature description, upgrade button

### Established Patterns
- `@Environment(ProManager.self)` for Pro state access in views
- `proManager.isPro` boolean check for conditional rendering
- `proManager.canCreateHabit(currentCount:)` for limit enforcement
- `@Query` macro for SwiftData model queries in views
- Sheet presentation via `@State var showPaywall = false`

### Integration Points
- `ContentView.swift` tab bar — Sleep and Social tabs already gated
- `HabitLandApp.swift` — Service initialization, HealthKit sync trigger
- `GeneralSettingsView.swift` — Settings rows for subscription management
- `SharedModelContainer.swift` — CloudKit sync enable/disable toggle

</code_context>

<deferred>
## Deferred Ideas

- Time-based upsells (e.g., after 7 days of use) — post-launch optimization
- Success-based upsells (e.g., after 10 habit completions) — post-launch
- Rich notifications with custom UI — v2
- Yearly → Lifetime upgrade flow — Apple handles via subscription management
- Remote push notifications from server — v2 (local notifications sufficient for v1)

</deferred>

---

*Phase: 01-monetization-platform-activation*
*Context gathered: 2026-03-21*
