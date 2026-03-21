# Codebase Structure

**Analysis Date:** 2026-03-21

## Directory Layout

```
HabitLand/                          # Main app target
├── HabitLandApp.swift              # App entry point, AppDelegate, SceneDelegate
├── ContentView.swift                # Root tab navigation and onboarding gate
├── Models/                          # SwiftData models and templates
│   ├── Models.swift                 # Core data models (Habit, HabitCompletion, SleepLog, etc.)
│   └── HabitTemplate.swift          # Predefined habit templates for creation flow
├── Screens/                         # Feature screens organized by domain
│   ├── Home/                        # Dashboard and habit overview
│   │   ├── HomeDashboardView.swift  # Daily habits, streak summary, insights
│   │   ├── DailyHabitsOverview.swift # Quick habit completion panel
│   │   ├── StreakSummaryView.swift  # Longest/current streak display
│   │   ├── WeeklyProgressView.swift # Week-over-week completion chart
│   │   └── InsightsOverviewView.swift # Analytics and statistics
│   ├── Habits/                      # Habit CRUD
│   │   ├── HabitListView.swift      # Browseable list of all habits
│   │   ├── CreateHabitView.swift    # New habit form with template picker
│   │   ├── EditHabitView.swift      # Modify existing habit
│   │   ├── HabitDetailView.swift    # Single habit history and stats
│   │   └── HabitListItemView.swift  # List cell component
│   ├── Sleep/                       # Sleep tracking
│   │   ├── SleepDashboardView.swift # Sleep overview and logs
│   │   ├── LogSleepView.swift       # Manual sleep entry form
│   │   ├── SleepHistoryView.swift   # Past logs list
│   │   ├── SleepAnalyticsView.swift # Trends and insights
│   │   └── SleepInsightsView.swift  # Sleep quality analysis
│   ├── Gamification/                # Achievements, levels, streaks
│   │   ├── AchievementsView.swift   # Badge display and progress
│   │   ├── StreakOverviewView.swift # Streak leaderboard
│   │   ├── LevelProgressView.swift  # XP and level progression
│   │   ├── MilestonesView.swift     # Milestone celebrations
│   │   └── RewardsView.swift        # Reward shop/system
│   ├── Social/                      # Friend features and social challenges
│   │   ├── SocialHubView.swift      # Social features gateway
│   │   ├── FriendsView.swift        # Friend list and add
│   │   ├── LeaderboardView.swift    # Streak competition
│   │   ├── ChallengesView.swift     # Group challenges
│   │   ├── FriendProfileView.swift  # Friend details
│   │   └── SocialFeedView.swift     # Activity feed
│   ├── Discovery/                   # Habit suggestions and marketplace
│   │   ├── HabitDiscoveryView.swift # Recommended habits
│   │   ├── HabitCategoriesView.swift# Browse by category
│   │   ├── HabitPackDetailView.swift# Pack preview and import
│   │   └── RecommendedHabitsView.swift # Personalized suggestions
│   ├── Premium/                     # Pro feature paywall
│   │   ├── PremiumView.swift        # Feature comparison and pricing
│   │   ├── PromoCodeView.swift      # Redemption form
│   │   └── PaywallView.swift        # Purchase flow
│   ├── Profile/                     # User profile and stats
│   │   └── ProfileView.swift        # User info, stats, level display
│   ├── Settings/                    # App configuration
│   │   ├── SettingsView.swift       # Settings home/menu
│   │   ├── NotificationSettingsView.swift # Notification preferences
│   │   ├── GeneralSettingsView.swift    # App settings
│   │   ├── AppearanceSettingsView.swift # Theme, accent color
│   │   ├── PrivacySettingsView.swift    # Data/privacy settings
│   │   ├── HabitSettingsView.swift      # Habit behavior settings
│   │   └── DataExportView.swift        # Export user data
│   ├── Notifications/               # Push notification management
│   │   └── NotificationCenterView.swift # Notification history/settings
│   ├── Onboarding/                  # First-time user experience
│   │   ├── OnboardingView.swift     # Main onboarding flow
│   │   └── [Onboarding pages]       # Individual slides with animations
│   └── Analytics/                   # Data analysis screens
│       ├── AnalyticsView.swift      # Analytics dashboard
│       └── TrendAnalysisView.swift  # Trend computation and display
├── Components/                      # Reusable UI components
│   ├── Common/                      # Generic components
│   │   ├── HabitCard.swift          # Habit display card
│   │   ├── ProgressCircle.swift     # Circular progress indicator
│   │   ├── StreakBadge.swift        # Streak display
│   │   └── [other shared components]
│   ├── Navigation/                  # Navigation components
│   │   ├── TabBarView.swift         # Custom or standard tab bar
│   │   ├── NavigationLinkRouter.swift # Deep link routing
│   │   └── [navigation utilities]
│   ├── Cards/                       # Card-style containers
│   │   ├── InsightCard.swift        # Data visualization card
│   │   ├── AchievementCard.swift    # Badge card
│   │   └── [other card variants]
│   ├── Inputs/                      # Form inputs
│   │   ├── HabitNameField.swift     # Validated text input
│   │   ├── ColorPicker.swift        # Color selection
│   │   ├── IconPicker.swift         # SF Symbol picker
│   │   └── [form components]
│   ├── Gamification/                # Gamification UI
│   │   ├── LevelBadge.swift         # Level display
│   │   ├── XPBar.swift              # XP progress bar
│   │   └── [achievement components]
│   ├── Social/                      # Social feature components
│   │   ├── FriendAvatar.swift       # Friend profile pic
│   │   ├── ChallengeCard.swift      # Challenge display
│   │   └── [social components]
│   ├── Analytics/                   # Data visualization
│   │   ├── WeeklyChart.swift        # Bar/line chart
│   │   ├── HeatMap.swift            # Calendar heatmap
│   │   └── [analytics visualizations]
└── Services/                        # Business logic and integrations
    ├── SharedModelContainer.swift   # SwiftData setup and schema
    ├── ProManager.swift             # StoreKit2 subscriptions and product management
    ├── AchievementManager.swift     # Achievement unlock logic
    ├── ThemeManager.swift           # Accent theme switching
    ├── NotificationManager.swift    # Push notification scheduling
    ├── HealthKitManager.swift       # HealthKit sync for metrics
    ├── CloudKitManager.swift        # CloudKit sync for social/shared data
    └── ReviewManager.swift          # App store review prompt

├── DesignSystem/                    # Design tokens and utilities
│   ├── Theme.swift                  # Colors, fonts, spacing, accents
│   └── Effects.swift                # Animation effects and transitions

├── Assets.xcassets/                 # Image and color assets
│   ├── AppIcon.appiconset/          # App icon variants
│   ├── LaunchLogo.imageset/         # Launch screen logo
│   ├── LaunchBackground.colorset/   # Launch screen background
│   └── AccentColor.colorset/        # Dynamic accent color

├── Intents/                         # Siri Shortcuts and App Intents
│   └── [Intent definitions]

├── HabitLandApp.entitlements        # Entitlements (iCloud, push, etc.)
└── Info.plist                       # App configuration

HabitLandTests/                      # Unit and integration tests
├── Models/                          # Model tests
├── Services/                        # Service tests
└── [Feature-based test directories]

HabitLandUITests/                    # UI/automation tests
├── HabitLandUITests.swift           # Main test suite
└── Screens/                         # Screen-by-screen tests

HabitLandWatch/                      # watchOS companion app (minimal)
└── [Watch-specific code]

HabitLandWidget/                     # Home screen widget
├── WidgetView.swift                 # Widget UI
└── WidgetBundle.swift               # Widget configuration
```

