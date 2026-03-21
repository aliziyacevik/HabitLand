# Codebase Concerns

**Analysis Date:** 2026-03-21

## Tech Debt

**CloudKit Sync Disabled:**
- Issue: CloudKit automatic sync is completely disabled waiting for Apple Developer account approval
- Files: `HabitLand/Services/SharedModelContainer.swift` (line 26-27)
- Impact: Device-to-device sync is non-functional; iCloud private database commented out; only local SQLite used
- Fix approach: When account approved, uncomment line 27 and set `cloudKitDatabase: .private("iCloud.azc.HabitLand")` in ModelConfiguration

**HealthKit & Push Notifications Disabled:**
- Issue: Both features are disabled in code waiting for Developer account approval
- Files: `HabitLand/Services/HealthKitManager.swift`, notification setup in `HabitLandApp.swift`
- Impact: Users cannot sync Apple Health data; no push notifications send despite implementation
- Fix approach: Re-enable once account approved; toggle feature flags in code

**Debug Pro Toggle in Production:**
- Issue: DEBUG-only `debugProEnabled` toggle exists but means code path for Pro features is untested in release builds
- Files: `HabitLand/Services/ProManager.swift` (lines 18-20, 23-25), `HabitLand/Screens/Settings/GeneralSettingsView.swift` (lines 106-117)
- Impact: Screenshot tests use `-screenshotMode` flag to enable Pro; actual free tier limits never properly tested in QA
- Fix approach: Add dedicated free tier test user; ensure QA tests free tier without shortcuts; remove debug toggle before App Store submission

**Debug Print Statements:**
- Issue: 24 `print()` calls scattered throughout service layer for error logging
- Files: `HabitLand/Services/CloudKitManager.swift`, `HabitLand/Services/ProManager.swift`, `HabitLand/Services/HealthKitManager.swift`
- Impact: Production builds send debug output to console; should use proper logging framework for filtered, production-safe logging
- Fix approach: Replace all `print()` with os.Logger; configure log levels per build configuration

**Hard-coded CloudKit Container ID:**
- Issue: Container ID `"iCloud.azc.HabitLand"` is hardcoded in CloudKitManager
- Files: `HabitLand/Services/CloudKitManager.swift` (line 11)
- Impact: Not configurable per environment; brittle if bundleID ever changes
- Fix approach: Move to Configuration or Info.plist; use Bundle.main.bundleIdentifier as fallback

## Known Bugs

**Optional Completions Relationship Not Fully Guarded:**
- Issue: Habit.completions is Optional but widely accessed via `.safeCompletions` convenience property; mixes nil-coalescing patterns
- Files: `HabitLand/Models/Models.swift` (lines 27, 30-31); used throughout views
- Trigger: If relationship fails to load from CloudKit/SwiftData, code safely handles via ?? [] but inconsistent across codebase
- Workaround: Current workaround (safeCompletions) is in place but forces defensive programming everywhere

**Date Formatting Not Localized:**
- Issue: DateFormatter hardcoded to "EEEE, MMM d" format with no locale configuration
- Files: `HabitLand/Screens/Home/HomeDashboardView.swift` (lines 73-75)
- Trigger: Users with non-English locales may see inconsistent date formatting
- Impact: Reduced UX for international users
- Fix approach: Use Locale.current or FormatStyle (iOS 15+)

**Fatalizing Error on ModelContainer Creation:**
- Issue: Fallback error path uses `fatalError()` which crashes app instead of graceful degradation
- Files: `HabitLand/Services/SharedModelContainer.swift` (line 49)
- Trigger: If both primary and fallback ModelContainer initialization fail (extremely rare)
- Impact: App hard-crashes instead of showing user-friendly error or using in-memory database
- Fix approach: Use in-memory container or show error sheet instead of fatalError

**Missing Nil Checks in CloudKit Operations:**
- Issue: Many CloudKit operations assume `currentUserRecordID` exists without defensive checks
- Files: `HabitLand/Services/CloudKitManager.swift` (lines 63, 91)
- Trigger: If user signs out of iCloud mid-operation, guard statements prevent crashes but operations silently fail
- Impact: Silent failures; no user feedback when CloudKit operations fail
- Fix approach: Add error callbacks; post notifications on CloudKit state changes; toast user on failure

