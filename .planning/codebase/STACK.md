# Technology Stack

**Analysis Date:** 2026-03-21

## Languages

**Primary:**
- Swift 5.0 - All application code, UI, business logic
- SwiftUI - Declarative UI framework for all screens
- Objective-C - Bridging layer for UIKit integration where needed

## Runtime

**Environment:**
- iOS 17.0 (minimum deployment target)
- watchOS (Watch app target available)
- Widget Extension (iOS App Extension)

**Architecture:**
- Apple Silicon and Intel x86 supported
- Built with Xcode build system (pbxproj)

## Frameworks

**Core UI & State:**
- SwiftUI - Modern declarative UI (iOS 17+)
- UIKit - System integration (AppDelegate, SceneDelegate, StatusBar)

**Data Persistence:**
- SwiftData - Modern ORM for local data storage
  - Location: `HabitLand/Services/SharedModelContainer.swift`
  - Database: SQLite (HabitLand.sqlite)
  - Storage: App Groups container for widget/watch access
  - Current CloudKit sync: Disabled (pending developer account approval)

**Health & Fitness:**
- HealthKit - Integration with Apple Health data
  - Metrics: steps, water, exercise, calories, distance, stand hours, mindfulness, sleep
  - Location: `HabitLand/Services/HealthKitManager.swift`
  - Read-only permissions (no health data writes)

**Cloud & Social:**
- CloudKit - Apple's cloud database service
  - Container ID: `iCloud.azc.HabitLand`
  - Public database for social features (friends, challenges, leaderboards)
  - Currently disabled in ModelContainer (pending account)
  - Location: `HabitLand/Services/CloudKitManager.swift`

**In-App Purchases & Monetization:**
- StoreKit 2 - App Store In-App Purchase framework
  - Products: Yearly subscription, Lifetime purchase
  - Located in: `HabitLand/Services/ProManager.swift`
  - Configuration: `HabitLand/Configuration.storekit`
  - Trial support: Free trial period configurable via StoreKit config

**Local Notifications:**
- UserNotifications - Push notification scheduling
  - Habit reminders (daily)
  - Streak alerts (8pm if not completed)
  - Weekly summary (Sundays at 7pm)
  - Location: `HabitLand/Services/NotificationManager.swift`

**App Monetization & Reviews:**
- StoreKit - App Store review prompts
  - Smart prompt logic (15+ completions, 60-day min interval)
  - Location: `HabitLand/Services/ReviewManager.swift`

**Theme & Design:**
- Custom Design System - Custom theme/colors
  - Location: `HabitLand/DesignSystem/Theme.swift`
  - Location: `HabitLand/DesignSystem/Effects.swift`
  - AudioToolbox - Haptic feedback via Taptic Engine

## Key Dependencies

**Critical:**
- SwiftData - Local persistence (system framework, no external dependency)
- SwiftUI - UI framework (system framework)
- CloudKit - Social backend (system framework, currently disabled)
- HealthKit - Health data sync (system framework)

**Infrastructure:**
- UserNotifications - Local push notifications (system framework)
- StoreKit 2 - App Store purchases (system framework)

## Data Models

**Primary Entities** (defined in `HabitLand/Models/Models.swift`):
- Habit - User habit with tracking metadata
- HabitCompletion - Daily completion records with timestamps
- SleepLog - Sleep tracking data (bedtime, wake time, quality, mood)
- UserProfile - User identity, level, XP, bio, avatar
- Achievement - Achievement tracking with unlock status
- Friend - Social connection data
- Challenge - Group challenges between friends
- AppNotification - Local notification records

**Relationships:**
- Habit → HabitCompletion (one-to-many, cascade delete)
- CloudKit records: SocialProfile, FriendRequest, SocialChallenge, ChallengeParticipant, Nudge

## Configuration

**Environment:**
- SwiftData stores in app group container for widget/watch access
- App Group ID: `group.azc.HabitLand`
- Database URL: `{appGroupContainer}/HabitLand.sqlite`

**Build Settings:**
- iOS Deployment Target: 17.0
- Swift Version: 5.0
- Entitlements: App Groups capability
  - Located in: `HabitLand/HabitLand.entitlements`

**Runtime Switches:**
- `-screenshotMode` argument enables demo data seeding
- DEBUG builds support ProManager debug toggle
- CloudKit availability detection at runtime

## Platform Requirements

**Development:**
- Xcode (Apple's IDE)
- iOS 17.0+ SDK
- Swift 5.0 compiler

**Production:**
- Target deployment: iOS 17.0 and later
- iPhone models with iOS 17 support
- watchOS support via HabitLandWatch target
- Widget support via HabitLandWidget extension

**App Store Requirements:**
- Apple Developer Program account (pending for iCloud/HealthKit/Push)
- App Store signing certificates and provisioning profiles

---

*Stack analysis: 2026-03-21*
