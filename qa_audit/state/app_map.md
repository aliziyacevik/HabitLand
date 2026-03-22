# HabitLand App Map (Updated 2026-03-22)

## Architecture
- SwiftUI + SwiftData (local persistence)
- CloudKit for social features (currently disabled - pending developer account)
- HealthKit integration (pending developer account)
- StoreKit 2 for IAP (pending developer account)

## Tab Navigation (5 tabs via custom TabBarView)

### Tab 1: Home
- `HomeDashboardView` — Daily progress ring, streak card, weekly quests, habit list
  - `→ DailyHabitsOverview` (sheet) — Full habit completion list
  - `→ NotificationCenterView` (sheet) — Notification history
  - `→ CreateHabitView` (sheet via FAB) — Habit creation form
  - `→ PomodoroView` (sheet) — Focus timer with ambient sounds
  - `→ HabitTimerView` (sheet) — Habit timer
  - Embedded: StreakSummaryView, WeeklyProgressView, InsightsOverviewView, HabitChainView

### Tab 2: Habits
- `HabitListView` — Active/Archived filter, search, sort
  - `→ HabitDetailView` (push) — Stats, calendar heatmap, history
    - `→ EditHabitView` (sheet), HabitHistoryView, HabitStatisticsView, HabitScheduleView, HabitNotesView, HabitReminderView
  - `→ CreateHabitView` (sheet) — With template browser, discovery
  - `→ HabitArchiveView` (embedded via filter)

### Tab 3: Sleep (Pro-gated)
- `SleepDashboardView` — Last night card, weekly chart, stats, insights
  - `→ LogSleepView` (sheet), SleepInsightsView, SleepHistoryView, SleepAnalyticsView

### Tab 4: Social (Pro-gated + iCloud-gated)
- `SocialHubView` — Segmented: Friends/Leaderboard/Challenges/Feed
  - Friends: FriendsListView → FriendProfileView, InviteFriendsView
  - Leaderboard: LeaderboardView — Podium + rankings
  - Challenges: SharedChallengesView → CreateChallengeView
  - Feed: SocialFeedView — Activity feed with likes/nudges
  - NudgesSheetView, PendingRequestsView

### Tab 5: Profile
- `UserProfileView` — Avatar, stats, achievements preview
  - EditProfileView, PersonalStatisticsView, AchievementsView
  - GeneralSettingsView → Appearance, Notifications, Privacy, DataExport, HabitSettings
  - PaywallView, LegalView

### Onboarding
- OnboardingView → StarterHabitsView → ThemeOnboardingView → ReferralCodeEntryView

## Totals: 71 screen files, 31 components, 13 services, 8 models