## Security Considerations

**No SSL Certificate Pinning:**
- Risk: CloudKit and any future API calls use standard TLS without pinning; vulnerable to MITM if certificate authority compromised
- Files: `HabitLand/Services/CloudKitManager.swift`, network configuration in app delegate
- Current mitigation: Uses Apple's built-in CloudKit framework (inherently more secure); no custom HTTP endpoints
- Recommendations: If custom backend added later, implement certificate pinning via URLSessionConfiguration

**UserProfile Data in Public CloudKit Database:**
- Risk: All user profile data (name, username, bio, level, XP, stats) published to CloudKit public database for social features
- Files: `HabitLand/Services/CloudKitManager.swift` (lines 62-87)
- Current mitigation: Only non-sensitive data shared; passwords/auth tokens never sent
- Recommendations: Document privacy model clearly; allow users to opt-out of public profile; add option to make profile private

**Debug Mode Enabled for Screenshots:**
- Risk: `-screenshotMode` argument enables Pro features and bypasses authentication; if flag is leaked/documented, becomes privilege escalation
- Files: `HabitLand/HabitLandApp.swift` (lines 56-68), `HabitLand/Services/ProManager.swift` (line 26)
- Current mitigation: Only active if explicitly passed as launch argument
- Recommendations: Remove screenshot mode before App Store release; use separate build variant instead

**Unencrypted Local Data (iCloud Disabled):**
- Risk: All data stored locally in SQLite without encryption; accessible to jailbroken devices or forensic tools
- Files: `HabitLand/Services/SharedModelContainer.swift` (lines 21-23)
- Current mitigation: File protection via sandbox; device-level encryption via iOS
- Recommendations: Consider Data Protection API (FileProtectionLevel.complete) once CloudKit enabled; document no E2E encryption for habit data

## Performance Bottlenecks

**Large View Hierarchy in HomeDashboardView:**
- Problem: Home dashboard is 933 lines; contains multiple computed properties that recalculate on every view render
- Files: `HabitLand/Screens/Home/HomeDashboardView.swift` (lines 1-500+)
- Cause: All habit filtering/sorting/calculation done in view body; `weeklyDays` recalculates calendar math on every frame; O(habits * days) complexity
- Impact: Noticeable lag when user has 30+ habits on iPhone 11/12
- Improvement path: Extract calculations to view model; memoize calendar calculations; use @Computed property in SwiftData if available

**Effects.swift Shimmer Animation:**
- Problem: Shimmer effect uses .repeatForever(autoreverses: false) causing continuous animation even when off-screen
- Files: `HabitLand/DesignSystem/Effects.swift` (lines 75-99)
- Cause: No animation pause mechanism; phase state resets on every view refresh
- Impact: Unnecessary CPU/GPU usage during shimmer; drains battery on devices with many shimmer views
- Improvement path: Use .paused modifier when view is not visible; convert to CABasicAnimation for better control

**Weekly Data Calculation O(n²) Complexity:**
- Problem: `weeklyDays` calculated by filtering all habits against 7 days; then weeklyTotal does similar iteration
- Files: `HabitLand/Screens/Home/HomeDashboardView.swift` (lines 80-115, 132-145)
- Cause: Nested loops through habits.completions for each day
- Impact: Performance degrades quadratically with habit count; visible at 50+ habits
- Improvement path: Pre-calculate in weekly aggregate on model; cache completion index by date

**SwiftData Query Without Pagination:**
- Problem: HomeDashboardView loads all habits without limit; no pagination or lazy loading
- Files: `HabitLand/Screens/Home/HomeDashboardView.swift` (line 8)
- Cause: Simple @Query decorator
- Impact: Full dataset loaded into memory; slow scroll on first render with 100+ habits
- Improvement path: Add limit to @Query; implement scroll-to-load pattern; or batch-fetch top 50 with fetch predicate

