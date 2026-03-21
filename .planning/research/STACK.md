# Technology Stack

**Project:** HabitLand - Monetization, ASO & App Store Launch
**Researched:** 2026-03-21

## Current State

The app is built on a **pure Apple stack** (no third-party dependencies). StoreKit 2 infrastructure already exists in `ProManager.swift` with yearly subscription ($19.99/yr with 1-week free trial) and lifetime purchase ($39.99). The StoreKit Configuration file is set up for local testing. ReviewManager handles smart review prompts. The foundation is solid -- this milestone is about connecting it to real App Store Connect products, building the paywall UI, and polishing for launch.

## Recommended Stack

### Monetization (StoreKit 2)

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| StoreKit 2 (native) | iOS 17+ | IAP subscriptions & one-time purchase | Already integrated. Pure Apple, no revenue share to middleman SDKs. Your existing `ProManager` handles products, purchases, verification, trial eligibility, and transaction listening correctly. | HIGH |
| SubscriptionStoreView | iOS 17+ | Built-in paywall UI | Apple's native SwiftUI paywall component. Handles trial eligibility display, subscription picker, purchase flow automatically. Customizable header. Eliminates building paywall from scratch. | HIGH |
| StoreKit Testing (Xcode) | Xcode 15+ | Local IAP testing | Already configured via `Configuration.storekit`. Test purchases, refunds, subscription renewals without App Store Connect. | HIGH |

**What NOT to use:**
- **RevenueCat SDK** -- Adds a third-party dependency (violates your pure Apple stack constraint), takes 1-5% revenue share on paid plans, and adds unnecessary complexity for a solo indie app with 2 products. StoreKit 2 handles everything you need natively.
- **Adapty / Superwall / Qonversion** -- Same reasoning. These make sense for apps with complex paywall A/B testing across dozens of products, not for a 2-product setup.
- **StoreKit 1** -- Deprecated as of WWDC 2024. StoreKit 2 is the only path forward.

### Paywall Design

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| SubscriptionStoreView | iOS 17+ | Primary paywall | Native Apple view with subscription picker, trial badge, and purchase CTA. Customize the marketing header with your own SwiftUI view showing gamification benefits. | HIGH |
| Custom soft paywall | SwiftUI | Feature-gate prompts | When user hits free limit (3 habits, 5 achievements), show a custom SwiftUI sheet that explains the Pro benefit and links to `SubscriptionStoreView`. More contextual than a generic paywall. | HIGH |

**Paywall strategy:**
- Soft paywall at feature gates (habit limit, achievement limit) -- user sees value before being asked to pay
- Hard paywall only for clearly Pro features (unlimited habits, advanced analytics, custom themes)
- Free trial CTA prominent on first paywall encounter (1-week trial already configured)

### App Store Submission

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Xcode Organizer | Xcode 16+ | Archive, upload, manage builds | Standard Apple toolchain for submission. No need for Fastlane for a solo project. | HIGH |
| App Store Connect | Web/App | Metadata, screenshots, pricing | Required. Configure products, set pricing, upload screenshots, write descriptions. | HIGH |
| TestFlight | Apple | Beta testing | Real-device testing of IAP with sandbox accounts before App Store review. Essential for validating StoreKit 2 integration works end-to-end. | HIGH |

**What NOT to use:**
- **Fastlane** -- Overkill for a solo developer with one app. Xcode's built-in archive/upload is sufficient. Fastlane adds Ruby dependency management headaches.
- **CI/CD pipelines (GitHub Actions, Bitrise)** -- Premature for launch. Add after you have a release cadence.

### ASO (App Store Optimization)

| Technology | Pricing | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| **Astro** (macOS app) | $108/year ($9/mo) | Keyword research, ranking tracking, competitor analysis | Built specifically for iOS/Apple App Store. Native macOS app. Pulls keyword popularity directly from Apple Search Ads data (most accurate source). No fluff -- focused on what indie devs need: keyword discovery, difficulty scores, ranking tracking. 90% of users see impression increase in first week after metadata update. | MEDIUM |
| **ASO.dev** (alternative) | From $9/mo | Keyword tracking, metadata editor, localization | Strong alternative to Astro. Integrates with App Store Connect directly. Better for localization workflows (relevant if you localize to Turkish). Has metadata editor with rollback. | MEDIUM |

**Recommendation: Start with Astro.** It is the most focused tool for a solo iOS developer. Use it for keyword research before submission, then track rankings post-launch.

**What NOT to use:**
- **AppTweak / Sensor Tower / Data.ai** -- Enterprise pricing ($100-500+/mo). Designed for teams managing portfolios of apps. Massive overkill for a single app launch.
- **Google Keyword Planner** -- Designed for web search, not App Store search. Different algorithm, different intent.

### Referral System

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Universal Links | iOS 17+ | Deep linking for referrals | Apple's native deep linking. User shares a link (e.g., `https://habitland.app/invite/CODE`), recipient taps, app opens to referral flow. Works without third-party SDKs. | HIGH |
| ShareLink (SwiftUI) | iOS 16+ | Native share sheet | Built-in SwiftUI view for sharing referral links. Clean, native feel. | HIGH |
| CloudKit (existing) | iOS 17+ | Store referral records | You already use CloudKit for social features. Store referral codes and redemptions in the same public database. No new infrastructure needed. | HIGH |
| UserDefaults / Keychain | iOS 17+ | Store pending referral code | For deferred deep links: if app isn't installed, store referral code after install. Clipboard-based approach is the native alternative to Firebase Dynamic Links (now deprecated). | MEDIUM |

