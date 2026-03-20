# HabitLand App Map

## Architecture
- SwiftUI + SwiftData (local persistence)
- No networking/API layer — fully offline app
- StoreKit 2 for IAP (Pro tier)
- Local notifications via UNUserNotificationCenter
- State: @Query, @AppStorage, singletons (ProManager, ThemeManager, NotificationManager)

## Tab Structure (ContentView.swift)
| Tab | Screen | Gated |
|-----|--------|-------|
| Home | HomeDashboardView | No |
| Habits | HabitListView | No |
| Sleep | SleepDashboardView | Pro (premiumGated) |
| Social | FriendsListView | Pro + Coming Soon |
| Profile | UserProfileView | No |

## Screens Inventory

### Onboarding (5 screens)
- OnboardingView (4-page TabView carousel)
- StarterHabitsView (habit selection)
- GoalSetupView
- HabitPreferenceView
- NotificationSetupView
- OnboardingCompleteView

### Auth (3 screens — UI only, no backend)
- LoginView
- RegisterView
- ForgotPasswordView

### Home (5 screens)
- HomeDashboardView (main dashboard)
- DailyHabitsOverview (sheet)
- WeeklyProgressView (sheet)
- InsightsOverviewView (sheet)
- StreakSummaryView

### Habits (10 screens)
- HabitListView (main list with search/sort/filter)
- HabitDetailView (detail with calendar heatmap)
- CreateHabitView (sheet)
- EditHabitView (sheet)
- HabitHistoryView
- HabitStatisticsView
- HabitArchiveView
- HabitScheduleView
- HabitNotesView
- HabitReminderView

### Sleep (5 screens)
- SleepDashboardView
- LogSleepView (sheet)
- SleepHistoryView
- SleepAnalyticsView
- SleepInsightsView

### Gamification (5 screens)
- AchievementsView
- StreakOverviewView
- LevelProgressView
- RewardsView
- MilestonesView

### Social (6 screens — all behind Pro + Coming Soon)
- FriendsListView
- LeaderboardView
- FriendProfileView
- InviteFriendsView
- SharedChallengesView
- SocialFeedView

### Profile (4 screens)
- UserProfileView
- EditProfileView
- PersonalStatisticsView
- AchievementsShowcaseView

### Premium (3 screens)
- PremiumGateView (gate overlay)
- PaywallView (IAP sheet)
- LegalView

### Notifications (3 screens)
- NotificationCenterView
- NotificationDetailView
- ReminderSettingsView

### Settings (6 screens)
- GeneralSettingsView
- AppearanceSettingsView
- HabitSettingsView
- NotificationSettingsView
- PrivacySettingsView
- DataExportView

### Analytics (5 screens)
- WeeklyAnalyticsView
- MonthlyAnalyticsView
- HabitSuccessTrendsView
- HabitDifficultyInsightsView
- LongTermProgressView

### Discovery (3 screens)
- HabitDiscoveryView
- HabitCategoriesView
- RecommendedHabitsView

## Models (SwiftData)
- Habit, HabitCompletion, SleepLog, UserProfile, Achievement, Friend, Challenge, AppNotification

## Services
- ProManager (StoreKit IAP)
- ThemeManager (appearance/accent)
- AchievementManager (unlock checks)
- NotificationManager (local notifications)
- ReviewManager (SKStoreReviewController)

## Total Screens: ~63