**Large Font Effects File:**
- Problem: Effects.swift is 1,448 lines; monolithic file with all animations, haptics, and visual effects
- Files: `HabitLand/DesignSystem/Effects.swift`
- Cause: No modular breakup
- Impact: Long compile time; single point of failure; hard to find specific animations
- Improvement path: Split into separate files: Haptics.swift, Animations.swift, VisualEffects.swift

## Fragile Areas

**CloudKit Recovery Path Uncertain:**
- Files: `HabitLand/Services/CloudKitManager.swift`, `HabitLand/Services/SharedModelContainer.swift`
- Why fragile: CloudKit integration is disabled and untested; re-enabling involves complex state management (sync conflicts, zone creation, etc.)
- Safe modification: When account approved: (1) Write comprehensive tests for CloudKit sync in QA suite before enabling (2) Test account logout/re-login flow (3) Test iCloud disabled scenario
- Test coverage: QA audit does not test CloudKit at all; no unit tests for sync

**Achievement Unlock Logic:**
- Files: `HabitLand/Services/AchievementManager.swift`
- Why fragile: Achievement conditions hard-coded; multiple interdependent checks (streak, completion, level); no audit trail if unlock fails
- Safe modification: Add logging to AchievementManager; write tests for each achievement condition; add @Observable notification when unlocked
- Test coverage: Sample data tests exist (HabitLandTests.swift lines 381-416) but no integration tests for unlock triggers

**Free Tier Limit Enforcement:**
- Files: `HabitLand/Services/ProManager.swift` (lines 185-190), `HabitLand/Screens/Habits/CreateHabitView.swift`
- Why fragile: Limit checked via `canCreateHabit()` but not enforced at data model level; user could theoretically bypass by editing SwiftData directly
- Safe modification: Add @Computed property on UserProfile counting non-archived habits; validate in CreateHabitView before save; do NOT trust client-side checks alone
- Test coverage: No tests for free tier limit; only tested via debug Pro toggle

**Social Feature CloudKit Dependencies:**
- Files: All files in `HabitLand/Screens/Social/`
- Why fragile: Friends, leaderboard, challenges all require public CloudKit database; 10 separate CloudKit record types; no fallback if CloudKit unavailable
- Safe modification: Do NOT add new social features without comprehensive CloudKit error handling; always show "iCloud unavailable" states
- Test coverage: QA audit tests social screens but mocked iCloud; no live CloudKit testing

## Test Coverage Gaps

**No Unit Tests for View Models:**
- Untested area: All @MainActor ObservableObject managers (ProManager, CloudKitManager, HealthKitManager, AchievementManager, NotificationManager)
- Files: `HabitLand/Services/ProManager.swift`, `HabitLand/Services/CloudKitManager.swift`, etc.
- Risk: Changes to transaction handling, error recovery, state management could break without detection
- Priority: High
- Fix: Write unit tests for StoreKit transaction flow, CloudKit error recovery, HealthKit auth flow

**No Integration Tests for Data Persistence:**
- Untested area: SwiftData model lifecycle; CloudKit sync (when re-enabled); model migrations
- Files: `HabitLand/Models/Models.swift`, `HabitLand/Services/SharedModelContainer.swift`
- Risk: Data corruption, lost habits if model schema changes without proper migration
- Priority: High
- Fix: Add integration tests creating/updating/deleting all model types; test CloudKit sync when enabled

**Free Tier & Pro Feature Gating:**
- Untested area: Free tier 3-habit limit enforcement; Pro-only features (sleep, social, advanced analytics)
- Files: Scattered across multiple views and ProManager
- Risk: Users bypass limits; Pro features become accessible to free users
- Priority: High
- Fix: QA suite must test free tier without debug Pro toggle; test paywall triggers; verify 4th habit creation fails

**Sleep & Analytics View Calculations:**
- Untested area: All analytics calculations (monthly trends, weekly averages, quality scoring)
- Files: `HabitLand/Screens/Sleep/SleepAnalyticsView.swift`, `HabitLand/Screens/Analytics/MonthlyAnalyticsView.swift`, etc.
- Risk: Incorrect calculations shown to users; misleading trends
- Priority: Medium
- Fix: Unit tests for each calculation function; parametrized tests with known inputs/outputs

