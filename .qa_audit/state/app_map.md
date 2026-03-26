# HabitLand App Map — QA Audit v6

## Navigation Structure
- 4 Tabs: Home, Habits, Sleep, Profile
- Social tab REMOVED
- HealthKit REMOVED
- Trial system REMOVED

## Tab 1: Home (HomeDashboardView)
- Daily habit cards with completion toggle
- Streak summary section
- Weekly progress section
- Insights overview
- Getting started card (new users)
- Notifications bell (sheet: NotificationCenterView)
- FAB: Create Habit (sheet: CreateHabitView)
- Habit card tap -> HabitDetailView (push)
  - Edit habit (sheet: EditHabitView)
  - Habit history, statistics, schedule, notes, reminders
- Pomodoro timer (sheet: PomodoroView)
- Habit chain (sheet: HabitChainView)
- Celebration overlay
- Achievement celebration overlay
- Level up overlay
- Streak milestone overlay
- Daily overview (sheet: DailyHabitsOverview)

## Tab 2: Habits (HabitListView)
- Active / Archived filter tabs
- Search bar
- Sort options (Custom, Name, Streak, Category, Newest)
- Free tier banner (non-pro)
- Habit cards -> HabitDetailView (push)
- FAB: Create Habit (sheet: CreateHabitView)
- Free user: FAB opens PaywallView (not alert) when >= 3 active habits
- Paywall (sheet: PaywallView)

## Tab 3: Sleep (SleepDashboardView) [PRO GATED]
- Blurred premium gate for free users (PremiumGateView overlay)
- Last night card
- Weekly chart card
- Average stats row
- Insights card
- Sleep-habit correlation card
- Log Sleep button (sheet: LogSleepView)
- Sleep Analytics (push: SleepAnalyticsView)
- Sleep History (push: SleepHistoryView)
- Sleep Insights (push: SleepInsightsView)

## Tab 4: Profile (UserProfileView)
- Profile header with avatar, name, level
- Edit Profile (push: EditProfileView)
  - Avatar picker (sheet: AvatarPickerView)
- Stats row (Days Active, Completions, Streak, Level)
- Achievements section
- Quick links:
  - Personal Statistics (push or paywall sheet) [PRO GATED]
  - Achievements (push: AchievementsShowcaseView)
  - Settings (push: GeneralSettingsView)
  - Share Profile (ShareLink)
- Settings gear icon (toolbar) -> GeneralSettingsView

## Settings (GeneralSettingsView)
- Upgrade to Pro (sheet: PaywallView) [non-pro only]
- Current plan status
- Edit Profile (push: EditProfileView)
- Manage Subscription (deep link) [pro yearly only]
- Appearance (push: AppearanceSettingsView)
- Habit Settings (push: HabitSettingsView)
- Notifications (push: NotificationSettingsView)
- Data & Export (push: DataExportView)
- Privacy Policy (sheet: LegalView)
- Terms of Use (sheet: LegalView)
- Help Center / Contact Support / Rate HabitLand
- Redeem Promo Code [non-pro only]
- Debug Pro toggle [DEBUG only]
- Version info

## Paywall (PaywallView)
- Feature list
- Plan cards (Yearly, Lifetime)
- Purchase button
- Promo code button
- Restore purchases
- Legal section (Terms, Privacy)

## Onboarding (OnboardingView)
- Step 1: Welcome page (swipe) — "Building habits made fun"
- Step 2: Name entry + avatar picker
- Step 3: Theme selection (ThemeOnboardingView)
- Step 4: Pro offer ("Start Pro" or "Maybe Later")

## Other Screens
- HabitDetailView -> EditHabitView, HabitHistoryView, HabitStatisticsView
- NotificationCenterView, NotificationDetailView
- TemplateBrowserView, HabitDiscoveryView, HabitCategoriesView
- LevelProgressView, RewardsView, AchievementsView
- StreakOverviewView, MilestonesView
- Analytics views (WeeklyAnalyticsView, MonthlyAnalyticsView, etc.)

## Premium Gates
1. Sleep tab — Blurred overlay with "Upgrade to Pro" button
2. Personal Statistics — PRO badge on link, tap opens paywall
3. Habit creation — Free limit is 3, FAB opens paywall (sheet) at limit
4. Settings — "Upgrade to Pro" row visible for free users