## Directory Purposes

**Models/:**
- Purpose: Data schema and business object definitions
- Contains: SwiftData `@Model` classes, enums for categories/frequencies
- Key files: `Models.swift` (Habit, HabitCompletion, SleepLog, UserProfile, Achievement, Friend, Challenge), `HabitTemplate.swift` (template collection for UI)

**Screens/:**
- Purpose: Feature-specific views organized by domain
- Contains: Full-screen views that form the app navigation structure
- Key files: `HomeDashboardView.swift`, `CreateHabitView.swift`, `SleepDashboardView.swift`
- Organization: Each subdirectory (Home, Habits, Sleep, etc.) groups related screens and their supporting components

**Components/:**
- Purpose: Reusable UI building blocks
- Contains: Smaller views that appear across multiple screens
- Key files: Cards, inputs, navigation elements, design system applications
- Organization: Grouped by type (Common, Cards, Inputs, Navigation) to ease discovery

**Services/:**
- Purpose: Business logic, external integrations, state management
- Contains: Managers that handle permissions, storage, purchases, notifications, HealthKit, CloudKit
- Key files: `SharedModelContainer.swift` (data setup), `ProManager.swift` (subscriptions), `AchievementManager.swift` (achievement unlocking)

**DesignSystem/:**
- Purpose: Centralized styling definitions
- Contains: Colors, typography scales, spacing, animation definitions
- Key files: `Theme.swift` (color palette, fonts, spacing), `Effects.swift` (animations and transitions)