**What NOT to use:**
- **Branch.io** -- Third-party dependency. Adds SDK complexity. Your referral system is simple enough (share code, friend installs, both get reward) that native Universal Links + CloudKit handles it.
- **Firebase Dynamic Links** -- Deprecated by Google. Do not adopt.

### UI/UX Polish

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| SwiftUI Animations | iOS 17+ | Micro-interactions, transitions | Already using custom animations (onboarding). Extend to habit completion celebrations, streak milestones, paywall transitions. | HIGH |
| SF Symbols 5+ | iOS 17+ | Consistent iconography | Apple's icon library. Variable color, new animation presets. Ensures App Store review compliance (no icon licensing issues). | HIGH |
| TipKit | iOS 17+ | Feature discovery tips | Native Apple framework for showing contextual tips. Use for onboarding users to Pro features, new social features. Non-intrusive, Apple-approved pattern. | MEDIUM |

### App Store Review Preparation

| Requirement | Status | Action Needed | Confidence |
|-------------|--------|---------------|------------|
| Privacy Policy URL | NEEDED | Host a privacy policy page. Use a simple GitHub Pages or Notion page. Required for any app collecting data. | HIGH |
| App Privacy Labels | NEEDED | Declare data collection in App Store Connect. HabitLand collects: health data (HealthKit), usage data (habits), identifiers (CloudKit). | HIGH |
| Screenshots (6.7", 6.1", iPad) | PARTIAL | Screenshot mode exists (`-screenshotMode`). Need final screenshots at required resolutions. Minimum: iPhone 6.7" (15 Pro Max), 6.1" (15 Pro). iPad optional but recommended. | HIGH |
| App Icon | REVIEW | Verify 1024x1024 App Store icon is final and meets Apple guidelines (no alpha channel, no rounded corners -- system applies them). | HIGH |
| Age Rating | NEEDED | Set in App Store Connect. HabitLand is likely 4+ (no objectionable content). Social features may push to 9+ depending on implementation. | HIGH |
| Export Compliance | NEEDED | Declare encryption usage. If using only HTTPS (CloudKit does), select "Yes, but exempt" with ITSAppUsesNonExemptEncryption = NO in Info.plist. | HIGH |
| Review Notes | NEEDED | Provide demo account or instructions for reviewer. Include how to test IAP (sandbox), how to see social features. | HIGH |
| IDFA Declaration | CHECK | If not using advertising tracking (you shouldn't be), declare "No" for App Tracking Transparency. Simplifies review. | HIGH |

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| IAP SDK | StoreKit 2 (native) | RevenueCat | Adds dependency, revenue share, unnecessary for 2 products |
| Paywall UI | SubscriptionStoreView | Custom SwiftUI | SubscriptionStoreView handles trial eligibility, localization, accessibility automatically |
| ASO Tool | Astro | Sensor Tower | Enterprise pricing, overkill for indie |
| Deep Linking | Universal Links | Branch.io | Third-party dependency, simple referral doesn't need it |
| CI/CD | Xcode Organizer | Fastlane | Ruby dependency, premature for single-app solo dev |
| Analytics | App Store Connect Analytics | Mixpanel/Amplitude | No third-party dependency; ASC gives downloads, revenue, retention for free |
| Crash Reporting | Xcode Organizer (Crashes) | Firebase Crashlytics | No SDK needed; Xcode Organizer shows crash logs post-release |

## Version Compatibility Notes

| Component | Minimum iOS | Notes |
|-----------|-------------|-------|
| StoreKit 2 | iOS 15+ | Full features available on iOS 17+ (your target) |
| SubscriptionStoreView | iOS 17+ | Perfect alignment with your deployment target |
| TipKit | iOS 17+ | Perfect alignment |
| Universal Links | iOS 9+ | Well-established, stable |
| ShareLink | iOS 16+ | Available on your target |
| App Store Connect API | N/A | Server-side, version independent |

## Implementation Priority

1. **StoreKit 2 finalization** -- Connect existing `ProManager` to real App Store Connect products. Your code is already correct; you just need real product IDs after developer account approval.
2. **Paywall UI** -- Build with `SubscriptionStoreView` + custom header. Add soft paywalls at feature gates.
3. **App Store metadata** -- Privacy policy, screenshots, description, keywords (use Astro for keyword research).
4. **Referral system** -- Universal Links + CloudKit. Build after core monetization is solid.
5. **Polish** -- TipKit integration, animation refinements, bug fixes.

## Key Insight

Your existing stack is already well-suited for this milestone. The "pure Apple stack" constraint is actually an advantage here -- StoreKit 2 + SubscriptionStoreView + CloudKit + Universal Links cover every requirement without adding a single dependency. The main work is configuration (App Store Connect), UI (paywall, polish), and content (ASO metadata, screenshots) rather than new technology adoption.

## Sources

- [StoreKit 2 - Apple Developer](https://developer.apple.com/storekit/)
- [What's New in StoreKit - WWDC25](https://developer.apple.com/videos/play/wwdc2025/241/)
- [StoreKit Views Guide - RevenueCat](https://www.revenuecat.com/blog/engineering/storekit-views-guide-paywall-swift-ui/) (reference only, not using their SDK)
- [Astro ASO Tool](https://tryastro.app/)
- [ASO.dev](https://aso.dev/)
- [App Store Submitting - Apple Developer](https://developer.apple.com/app-store/submitting/)
- [iOS App Store Submission Checklist 2026](https://www.ailoitte.com/blog/ios-app-store-submission-checklist/)
- [Deeplink URL Handling in SwiftUI - SwiftLee](https://www.avanderlee.com/swiftui/deeplink-url-handling/)
- [ASO in 2025 Complete Guide](https://asomobile.net/en/blog/aso-in-2025-the-complete-guide-to-app-optimization/)

---

*Stack research: 2026-03-21*
