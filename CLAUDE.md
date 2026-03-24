<!-- GSD:project-start source:PROJECT.md -->
## Project

**HabitLand**

HabitLand, gamification odaklı bir iOS habit tracker uygulamasıdır. Kullanıcılar günlük alışkanlıklarını takip eder, streak'ler ve rozetlerle motivasyon kazanır, arkadaşlarıyla yarışır ve uyku kalitelerini izler. SwiftUI + SwiftData ile iOS 17+ hedeflenerek geliştirilmektedir.

**Core Value:** Kullanıcıların alışkanlıklarını eğlenceli ve sosyal bir deneyimle kalıcı hale getirmesi — "Bu sefer yarıda bırakmayacaksın."

### Constraints

- **Platform**: iOS 17+ only, SwiftUI + SwiftData
- **Backend**: CloudKit only — no custom server
- **Developer Account**: Active — iCloud/HealthKit/Push enabled
- **Monetization**: Apple IAP only (StoreKit 2)
- **Language**: Swift 5.0, no third-party dependencies (pure Apple stack)
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Swift 5.0 - All application code, UI, business logic
- SwiftUI - Declarative UI framework for all screens
- Objective-C - Bridging layer for UIKit integration where needed
## Runtime
- iOS 17.0 (minimum deployment target)
- watchOS (Watch app target available)
- Widget Extension (iOS App Extension)
- Apple Silicon and Intel x86 supported
- Built with Xcode build system (pbxproj)
## Frameworks
- SwiftUI - Modern declarative UI (iOS 17+)
- UIKit - System integration (AppDelegate, SceneDelegate, StatusBar)
- SwiftData - Modern ORM for local data storage
- HealthKit - Integration with Apple Health data
- CloudKit - Apple's cloud database service
- StoreKit 2 - App Store In-App Purchase framework
- UserNotifications - Push notification scheduling
- StoreKit - App Store review prompts
- Custom Design System - Custom theme/colors
## Key Dependencies
- SwiftData - Local persistence (system framework, no external dependency)
- SwiftUI - UI framework (system framework)
- CloudKit - Social backend (system framework, currently disabled)
- HealthKit - Health data sync (system framework)
- UserNotifications - Local push notifications (system framework)
- StoreKit 2 - App Store purchases (system framework)
## Data Models
- Habit - User habit with tracking metadata
- HabitCompletion - Daily completion records with timestamps
- SleepLog - Sleep tracking data (bedtime, wake time, quality, mood)
- UserProfile - User identity, level, XP, bio, avatar
- Achievement - Achievement tracking with unlock status
- Friend - Social connection data
- Challenge - Group challenges between friends
- AppNotification - Local notification records
- Habit → HabitCompletion (one-to-many, cascade delete)
- CloudKit records: SocialProfile, FriendRequest, SocialChallenge, ChallengeParticipant, Nudge
## Configuration
- SwiftData stores in app group container for widget/watch access
- App Group ID: `group.azc.HabitLand`
- Database URL: `{appGroupContainer}/HabitLand.sqlite`
- iOS Deployment Target: 17.0
- Swift Version: 5.0
- Entitlements: App Groups capability
- `-screenshotMode` argument enables demo data seeding
- DEBUG builds support ProManager debug toggle
- CloudKit availability detection at runtime
## Platform Requirements
- Xcode (Apple's IDE)
- iOS 17.0+ SDK
- Swift 5.0 compiler
- Target deployment: iOS 17.0 and later
- iPhone models with iOS 17 support
- watchOS support via HabitLandWatch target
- Widget support via HabitLandWidget extension
- Apple Developer Program account (pending for iCloud/HealthKit/Push)
- App Store signing certificates and provisioning profiles
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- View files: `[FeatureName]View.swift` (e.g., `HomeDashboardView.swift`, `HabitCard.swift`)
- Model files: `Models.swift` (all data models in single file), or `[ModelName].swift` for enums/templates (e.g., `HabitTemplate.swift`)
- Service/Manager files: `[Name]Manager.swift` or `[Name]Service.swift` (e.g., `NotificationManager.swift`, `ThemeManager.swift`)
- Intent files: `[Action]Intent.swift` (e.g., `CompleteHabitIntent.swift`, `DailyProgressIntent.swift`)
- Test files: `[Name]Tests.swift` in HabitLandTests/, `[Name]Tests.swift` in HabitLandUITests/ (e.g., `HabitLandTests.swift`, `QAAuditTests.swift`)
- PascalCase: `HomeDashboardView`, `NotificationManager`, `Habit`, `UserProfile`
- Enum cases: camelCase or lowercase depending on context
- Extensions: Organized by MARK sections with dashes (e.g., `// MARK: - Authorization`, `// MARK: - Computed Properties`)
- camelCase: `scheduleHabitReminder`, `requestPermission`, `fetchCount`, `checkAuthorization`
- Private functions: prefix with `private func` (e.g., `private func setupQuickActions()`)
- Getter/computed properties: `var currentStreak: Int`, `var todayCompleted: Bool`
- camelCase for local variables and properties: `userName`, `completedCount`, `streakDays`, `isFocused`
- Private properties: `@State private var`, `private let`, `nonisolated(unsafe) static var`
- Published properties for Observable: `@Published var isAuthorized`
- Colors: `hl` prefix in extension (e.g., `Color.hlPrimary`, `Color.hlSuccess`, `Color.hlError`)
- Spacing: `HLSpacing` struct with static constants (e.g., `HLSpacing.xs`, `HLSpacing.md`)
- Fonts: `HLFont` struct with static functions (e.g., `HLFont.headline()`, `HLFont.body()`)
- Radius: `HLRadius` struct (e.g., `HLRadius.md`, `HLRadius.lg`)
- Icons: `HLIcon` enum/constants (e.g., `HLIcon.flame`, `HLIcon.trendUp`)
- Shadows: `HLShadow.Level`
## Code Style
- No explicit linting/formatting config (Xcode defaults applied)
- Spaces for indentation (not tabs), 4-space indent
- Maximum line length: not explicitly enforced; lines typically ~100 chars
- Trailing commas in multi-line collections
- Section dividers: `// MARK: - Section Name` (with dashes)
- Single-line comments on complex logic (not excessive)
- No JSDoc-style comments; focus on clear code over documentation comments
- Inline comments for non-obvious behavior (e.g., `// Fire at 8pm if not completed`)
- Opening braces on same line: `if condition {`
- Closing braces on new line (standard Swift)
- Minimal braces in simple conditions where readable
## Import Organization
## SwiftUI Component Patterns
- Components are `struct` implementing `View` protocol
- Multiple initializers supported: one for model objects, one for preview/manual construction
- Example from `HabitCard.swift`:
- Main `body` property contains high-level layout
- Complex subviews extracted into `private var` properties
- Subview pattern: `private var iconView: some View { ... }`
- Example from `HabitCard.swift`:
- `@State` for local UI state: `@State private var showDailyOverview = false`
- `@Query` for SwiftData queries: `@Query(filter: ..., sort: ...) private var habits: [Habit]`
- `@Environment` for model context: `@Environment(\.modelContext) private var modelContext`
- `@ObservedObject` for published objects: `@ObservedObject private var proManager = ProManager.shared`
- `@Binding` for parent-child value passing: `@Binding var text: String`
- `@FocusState` for keyboard focus: `@FocusState private var isFocused: Bool`
- Design system modifiers chained: `.hlCard()`, `.hlButton()`, etc.
- Animations: `.animation(HLAnimation.quick, value: someState)`
- Transitions: `.transition(.opacity.combined(with: .move(edge: .top)))`
## Error Handling
- Try-catch in methods returning optional or Bool
- Silent failures (return false/nil) for permission/notification operations
- No exception throwing; preference for optional returns
- Example from `NotificationManager.swift`:
- Guard statements for required values: `guard totalCount > 0 else { return 0 }`
- Safe accessors for optional relationships: `var safeCompletions: [HabitCompletion] { completions ?? [] }`
- nil-coalescing in computed properties: `private var profile: UserProfile? { profiles.first }`
## Logging
## Model Design (SwiftData)
- `@Model` macro for persistent classes
- Classes (not structs): `final class Habit`, `final class UserProfile`
- UUID primary key: `var id: UUID = UUID()`
- Timestamps: `createdAt: Date`, `updatedAt: Date`
- Relationships: `@Relationship(deleteRule: .cascade) var completions: [HabitCompletion]? = []`
- Optional relationships for CloudKit compatibility: `var habit: Habit?`
- Safe accessors for optional relationships: `var safeCompletions: [HabitCompletion] { completions ?? [] }`
- Designated initializer: All properties initialized, UUIDs and dates set in init
- Example from `Models.swift`:
- Streak calculation: Iterates through sorted completions, early exit on first gap
- Weekly completion: Filters completions by date range
- Used heavily in `HomeDashboardView` and habit detail views
- No caching; computed on-demand (acceptable for small datasets per habit)
## Testing Patterns
- Unit tests in `HabitLandTests/`
- UI tests in `HabitLandUITests/`
- See TESTING.md for detailed patterns
## Screenshot Mode
- Launch argument flag: `-screenshotMode`
- Check via: `ProcessInfo.processInfo.arguments.contains("-screenshotMode")`
- Used to seed demo data and skip real initializations
- Example from `HabitLandApp.swift`:
## Actor Isolation (MainActor)
- `@MainActor final class` for managers (e.g., `NotificationManager`, `ThemeManager`)
- `@MainActor` on methods that update UI state from background tasks
- Async/await for background operations: `Task { await manager.checkAuthorization() }`
- Thread-safe globals for theme: `nonisolated(unsafe) static var current` in `ActiveAccent`
## Special Patterns
- Defined as enum in app: `enum QuickAction: String`
- Configured in `setupQuickActions()` method
- Triggered via `AppDelegate` and `SceneDelegate`
- Notification center used for event propagation: `NotificationCenter.default.post(name: .quickActionTriggered, object: action)`
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern Overview
- SwiftUI-native data binding using `@Query` and `@Environment` for reactive views
- SwiftData for persistent local storage with optional CloudKit sync
- Data layer abstraction through Services (ProManager, AchievementManager, NotificationManager, etc.)
- Component-based UI with reusable design system tokens
- Tab-based navigation with sheet/modal overlays for detail views
## Layers
- Purpose: Render UI, handle user interactions, display data reactively
- Location: `HabitLand/Screens/`, `HabitLand/Components/`
- Contains: SwiftUI View structs organized by screen/feature
- Depends on: Models (SwiftData), Services (ProManager, AchievementManager, etc.), DesignSystem
- Used by: User interactions, quick actions
- Purpose: Shared UI components and design system compliance
- Location: `HabitLand/Components/`, `HabitLand/DesignSystem/`
- Contains: Common components (cards, inputs, navigation), design tokens (colors, typography, spacing)
- Depends on: Theme system (ActiveAccent, HLFont, HLSpacing)
- Used by: All Screens
- Purpose: Define data schema and persistent storage
- Location: `HabitLand/Models/Models.swift`, `HabitLand/Models/HabitTemplate.swift`
- Contains: `@Model` classes (Habit, HabitCompletion, SleepLog, UserProfile, Achievement, Friend, Challenge, AppNotification)
- Depends on: Foundation, SwiftData
- Used by: All layers (views query data, services manipulate data)
- Purpose: Business logic, external integrations, cross-cutting concerns
- Location: `HabitLand/Services/`
- Contains: Managers for Pro features, notifications, HealthKit, CloudKit, achievements, theme
- Depends on: Models, SwiftData context, external SDKs (StoreKit, UserNotifications, HealthKit, CloudKit)
- Used by: Views through `@ObservedObject`, app lifecycle hooks
- Purpose: Centralized styling and visual consistency
- Location: `HabitLand/DesignSystem/` (Theme.swift, Effects.swift)
- Contains: Colors (hlPrimary, hlSuccess, hlError), typography (HLFont), spacing (HLSpacing), animations (HLAnimation), effects
- Depends on: SwiftUI, UIKit (for adaptive colors)
- Used by: All screens and components
## Data Flow
- **Local View State:** `@State` for transient UI state (sheet presentation, alerts, animations)
- **Persistent Data:** SwiftData `@Query` for reactive binding to model changes
- **App-wide State:** `@AppStorage` (UserDefaults), `@ObservedObject` for services (ProManager, ThemeManager)
- **Service State:** Managers maintain published properties for views to observe
## Key Abstractions
- Purpose: Provide guided habit creation with pre-configured icons, colors, categories
- Examples: `HabitLand/Models/HabitTemplate.swift`
- Pattern: Static collection of structured templates (name, icon, color, category) that feed the `CreateHabitView`
- Purpose: Track user milestones and unlock badges based on progress
- Examples: `AchievementManager.checkAll()` evaluates conditions for "First Step", "On Fire", "Century", etc.
- Pattern: Declarative conditions (switch on achievement name) that read model state and toggle `isUnlocked` flag
- Purpose: Dynamic theming with user-selectable accent colors
- Examples: `ActiveAccent.current`, `Theme.swift` defines `AccentTheme` enum
- Pattern: Thread-safe color lookup; primary color updates via `ThemeManager.setAccentTheme()` persist to UserDefaults
- Purpose: StoreKit2 integration for subscriptions and feature gating
- Examples: `ProManager.swift` with yearly and lifetime products
- Pattern: `@Published var isPro` checked before showing premium features; debug override in DEBUG builds
- Purpose: Home screen shortcuts and app shortcuts
- Examples: "Add Habit", "Today's Progress", "Log Sleep"
- Pattern: Enum-based routing in `HabitLandApp`, captured by `AppDelegate`, passed through `NotificationCenter.post()`
## Entry Points
- Location: `HabitLand/HabitLandApp.swift`
- Triggers: App launch
- Responsibilities: Initialize ModelContainer, set up quick actions, seed data, request notifications, sync HealthKit
- Location: `HabitLand/ContentView.swift`
- Triggers: After onboarding check
- Responsibilities: Render tab view, handle quick actions, manage sheet/modal overlays
- Location: `HabitLand/Screens/Home/HomeDashboardView.swift`
- Triggers: App launch (default tab), tab bar selection
- Responsibilities: Display daily habit completion progress, streak summary, insights, celebrations
- Location: `HabitLand/Screens/Habits/HabitListView.swift`, `HabitDetailView.swift`, `CreateHabitView.swift`
- Triggers: Tab selection, navigation push
- Responsibilities: List habits, create/edit habits, archive/delete, view history
## Error Handling
- CloudKit sync failure falls back to local-only storage (see `SharedModelContainer` try/catch)
- HealthKit permission denial gracefully disables sync without breaking app
- StoreKit product loading failure shows retry UI in paywall
- Notification permission denial continues app with warning toast
- Database deletion/archival wrapped in try/catch with optional chaining
## Cross-Cutting Concerns
- Minimal console output; uses print() for development/screenshot mode debugging
- No structured logging framework; relies on Xcode debugging
- Form inputs validated in `CreateHabitView` and `EditHabitView` (name not empty, valid times)
- Model invariants (e.g., currentStreak computed property handles nil completions)
- No centralized validation layer
- No user authentication; app is single-user with optional CloudKit sync
- Social features (challenges, leaderboard) require CloudKit sync setup
- iCloud sync status checked in `CloudKitManager.fetchUserID()` for permission gating
- Notification permission requested lazily after onboarding
- HealthKit permission requested during habit creation if metric selected
- Health/fitness data requires permission check before reading
<!-- GSD:architecture-end -->

## Unit Test Zorunlulugu

Her yeni feature veya bug fix sonrasi:

1. **Unit test yaz** — Yeni eklenen/degistirilen business logic, manager, computed property icin unit test ZORUNLU
2. **Test'i calistir** — `xcodebuild test` ile testlerin gectigini dogrula
3. **Gecene kadar durma** — Test fail ederse, fix'le ve tekrar calistir. Test gecene kadar feature tamamlanmis sayilmaz
4. **XCUITest** — UI degisiklikleri icin hedeflenen ekrani test eden XCUITest de yaz

Test yazma istisna: Sadece copy/text degisikligi, asset ekleme, veya pure UI spacing/color tweaks icin test gerekmez.

## Force Unwrap & Safety Enforcement

- `!` (force unwrap) kullanildiktan sonra `grep -rn '!' ile tum yeni force unwrap'lari tara
- `URL(string:)!` YASAK — her zaman `guard let` veya `?? fallbackURL` kullan
- `Calendar.current.date(byAdding:)!` YASAK — her zaman `?? Date()` fallback ekle
- `best!.property` pattern'i YASAK — `if let` veya `guard let` kullan
- `@ScaledMetric` kullanirken her zaman `min(scaledValue, maxCap)` pattern'i uygula

## modelContext.save() Kurali

`modelContext.insert()` veya `modelContext.delete()` sonrasi **HER ZAMAN** `try? modelContext.save()` cagir.
Bunu unutmamak icin her mutation iceren fonksiyonda save() cagrisini kontrol et.

## QA Audit & Milestone Kurali

- Her major milestone tamamlandiginda Claude kullaniciya **"/qa-audit calistiralim mi?"** diye sormali
- Major milestone = yeni feature grubu tamamlama, buyuk refactor, release oncesi
- QA audit sonuclari versiyonlu klasorlerde saklanir (`.qa_audit/runs/vN/`)
- Onceki versiyonlarla karsilastirma yapilabilir

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
