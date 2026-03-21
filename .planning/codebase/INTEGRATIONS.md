# External Integrations

**Analysis Date:** 2026-03-21

## APIs & External Services

**Apple HealthKit:**
- What: Health and fitness data from Apple Health app
- Location: `HabitLand/Services/HealthKitManager.swift`
- SDK/Client: HealthKit (system framework)
- Auth: User permission prompt at runtime
- Metrics supported:
  - Steps
  - Water intake
  - Exercise minutes
  - Active calories
  - Walking/running distance
  - Stand hours
  - Mindful minutes
  - Sleep hours
- Scope: Read-only, no data written to HealthKit
- Auto-complete: Habits can auto-complete from HealthKit metrics if goal is met
- Implementation: Async queries using HKStatisticsQueryDescriptor and HKSampleQueryDescriptor

**App Store (StoreKit):**
- What: In-app purchases and subscription management
- Location: `HabitLand/Services/ProManager.swift`
- SDK/Client: StoreKit 2 (system framework)
- Auth: Apple ID (via iOS system)
- Products:
  - `com.habitland.pro.yearly` - Annual subscription ($19.99)
  - `com.habitland.pro.lifetime` - One-time purchase ($39.99)
- Configuration: `HabitLand/Configuration.storekit`
- Features:
  - Free trial support (1-week free trial for yearly subscription)
  - Intro offer eligibility checking
  - Purchase verification and transaction finalization
  - Restore purchases from App Store
  - Promo code redemption
- Free tier limits:
  - Max 3 habits (without Pro)
  - Max 5 achievements (without Pro)

## Data Storage

**Databases:**
- SQLite (via SwiftData)
  - Connection: App Group container at `{groupID}/HabitLand.sqlite`
  - App Group ID: `group.azc.HabitLand`
  - Client: SwiftData (system framework ORM)
  - Scope: Local-only (user's device)
  - Models: Habit, HabitCompletion, SleepLog, UserProfile, Achievement, Friend, Challenge, AppNotification

**CloudKit (Public Database):**
- Service: Apple CloudKit
- Container ID: `iCloud.azc.HabitLand`
- Location: `HabitLand/Services/CloudKitManager.swift`
- Status: **Currently disabled** (pending Apple Developer account approval)
- When enabled:
  - Public database for social features (not user's private data)
  - No automatic sync (requires explicit CloudKitManager calls)
  - Record types: SocialProfile, FriendRequest, SocialChallenge, ChallengeParticipant, Nudge
  - User isolation: Records keyed by CloudKit user record ID

**File Storage:**
- None detected - app uses only local database
- Screenshots and UI assets only in bundle

**Caching:**
- None - relies on in-memory SwiftUI @State/@Published and SwiftData cache

## Authentication & Identity

**Auth Provider:**
- CloudKit User ID (when CloudKit enabled)
  - No traditional auth service
  - Uses device iCloud account for identity
  - Implementation: `CKContainer.userRecordID()`
  - Location: `HabitLand/Services/CloudKitManager.swift:fetchCurrentUser()`

**Local User Profile:**
- Stored in SwiftData as UserProfile model
- Contains: name, username, avatar emoji, bio, level, XP
- Per-device identity (not synced across devices currently)

## Monitoring & Observability

**Error Tracking:**
- None detected - no external error tracking service integrated
- Local error logging to console via print statements

**Logs:**
- Console logging only
- Locations using logging: CloudKitManager, HealthKitManager, NotificationManager, ProManager

**Debug Logging:**
- Screenshot mode logging in HabitLandApp.swift
- No production analytics or telemetry detected

## CI/CD & Deployment

**Hosting:**
- Apple App Store (deployment target)

**CI Pipeline:**
- None detected (no GitHub Actions, FastLane, or build server config)
- Manual build via Xcode

**Build System:**
- Xcode project file: `HabitLand.xcodeproj`
- Targets:
  - HabitLand (main app)
  - HabitLandTests (unit tests)
  - HabitLandUITests (XCUITest UI tests)
  - HabitLandWidget (iOS widget extension)
  - HabitLandWatch (watchOS app)

## Environment Configuration

**Required Environment Variables:**
- None detected in codebase
- Configuration via:
  - UserDefaults (e.g., onboarding flag, notification prefs, Pro status)
  - StoreKit Configuration.storekit for products
  - CloudKit container identifier (hardcoded in code)
  - App Group identifier (hardcoded in code)

**Configuration at Build Time:**
- Entitlements file: `HabitLand/HabitLand.entitlements`
  - App Groups: `group.azc.HabitLand`
- StoreKit config: `HabitLand/Configuration.storekit`
  - Local-only test configuration

**Secrets Location:**
- Apple Developer Team ID: Hardcoded in entitlements and xcodeproj (not sensitive)
- CloudKit container: Hardcoded as string literal
- No API keys or tokens in codebase

## Webhooks & Callbacks

**Incoming:**
- None - app is client-only

**Outgoing:**
- CloudKit subscriptions: None detected
- Push notifications: Outgoing to APNS (Apple Push Notification service) via UNUserNotificationCenter
  - Configured by NotificationManager
  - Local-only (not server-driven)

## System Integrations

**HomeScreen & Widgets:**
- Quick Actions: 3 home screen quick actions
  - Add Habit
  - Today's Progress
  - Log Sleep
- Implementation: `HabitLandApp.swift:setupQuickActions()`

**Notification Center:**
- Local notifications via UserNotifications framework
- No remote push notifications

**Status Bar & System UI:**
- App extension: HabitLandWidget for lock screen/home screen widget
- Watch app: HabitLandWatch for watchOS
- Shared model container for data access across targets

**Entitlements Required:**
- App Groups - for sharing data with extensions
- iCloud CloudKit Container (when enabled)
- HealthKit read access
- Microphone/Camera - Not requested (see Privacy.xcprivacy)

## Apple Health Integration Patterns

**Sync Flow:**
1. On app launch or explicit sync: `HealthKitManager.syncHealthHabits()`
2. Query today's value for each HealthKit-linked habit
3. Compare against habit goal
4. Auto-complete habit if goal met
5. Location: `HabitLandApp.swift:syncHealthKitHabits()`

**Authorization:**
- Permission request per metric group
- User can deny any metric
- Per-app authorization managed by iOS
- Location: `HabitKitManager.requestAuthorization(for:)`

## Social Features (CloudKit)

**When CloudKit is enabled:**

**Friend Management:**
- Search users by username (public database query)
- Send/receive friend requests
- Accept/decline requests
- Sync friend stats (level, streak, XP, last active)

**Social Challenges:**
- Create group challenges
- Invite friends to challenges
- Track challenge participation
- Update progress

**Messages (Nudges):**
- Send direct nudges to friends
- Fetch unread nudges
- Mark nudges as read

**Leaderboard:**
- Fetch leaderboard data for friends + user
- Sort by XP
- Display in friend list

**Implementation Details:**
- All CloudKit operations in `HabitLandApp/Services/CloudKitManager.swift`
- Public database only (no private sync)
- Manual sync (not automatic background sync)
- Status: Disabled pending developer account

---

*Integration audit: 2026-03-21*
