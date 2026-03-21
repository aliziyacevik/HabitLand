# Architecture

**Analysis Date:** 2026-03-21

## Pattern Overview

**Overall:** Layered MV pattern (Model-View without traditional ViewModels) using SwiftUI with declarative state management

**Key Characteristics:**
- SwiftUI-native data binding using `@Query` and `@Environment` for reactive views
- SwiftData for persistent local storage with optional CloudKit sync
- Data layer abstraction through Services (ProManager, AchievementManager, NotificationManager, etc.)
- Component-based UI with reusable design system tokens
- Tab-based navigation with sheet/modal overlays for detail views

## Layers

**Presentation Layer (Views):**
- Purpose: Render UI, handle user interactions, display data reactively
- Location: `HabitLand/Screens/`, `HabitLand/Components/`
- Contains: SwiftUI View structs organized by screen/feature
- Depends on: Models (SwiftData), Services (ProManager, AchievementManager, etc.), DesignSystem
- Used by: User interactions, quick actions

**Component Library (Reusable UI):**
- Purpose: Shared UI components and design system compliance
- Location: `HabitLand/Components/`, `HabitLand/DesignSystem/`
- Contains: Common components (cards, inputs, navigation), design tokens (colors, typography, spacing)
- Depends on: Theme system (ActiveAccent, HLFont, HLSpacing)
- Used by: All Screens

**Models & Data (SwiftData):**
- Purpose: Define data schema and persistent storage
- Location: `HabitLand/Models/Models.swift`, `HabitLand/Models/HabitTemplate.swift`
- Contains: `@Model` classes (Habit, HabitCompletion, SleepLog, UserProfile, Achievement, Friend, Challenge, AppNotification)
- Depends on: Foundation, SwiftData
- Used by: All layers (views query data, services manipulate data)

**Service Layer:**
- Purpose: Business logic, external integrations, cross-cutting concerns
- Location: `HabitLand/Services/`
- Contains: Managers for Pro features, notifications, HealthKit, CloudKit, achievements, theme
- Depends on: Models, SwiftData context, external SDKs (StoreKit, UserNotifications, HealthKit, CloudKit)
- Used by: Views through `@ObservedObject`, app lifecycle hooks

**Design System:**
- Purpose: Centralized styling and visual consistency
- Location: `HabitLand/DesignSystem/` (Theme.swift, Effects.swift)
- Contains: Colors (hlPrimary, hlSuccess, hlError), typography (HLFont), spacing (HLSpacing), animations (HLAnimation), effects
- Depends on: SwiftUI, UIKit (for adaptive colors)
- Used by: All screens and components

## Data Flow

**Habit Completion Flow:**

1. User taps checkbox in `DailyHabitsOverview` or `HomeDashboardView`
2. View creates/updates `HabitCompletion` in SwiftData context
3. `@Query` automatically re-executes, updating dependent computed properties (currentStreak, completionPercent, etc.)
4. `AchievementManager.checkAll()` runs to evaluate achievement unlock conditions
5. `NotificationManager` schedules celebration or summary notifications if enabled
6. HealthKit sync triggered if metric is linked via `ProManager.syncWithHealthKit()`

**App Launch Flow:**

1. `HabitLandApp` entry point initializes `SharedModelContainer`
2. `ContentView` checks `hasCompletedOnboarding` UserDefault
3. If first launch: shows `OnboardingView` → sets flag → transitions to `mainTabView`
4. If returning user: renders tab bar with `HomeDashboardView`, `HabitListView`, `SleepDashboardView`, etc.
5. Services initialize: `ProManager.loadProducts()`, `HealthKitManager.syncHealthHabits()`, `NotificationManager.requestPermission()`
6. Quick action handling via `AppDelegate`/`SceneDelegate` for home screen shortcuts

**State Management:**
- **Local View State:** `@State` for transient UI state (sheet presentation, alerts, animations)
- **Persistent Data:** SwiftData `@Query` for reactive binding to model changes
- **App-wide State:** `@AppStorage` (UserDefaults), `@ObservedObject` for services (ProManager, ThemeManager)
- **Service State:** Managers maintain published properties for views to observe

## Key Abstractions

**HabitTemplate System:**
- Purpose: Provide guided habit creation with pre-configured icons, colors, categories
- Examples: `HabitLand/Models/HabitTemplate.swift`
- Pattern: Static collection of structured templates (name, icon, color, category) that feed the `CreateHabitView`

**Achievement System:**
- Purpose: Track user milestones and unlock badges based on progress
- Examples: `AchievementManager.checkAll()` evaluates conditions for "First Step", "On Fire", "Century", etc.
- Pattern: Declarative conditions (switch on achievement name) that read model state and toggle `isUnlocked` flag

**Theme/Accent System:**
- Purpose: Dynamic theming with user-selectable accent colors
- Examples: `ActiveAccent.current`, `Theme.swift` defines `AccentTheme` enum
- Pattern: Thread-safe color lookup; primary color updates via `ThemeManager.setAccentTheme()` persist to UserDefaults

**Pro/Paywall System:**
- Purpose: StoreKit2 integration for subscriptions and feature gating
- Examples: `ProManager.swift` with yearly and lifetime products
- Pattern: `@Published var isPro` checked before showing premium features; debug override in DEBUG builds

**Quick Action System:**
- Purpose: Home screen shortcuts and app shortcuts
- Examples: "Add Habit", "Today's Progress", "Log Sleep"
- Pattern: Enum-based routing in `HabitLandApp`, captured by `AppDelegate`, passed through `NotificationCenter.post()`

## Entry Points

**App Entry:**
- Location: `HabitLand/HabitLandApp.swift`
- Triggers: App launch
- Responsibilities: Initialize ModelContainer, set up quick actions, seed data, request notifications, sync HealthKit

**Root Navigation:**
- Location: `HabitLand/ContentView.swift`
- Triggers: After onboarding check
- Responsibilities: Render tab view, handle quick actions, manage sheet/modal overlays

**Home Screen:**
- Location: `HabitLand/Screens/Home/HomeDashboardView.swift`
- Triggers: App launch (default tab), tab bar selection
- Responsibilities: Display daily habit completion progress, streak summary, insights, celebrations

**Habit Management:**
- Location: `HabitLand/Screens/Habits/HabitListView.swift`, `HabitDetailView.swift`, `CreateHabitView.swift`
- Triggers: Tab selection, navigation push
- Responsibilities: List habits, create/edit habits, archive/delete, view history

## Error Handling

**Strategy:** Graceful degradation with fallbacks

**Patterns:**
- CloudKit sync failure falls back to local-only storage (see `SharedModelContainer` try/catch)
- HealthKit permission denial gracefully disables sync without breaking app
- StoreKit product loading failure shows retry UI in paywall
- Notification permission denial continues app with warning toast
- Database deletion/archival wrapped in try/catch with optional chaining

## Cross-Cutting Concerns

**Logging:**
- Minimal console output; uses print() for development/screenshot mode debugging
- No structured logging framework; relies on Xcode debugging

**Validation:**
- Form inputs validated in `CreateHabitView` and `EditHabitView` (name not empty, valid times)
- Model invariants (e.g., currentStreak computed property handles nil completions)
- No centralized validation layer

**Authentication:**
- No user authentication; app is single-user with optional CloudKit sync
- Social features (challenges, leaderboard) require CloudKit sync setup
- iCloud sync status checked in `CloudKitManager.fetchUserID()` for permission gating

**Permissions:**
- Notification permission requested lazily after onboarding
- HealthKit permission requested during habit creation if metric selected
- Health/fitness data requires permission check before reading

---

*Architecture analysis: 2026-03-21*