**Assets.xcassets/:**
- Purpose: Bundled image and color resources
- Contains: App icons, launch screen assets, dynamic color sets
- Committed: Yes (part of source control)

## Key File Locations

**Entry Points:**
- `HabitLand/HabitLandApp.swift`: App initialization, quick action setup, data seeding
- `HabitLand/ContentView.swift`: Root navigation gate, tab bar routing, onboarding check

**Configuration:**
- `HabitLand/Services/SharedModelContainer.swift`: SwiftData schema and storage setup
- `HabitLand/Services/ProManager.swift`: StoreKit product IDs and purchase state
- `HabitLand/Info.plist`: App metadata, build settings

**Core Logic:**
- `HabitLand/Models/Models.swift`: All data model definitions
- `HabitLand/Services/AchievementManager.swift`: Achievement unlock conditions
- `HabitLand/Screens/Home/HomeDashboardView.swift`: Primary data flow (habit completion, streak, insights)

**Testing:**
- `HabitLandTests/`: Unit tests for models and services
- `HabitLandUITests/HabitLandUITests.swift`: XCUITest automation for screens

## Naming Conventions

**Files:**
- View files: `[FeatureName]View.swift` (e.g., `HomeDashboardView.swift`, `CreateHabitView.swift`)
- Component files: `[ComponentName].swift` (e.g., `ProgressCircle.swift`, `HabitCard.swift`)
- Manager/Service files: `[Domain]Manager.swift` (e.g., `ProManager.swift`, `AchievementManager.swift`)
- Model files: `Models.swift` (single file for all models)

**Directories:**
- Screen directories: Feature-based (Home, Habits, Sleep, Social, etc.)
- Component directories: Type-based (Common, Cards, Inputs, Navigation, Gamification, Analytics, Social)
- Service files: Flat structure in Services/ directory

**Structs/Classes:**
- Views: Suffix with `View` (e.g., `HomeDashboardView`, `HabitDetailView`)
- Components: Descriptive names matching UI elements (e.g., `StreakBadge`, `ProgressCircle`)
- Services: Suffix with `Manager` (e.g., `ProManager`, `AchievementManager`)
- Models: Capitalized nouns (e.g., `Habit`, `Achievement`, `UserProfile`)

## Where to Add New Code

**New Feature Screen:**
- Create new directory under `Screens/` with feature name (e.g., `Screens/NewFeature/`)
- Place main screen view as `NewFeatureView.swift`
- Create sub-views for complex sections as `[Section]View.swift`
- Add tests in `HabitLandTests/NewFeature/`

**New Reusable Component:**
- Add to appropriate category directory under `Components/`
  - Generic UI: `Components/Common/`
  - Data card: `Components/Cards/`
  - Form input: `Components/Inputs/`
  - Chart/graph: `Components/Analytics/`
- Use descriptive name: `[ComponentName].swift`

**New Service/Manager:**
- Add `[Domain]Manager.swift` file directly in `Services/`
- Implement singleton pattern if needed: `static let shared = [DomainManager]()`
- Use `@MainActor` if updates UI from published properties

**New Data Model:**
- Add to `Models/Models.swift` with `@Model` decorator
- Include UUID, timestamps, and relationships
- Create computed properties for derived data (e.g., `currentStreak`)

**Shared Utilities:**
- Add extension to `Models/Models.swift` for model extensions
- Add computed properties to theme for new design tokens in `DesignSystem/Theme.swift`
- Add animation definitions to `DesignSystem/Effects.swift`

**Navigation/Routing:**
- Add cases to tab enum or create routing handlers in `ContentView.swift`
- Use NavigationStack with state-based routing (if refactoring to iOS 16+)
- Sheet/modal handling: define `@State` in parent view, pass binding to child

## Special Directories

**Assets.xcassets/:**
- Purpose: Bundled image and color resources
- Generated: No (manually created/managed)
- Committed: Yes

**.derivedData/:**
- Purpose: Xcode build cache and intermediate files
- Generated: Yes (by Xcode)
- Committed: No (in .gitignore)

**HabitLandWidget/:**
- Purpose: Home screen widget code (separate target)
- Shares: `SharedModelContainer` via app groups
- Independent: Yes (separate bundle identifier extension)

**HabitLandWatch/:**
- Purpose: watchOS companion app (minimal feature set)
- Shares: SwiftData via app groups
- Independent: Yes (separate target)

---

*Structure analysis: 2026-03-21*