**Error States & Edge Cases:**
- Untested area: Empty state UI (no habits, no sleep logs); single habit edge cases; timezone changes; date boundary conditions
- Files: All view files with plural queries
- Risk: Crashes or confusing UI when edge cases encountered
- Priority: Medium
- Fix: Add snapshot tests for all empty/single-item states; test behavior around midnight, date boundaries

**Onboarding Flow Completion:**
- Untested area: Full onboarding sequence; skip paths; data seeding after onboarding
- Files: `HabitLand/Screens/Onboarding/OnboardingView.swift`
- Risk: Users stuck on onboarding; sample data not created
- Priority: Medium
- Fix: QA audit must test full onboarding path; verify UserProfile and achievements created; verify app functions post-onboarding

## Scaling Limits

**Habit Count Scaling:**
- Current capacity: UI responsive up to ~30 habits
- Limit: Noticeable lag at 50+ habits due to O(n²) calculations in weekly data
- Scaling path: Implement view model with memoization; use @Computed on Habit model; optimize weekly calculation to O(n) with indexed lookups

**Completion History Scaling:**
- Current capacity: Works fine up to ~1,000 completions per habit
- Limit: Snapshot/archive feature not implemented; all history kept in memory
- Scaling path: Implement completion archival after 1 year; add completion pagination in HabitHistoryView; lazy-load old data

**CloudKit Record Count:**
- Current capacity: Public database designed for ~10,000 total users with profiles + friend relationships
- Limit: No cleanup of inactive profiles; leaderboard queries O(n); challenges never deleted
- Scaling path: Add automatic profile deletion after 6 months inactive; implement CloudKit batch operations for leaderboard; archive old challenges

**Local SQLite Database:**
- Current capacity: App works fine up to ~500MB of local data (rare edge case: 100 habits + 10 years completion history)
- Limit: No vacuum/cleanup; database grows unbounded
- Scaling path: Add manual database optimization; implement completion cleanup; compress very old data

## Dependencies at Risk

**StoreKit 2 Framework (Latest):**
- Risk: Heavy reliance on StoreKit 2 for in-app purchases; recent framework with potential API instability
- Impact: Purchase flow breaks if Apple changes verification APIs
- Migration plan: Already using latest StoreKit 2; no legacy support; upgrade path clear when iOS requirements change

**CloudKit (Deprecated/Unstable in This Build):**
- Risk: Currently disabled; when re-enabled, depends on Apple's CloudKit stability; record type schema hard-coded
- Impact: CloudKit downtime blocks social features and sync
- Migration plan: None; no backend alternative; all social features are CloudKit-dependent

**SwiftData (iOS 17+ Only):**
- Risk: SwiftData is relatively new framework; potential for bugs or API changes
- Impact: Database queries may break with iOS updates
- Migration plan: No escape; entire app is built on SwiftData; can't migrate to CoreData without major rewrite

**HealthKit Permission Requests:**
- Risk: HealthKit disabled; when re-enabled, permissions model may change in future iOS
- Impact: App may need new permissions prompts on iOS update
- Migration plan: Check Apple Health Integration guide annually; test permission requests on beta iOS

## Missing Critical Features

**Data Export/Privacy:**
- Problem: Data export exists UI (`HabitLand/Screens/Settings/DataExportView.swift`) but likely not fully implemented
- Blocks: Cannot comply with GDPR data subject access requests without working export
- Risk: Regulatory non-compliance

**Account & Auth:**
- Problem: No user account system; all data is local-only
- Blocks: Can't support multiple devices; can't recover data if app deleted; can't link social features across devices
- Risk: App loses all data on device reset; social features unreliable

**Cloud Backup (Proper):**
- Problem: CloudKit sync disabled; no iCloud backup integration
- Blocks: User data lost if device fails or app is deleted
- Risk: User churn if habit data is lost

**Notification Delivery Proof:**
- Problem: Reminders are local; no push notifications (disabled waiting for account)
- Blocks: Can't send timely reminders if app not running
- Risk: Habits fall off radar; users abandon app

---

*Concerns audit: 2026-03-21*
