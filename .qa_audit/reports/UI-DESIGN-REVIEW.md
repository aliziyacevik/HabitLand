# UI/UX Design Review

**Date:** 2026-03-24
**Project:** HabitLand
**Screens Analyzed:** 65 SwiftUI view files across 11 feature domains
**Screenshots Reviewed:** 40 PNG screenshots (21 unique screens visible; 19 showed wrong screens due to XCUITest navigation issues)
**Previous Review:** N/A

---

## Overall Score: 31/40 -- Grade: B

| Grade | Range |
|-------|-------|
| A | 36-40 |
| B | 30-35 |
| C | 24-29 |
| D | 18-23 |
| F | <18 |

---

## Pillar Summary

| Pillar | Score |
|--------|-------|
| Visual Hierarchy | 4/5 |
| Color & Theme | 4/5 |
| Typography | 4/5 |
| Spacing & Layout | 4/5 |
| Copywriting & UX Writing | 4/5 |
| Interaction Design | 4/5 |
| HIG Compliance | 4/5 |
| Accessibility | 3/5 |
| **Overall** | **31/40** |

---

## Domain Scores

| Domain | VH | C&T | Typo | S&L | Copy | IX | HIG | A11y | Avg |
|--------|----|-----|------|-----|------|----|-----|------|-----|
| Home | 4 | 4 | 4 | 4 | 5 | 4 | 4 | 3 | 4.0 |
| Habits | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 3.9 |
| Sleep | 4 | 5 | 4 | 4 | 4 | 4 | 4 | 3 | 4.0 |
| Social | 4 | 4 | 4 | 4 | 4 | 3 | 4 | 3 | 3.8 |
| Profile | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 3.9 |
| Settings | 3 | 4 | 4 | 4 | 4 | 4 | 5 | 3 | 3.9 |
| Onboarding | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 3.9 |
| Premium | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 3 | 3.9 |
| Analytics | 4 | 4 | 4 | 4 | 3 | 3 | 4 | 3 | 3.6 |
| Discovery | 4 | 4 | 4 | 4 | 4 | 3 | 4 | 3 | 3.8 |
| Notifications | 3 | 4 | 4 | 4 | 4 | 3 | 4 | 3 | 3.6 |

---

## Top 5 Quick Wins

1. **Add Dynamic Type support** -- Zero usage of `.dynamicTypeSize()` environment across the entire app. Adding `@Environment(\.dynamicTypeSize)` checks for layout adaptations at accessibility sizes would dramatically improve accessibility for a small code change.

2. **Add `.minimumScaleFactor(0.75)` to stat labels** -- The "33d Streak", "0/3 Quests", "90% This Week" labels on the home dashboard and similar stat displays across Profile, Sleep, and Social would truncate at larger dynamic type sizes. Only 21 occurrences of `minimumScaleFactor` across 9 files; should be 60+ across all stat cards.

3. **Replace placeholder emoji icons in Sleep History/Log Sleep** -- The sleep quality/mood icons show as "?" placeholders in screenshots (03_log_sleep_form.png, 03_sleep_history.png). Either the SF Symbol names are wrong or the emojis are not rendering. This is immediately visible to every user of the Sleep tab.

4. **Add VoiceOver labels to chart components** -- The weekly sleep chart (03_sleep_dashboard.png), bar charts in analytics, and circular progress ring have no `.accessibilityLabel()` on chart bars/data points. Screen reader users get no data from these visuals.

5. **Add `.accessibilityHidden(true)` to remaining decorative icons** -- 54 occurrences of `.accessibilityHidden(true)` is good but many decorative icons in Settings rows (crown, gear, bell icons), Social friend cards (flame icons for streak), and Analytics views still lack this modifier.

## Top 5 Major Improvements

1. **Implement Dynamic Type layout adaptation** -- When Dynamic Type is set to Accessibility XL, the three-column stat rows (Home dashboard "33d / 0/3 / 90%", Sleep "7.4h / 76% / 100%", Profile stats "42 / 210 / Lvl 12") will overflow horizontally. These should switch to a 2x2 or vertical stack layout at larger text sizes using `@Environment(\.dynamicTypeSize)`.

2. **Reduce `.font(.system(size:))` usage** -- 298 occurrences of hardcoded `.font(.system(size: N))` across 83 files. While most are wrapped with `min()` caps from `@ScaledMetric`, the pattern itself bypasses the `HLFont` design system. Icon sizes are appropriately using `@ScaledMetric`, but the `min()` caps (e.g., `min(flameSize, 16)`) create a ceiling that limits scaling for users who need larger text. Consider removing or raising the caps.

3. **Add loading/error states to Social and Analytics** -- The Leaderboard, Social Feed, and Analytics views fetch data but show no loading skeleton or spinner during fetch. The empty states are well-designed (e.g., "No challenges yet" with CTA), but the transition from loading to loaded has no intermediate visual state.

4. **Improve contrast for secondary text elements** -- `hlTextTertiary` in dark mode is #6E6E73 on #1C1C1E background, which yields approximately 3.2:1 contrast ratio -- below the WCAG AA minimum of 4.5:1 for normal text. This affects timestamps, subtle labels, and inactive tab bar items.

5. **Add pull-to-refresh to more screens** -- Only 5 screens have `.refreshable` (Home, Habits List, Sleep Dashboard, Social Hub, Profile). Sub-screens like Sleep History, Sleep Analytics, Leaderboard, Personal Statistics, and Achievements should also support pull-to-refresh for data freshness.

---

## Detailed Findings by Pillar

### 1. Visual Hierarchy (4/5)

The app demonstrates strong visual hierarchy overall. The home dashboard has a clear focal point with the 80% circular progress ring drawing the eye immediately. Cards are well-grouped with consistent use of the `.hlCard()` modifier. The level bar (LV8 with XP progress) creates a strong top-to-bottom reading flow.

### Visual Hierarchy -- Major

**Problem:** HomeDashboardView.swift -- The "Focus Timer" and "Track to Transform" cards at the bottom of the home screen have equal visual weight, making neither stand out. Both use the same card style with icon + text layout.

**Impact:** Users may miss the Focus Timer feature since it blends in with the motivational tip card below it.

**Fix:** Give the Focus Timer card a slight accent background tint or a colored left border to distinguish interactive features from static content cards. The play button (orange circle) helps but the surrounding card style matches everything else.

### Visual Hierarchy -- Minor

**Problem:** SocialHubView.swift -- The segment picker (Friends / Leaderboard / Challenges / Feed) uses a horizontally scrolling pill-style selector. On the Challenges tab, the empty state pushes below the fold with no visual anchor near the segment picker.

**Impact:** The large gap between the segment picker and "No challenges yet" content feels disconnected.

**Fix:** Reduce the top padding of the empty state or add a subtle divider below the segment picker to create visual continuity.

### Visual Hierarchy -- Minor

**Problem:** NotificationCenterView.swift (01_notifications.png) -- The empty notification screen has a centered icon and text but no visual weight at the top. The "Notifications" title is left-aligned in large title style while the empty state is centered, creating a split visual axis.

**Impact:** The screen feels sparse and disconnected. Users may think the app is broken.

**Fix:** Consider adding a subtle illustration or a more prominent empty state with a suggested action like "Enable notifications" or a link back to settings.

---

### 2. Color & Theme (4/5)

The color system is well-implemented with a comprehensive palette. The emerald/green primary with orange flame accents follows a clear hierarchy. Semantic colors are correctly applied (red for errors, green for success, purple for sleep). The 60/30/10 rule is generally followed with hlBackground (60%), hlSurface cards (30%), and hlPrimary accents (10%).

### Color & Theme -- Major

**Problem:** Theme.swift:43-47 -- `hlTextTertiary` uses the same hex value (#737380) for both light and dark modes, while `hlTextSecondary` uses different values. In dark mode, `hlTextTertiary` (#6E6E73) on `hlSurface` (#1C1C1E) yields approximately 3.2:1 contrast.

**Impact:** Tertiary text (timestamps, inactive states, tab bar labels) may be difficult to read in dark mode for users with low vision.

**Fix:** Lighten `hlTextTertiary` dark mode value to at least #8E8E93 (matching iOS system gray 2) to achieve 4.5:1 contrast ratio.

### Color & Theme -- Minor

**Problem:** LeaderboardView (04_leaderboard.png) -- The #1 podium position uses a yellow/gold background that has low contrast with the white text/numbers inside. The #2 and #3 positions use lighter tints that work better.

**Impact:** The most important ranking position has the weakest text readability.

**Fix:** Darken the gold background slightly or use dark text on the gold podium to improve contrast.

### Color & Theme -- Minor

**Problem:** Sleep domain uses purple (`hlSleep`: #665ACC) consistently, but the "Log Sleep" CTA button uses `hlPrimary` (green) instead of the sleep accent color, creating a visual disconnect.

**Impact:** The green CTA on the purple-themed sleep dashboard breaks the color story.

**Fix:** Consider using `hlSleep` for the Log Sleep CTA to maintain the sleep domain's visual identity, or keep green if the intent is to make all primary CTAs consistent app-wide. Either approach is valid but should be a deliberate choice.

---

### 3. Typography (4/5)

The typography system is excellent. `HLFont` provides a comprehensive set of text styles using `.rounded` design consistently. The hierarchy from `largeTitle` down to `caption2` is clear and well-used across screens. Font weights are appropriately limited (regular, medium, semibold, bold).

### Typography -- Major

**Problem:** Multiple files -- The `@ScaledMetric` pattern for icon sizes is applied extensively (excellent), but the `min()` caps create inconsistent scaling behavior. For example, `min(flameSize, 16)` in HabitCard.swift:103 means the flame icon stops scaling at 16pt regardless of user preference.

**Impact:** Users who set larger Dynamic Type sizes will see text scale but icons will hit their caps and stop, creating visual misalignment between text and icons.

**Fix:** Raise `min()` caps by 50% (e.g., `min(flameSize, 24)` instead of 16) or remove caps for icons that are purely decorative. Keep caps only for icons that would break layout at extreme sizes.

### Typography -- Minor

**Problem:** PomodoroView (01_pomodoro.png) -- The "25:00" timer display appears to use a large system font. The "Session 1 of 4" subtitle and "Focus" label are well-sized, but the timer digits could benefit from a monospaced design to prevent layout shifts as digits change.

**Impact:** During countdown, the timer width will fluctuate slightly as digits change (e.g., "25:00" vs "11:11") causing subtle visual jitter.

**Fix:** Use `.monospacedDigit()` modifier on the timer display font: `.font(HLFont.display()).monospacedDigit()`.

---

### 4. Spacing & Layout (4/5)

Spacing is remarkably consistent across the app. The 8-point grid system (`HLSpacing`) is used extensively (3,428 design system token references across 109 files). Hardcoded padding values are minimal (12 occurrences in 8 files). Cards have consistent internal padding via `.hlCard()`.

### Spacing & Layout -- Major

**Problem:** HomeDashboardView.swift -- The home dashboard has 12+ hardcoded `padding()` values alongside `HLSpacing` usage. At lines where stat cards (33d Streak / 0/3 Quests / 90% This Week) are arranged in a horizontal 3-column layout, there is no adaptive layout for larger text sizes.

**Impact:** At Accessibility XL text sizes, the three stat values will horizontally overflow or truncate.

**Fix:** Use a `ViewThatFits` or `@Environment(\.dynamicTypeSize)` check to switch from HStack to a 2-column or VStack layout when text size exceeds `.accessibility1`.

### Spacing & Layout -- Minor

**Problem:** CreateChallengeView (04_create_challenge.png) -- The "Create Challenge" button at the bottom appears partially obscured by the home indicator safe area. The gray background behind the button suggests it may not have proper bottom padding.

**Impact:** The primary CTA is partially hidden, reducing discoverability.

**Fix:** Ensure the Create Challenge button has `.padding(.bottom, HLSpacing.xxxl)` or is placed in a sticky footer with safe area inset handling.

### Spacing & Layout -- Minor

**Problem:** SleepHistoryView (03_sleep_history.png) -- Sleep log entries use consistent card spacing, but the bottom of the list gets cut off by the tab bar. The last entry ("Thursday, Mar 19 - 7h 30m") is partially visible.

**Impact:** Users may not realize there is more content below.

**Fix:** Add `.padding(.bottom, HLSpacing.xxxl)` to the ScrollView content to ensure the last item clears the tab bar.

---

### 5. Copywriting & UX Writing (4/5)

The app's copy is generally strong. Empty states are motivating ("No challenges yet -- Create a challenge and invite friends to stay accountable together"), CTAs are specific ("Create Challenge", "Log Sleep", "Share Invite Link"), and the tone is encouraging throughout.

### Copywriting & UX Writing -- Minor

**Problem:** HomeDashboardView.swift -- The "Track to Transform" motivational card uses generic copy: "What gets measured gets managed. Tracking habits makes you 2x more likely to succeed." This reads like a textbook quote, not a personal message.

**Impact:** After seeing this card daily, users will start ignoring it. It does not provide personalized value.

**Fix:** Make this card contextual: show a tip relevant to the user's current habits (e.g., "Your Morning Meditation streak is 33 days -- that's in the top 5% of HabitLand users!") or rotate through fresh tips. If dynamic content is not feasible, add a dismiss option.

### Copywriting & UX Writing -- Minor

**Problem:** InviteFriendsView (04_invite_friends.png) -- The referral code "HBT-3VJYVW" is displayed prominently but "Share your code, we both get 1 week of Pro!" uses "we" which feels impersonal. The "0 Friends Invited / 0 Weeks Pro" counters are discouraging for new users.

**Impact:** Showing zero counters creates negative social proof. The copy could be warmer.

**Fix:** When counters are zero, show encouraging copy instead: "Invite your first friend to unlock a free week of Pro!" rather than displaying "0".

### Copywriting & UX Writing -- Minor

**Problem:** SleepDashboardView -- The "Sleep & Habits" correlation card shows "85% Good sleep days / 93% Poor sleep days" (03_sleep_scrolled.png). Showing that habits are 93% consistent on poor sleep days is confusing -- it is unclear whether this is good or bad.

**Impact:** Users cannot interpret whether the data is positive or negative without context.

**Fix:** Add interpretive labels: "Your habits stay strong even when sleep is poor -- impressive discipline!" or use color coding (green for the positive metric, neutral for the comparison).

---

### 6. Interaction Design (4/5)

Interaction design is solid. The app uses haptic feedback extensively via `HLHaptics` (light, medium, heavy, success, selection, completionSuccess, achievementUnlocked). The undo toast for habit completion is a thoughtful touch. Button press animations via `HLCardPressStyle()` provide visual feedback. The Pomodoro timer has clear play/reset/skip controls.

### Interaction Design -- Major

**Problem:** Multiple screens -- Only 5 of 15+ scrollable main screens implement `.refreshable`. Sleep History, Sleep Analytics, Leaderboard, Achievements, Personal Statistics, and Friends List all show data but cannot be refreshed.

**Impact:** Users have no way to refresh stale data without navigating away and back. This is especially problematic for social features where data changes frequently.

**Fix:** Add `.refreshable` to all ScrollView-based screens that display data: SleepHistoryView, SleepAnalyticsView, LeaderboardView, AchievementsView, PersonalStatisticsView, FriendsListView.

### Interaction Design -- Minor

**Problem:** NotificationCenterView (01_notifications.png) -- The empty notification screen has no action. There is no way to configure notifications, no link to settings, and no pull-to-refresh.

**Impact:** Dead-end screen with no user agency.

**Fix:** Add a "Set Up Reminders" button that navigates to notification settings, or at minimum add pull-to-refresh to check for new notifications.

### Interaction Design -- Minor

**Problem:** Social tab -- The four-segment picker (Friends / Leaderboard / Challenges / Feed) requires precise tapping on small text labels. There is no swipe gesture to switch between sections.

**Impact:** Switching sections feels less fluid than iOS-native tab behavior.

**Fix:** Consider using a `TabView` with `.tabViewStyle(.page)` for swipe-to-switch, or use a segmented control (`.pickerStyle(.segmented)`) for the iOS-native feel.

---

### 7. HIG Compliance (4/5)

The app follows Apple HIG conventions well. Navigation uses NavigationStack properly, the custom tab bar mirrors the system tab bar behavior, SF Symbols are used consistently (via HLIcon constants), and sheets use the standard dismiss pattern. The `.hlSheetContent()` modifier suggests proper sheet sizing.

### HIG Compliance -- Minor

**Problem:** TabBarView.swift -- The app uses a fully custom tab bar instead of the system `TabView`. While visually polished, this means it does not support the standard iOS double-tap-to-scroll-to-top behavior that users expect.

**Impact:** Users who rely on the double-tap-to-scroll-to-top gesture (a deeply ingrained iOS behavior) will be frustrated.

**Fix:** Either implement scroll-to-top when the active tab is tapped again, or switch to the system `TabView` and customize its appearance. The custom tab bar already mirrors system styling closely, so this gap is noticeable.

### HIG Compliance -- Minor

**Problem:** HomeDashboardView -- The home screen uses a custom header ("HabitLand" with icons) instead of a standard `.navigationTitle`. This is acceptable for the home screen but differs from every other screen in the app which uses standard navigation titles.

**Impact:** Minor inconsistency. The home screen header scrolls with content while other screens use the standard collapsing large title.

**Fix:** This is intentional and acceptable for a home/dashboard screen. No change needed, noted for consistency tracking.

---

### 8. Accessibility (3/5)

Accessibility has foundational support but significant gaps. The app has 71 `.accessibilityLabel()` usages and 54 `.accessibilityHidden(true)` usages, which shows awareness. `@ScaledMetric` is used extensively for icon sizing. However, Dynamic Type layout adaptation is absent, contrast ratios need work, and many interactive elements lack labels.

### Accessibility -- Critical

**Problem:** All view files -- Zero usage of `@Environment(\.dynamicTypeSize)` or `.dynamicTypeSize()`. The app has no layout adaptation for Accessibility text sizes.

**Impact:** Users with Accessibility XL or larger text sizes will experience overlapping text, truncated content, and broken layouts in stat rows, card layouts, and horizontal arrangements throughout the app.

**Fix:** Add `@Environment(\.dynamicTypeSize) private var dynamicTypeSize` to views with horizontal layouts (stat rows, card grids, leaderboard podium). Switch from HStack to VStack when `dynamicTypeSize.isAccessibilitySize`.

### Accessibility -- Critical

**Problem:** Chart components (CircularProgressRing.swift, WeeklyChart.swift, SleepQualityGraph.swift, HabitAnalyticsGraph.swift) -- These visual data representations have minimal or no VoiceOver support. Charts show data visually but screen reader users get no information.

**Impact:** Blind and low-vision users cannot access any chart data, which is a core feature of the app (progress tracking, sleep analytics, habit trends).

**Fix:** Add `.accessibilityElement(children: .ignore)` to chart containers and provide a comprehensive `.accessibilityLabel()` that summarizes the data: e.g., "Weekly sleep chart. Average 7.4 hours. Best night Friday at 9 hours. Worst night Tuesday at 6 hours."

### Accessibility -- Major

**Problem:** Theme.swift:43-47 -- `hlTextTertiary` dark mode contrast is approximately 3.2:1 against `hlSurface`, below WCAG AA 4.5:1 minimum for normal text.

**Impact:** Users with low vision cannot read tertiary text in dark mode.

**Fix:** Change dark mode `hlTextTertiary` from `UIColor(red: 0.43, green: 0.43, blue: 0.45)` to `UIColor(red: 0.56, green: 0.56, blue: 0.58)` (#8E8E93) for 4.5:1+ contrast.

### Accessibility -- Major

**Problem:** Sleep quality and mood icons in LogSleepView and SleepHistoryView show as "?" placeholder boxes in screenshots (03_log_sleep_form.png, 03_sleep_history.png), suggesting emoji rendering issues or missing SF Symbols.

**Impact:** All users of the Sleep tab see broken icons. VoiceOver users would hear no meaningful description of these broken elements.

**Fix:** Verify that the emoji or SF Symbol names for sleep quality levels (Terrible, Poor, Fair, Good, Excellent) and mood levels (Exhausted through Energized) are valid. If using emoji, ensure they render correctly on all iOS versions.

---

## Domain Deep Dives

### Home Domain
**Screenshots reviewed:** 01_home_top.png, 01_home_mid.png, 01_home_bottom.png, 01_pomodoro.png, 01_notifications.png, 01_create_habit_sheet.png, 01_daily_overview.png
**Files analyzed:** HomeDashboardView.swift, DailyHabitsOverview.swift, PomodoroView.swift, WeeklyProgressView.swift, StreakSummaryView.swift, InsightsOverviewView.swift, HabitChainView.swift, HabitTimerView.swift
**Domain score:** 32/40

The home dashboard is the strongest screen in the app. The greeting ("Good morning, Alex"), date, level progress bar, and daily progress ring create a clear narrative from top to bottom. The habit list with streak badges and completion checkmarks is immediately scannable. The weekly insight card ("Just 1 habit left -- finish strong!") is well-placed and motivating.

The Pomodoro timer screen is clean and focused with a large ring timer, clear session counter, and ambient sound picker at the bottom. The sound picker icons (Rain, Forest, Ocean, etc.) are well-spaced and labeled.

Weakness: The bottom half of the home screen (below habits list) has diminishing returns -- stats row, insight, Focus Timer, and "Track to Transform" card feel like filler. Consider making the Focus Timer more prominent or removing the motivational card.

### Habits Domain
**Screenshots reviewed:** 02_edit_habit.png (shows undo toast on home), 02_habits_list.png through 02_create_form_bottom.png (all show home due to nav issues)
**Files analyzed:** HabitListView.swift, HabitDetailView.swift, CreateHabitView.swift, EditHabitView.swift, HabitArchiveView.swift, HabitHistoryView.swift, HabitNotesView.swift, HabitReminderView.swift
**Domain score:** 31/40

NOTE: Due to XCUITest navigation issues, all Habit tab screenshots showed the Home dashboard instead. Scoring is based on code inspection and the visible HabitCard components on the home screen.

The HabitCard component is well-designed: icon in colored circle, name, streak badge with flame, and a contextual right action (checkmark for simple habits, counter for progressive, timer for time-based, heart for HealthKit). The CreateHabitView has a comprehensive form with icon picker, color picker, category, frequency, goal, and HealthKit integration.

The undo toast (visible in 02_edit_habit.png) shows "Morning Meditation completed! [Undo]" -- a best-practice pattern for reversible actions.

### Sleep Domain
**Screenshots reviewed:** 03_sleep_dashboard.png, 03_sleep_scrolled.png, 03_sleep_bottom.png, 03_log_sleep_form.png, 03_log_sleep_scrolled.png, 03_sleep_history.png, 03_sleep_history_scrolled.png, 03_sleep_analytics.png, 03_sleep_analytics_scrolled.png, 03_sleep_saved.png
**Files analyzed:** SleepDashboardView.swift, LogSleepView.swift, SleepHistoryView.swift, SleepAnalyticsView.swift, SleepInsightsView.swift
**Domain score:** 32/40

The sleep domain has the most complete screenshot coverage and shows strong visual design. The dashboard card hierarchy (Last Night -> This Week chart -> Stats row -> Insights) is logical. The purple color theme (hlSleep) creates a distinct visual identity. The "Log Sleep" CTA is prominent and sticky at the bottom.

The Log Sleep form is clean with a clear duration display, time pickers, and quality/mood selectors. However, the quality and mood icons appear as "?" placeholders in screenshots -- this is a visual bug that needs fixing.

Sleep Analytics is data-rich with 30-day duration chart, quality trend line, best/worst night comparison, day-of-week averages, sleep debt, and bed-vs-asleep efficiency. The data density is high but well-organized with card separations.

### Social Domain
**Screenshots reviewed:** 04_social_hub.png, 04_friends_scrolled.png, 04_friend_profile.png, 04_friend_profile_scrolled.png, 04_leaderboard.png, 04_leaderboard_scrolled.png, 04_challenges.png, 04_create_challenge.png, 04_invite_friends.png
**Files analyzed:** SocialHubView.swift, FriendsListView.swift, FriendProfileView.swift, LeaderboardView.swift, SharedChallengesView.swift, CreateChallengeView.swift, SocialFeedView.swift, InviteFriendsView.swift, NudgesSheetView.swift, PendingRequestsView.swift
**Domain score:** 30/40

The social hub segment picker is functional but the four-segment horizontal layout feels crowded. The friends list is clean with avatar, name, level badge, streak, and activity status. Friend profiles are well-structured with avatar, stats row (42 Day Streak / 210 Completions / Lvl 12), and Nudge/Challenge action buttons.

The leaderboard podium view is creative with #1/#2/#3 positioned in a podium layout with crown icon. The full rankings list below is clear with rank number, avatar, name, streak, and XP.

The Challenges empty state is one of the best empty states in the app -- centered flag icon, clear message, and prominent "Create Challenge" CTA.

Invite Friends screen is comprehensive with referral code, share button, friend search, and code entry. The layout is well-organized.

### Profile Domain
**Screenshots reviewed:** 05_personal_stats.png, 05_personal_stats_scrolled.png (05_profile_top/scrolled/bottom showed Challenges screen due to nav issues)
**Files analyzed:** UserProfileView.swift, PersonalStatisticsView.swift, EditProfileView.swift, AchievementsShowcaseView.swift, AvatarPickerView.swift
**Domain score:** 31/40

NOTE: Profile screenshots showed the Social Challenges screen due to navigation issues. Scoring is based on code inspection and the Personal Statistics screenshots.

Personal Statistics view is excellent: 6 stat cards in a 2-column grid (Total Completions, Days Active, Success Rate, Best Streak, Habits Created, Achievements), monthly completions bar chart, category breakdown with color-coded progress bars, and personal records section. The data presentation is clear and well-organized.

From code analysis, the Profile view has proper structure: avatar, name/username, level badge, stats row, streak freeze card, achievements showcase, and quick links to settings.

### Settings Domain
**Screenshots reviewed:** None available in this run
**Files analyzed:** GeneralSettingsView.swift, AppearanceSettingsView.swift, NotificationSettingsView.swift, DataExportView.swift
**Domain score:** 31/40

From code inspection, Settings uses the standard `List` component with sections -- following HIG conventions closely. The "Upgrade to Pro" banner at the top of settings uses an orange gradient icon, which is a common and effective pattern. Settings icon styling (28x28 colored squares with rounded corners) follows the iOS Settings app pattern.

### Onboarding Domain
**Screenshots reviewed:** None in this run
**Files analyzed:** OnboardingView.swift, HabitPreferenceView.swift, NotificationSetupView.swift, OnboardingCompleteView.swift, StarterHabitsView.swift, ThemeOnboardingView.swift
**Domain score:** 31/40

OnboardingView.swift is one of the largest files with 22 `.font(.system(size:))` occurrences, suggesting complex custom layouts. The onboarding includes theme selection, habit preferences, notification setup, and starter habits -- a comprehensive first-run experience. Code shows `.minimumScaleFactor()` usage (8 instances), indicating attention to text fitting.

### Premium Domain
**Screenshots reviewed:** None in this run
**Files analyzed:** PaywallView.swift, PremiumGateView.swift, LegalView.swift
**Domain score:** 31/40

PaywallView uses a standard paywall pattern: header icon, feature list, plan selection, purchase button, restore button, and legal links. Error handling includes a "Purchase Failed" alert with "Try Again" option -- good error recovery. The contextual paywall system (`PaywallContext`) shows different headers based on which feature triggered the gate -- a sophisticated and user-friendly approach.

### Analytics Domain
**Screenshots reviewed:** 03_sleep_analytics.png, 03_sleep_analytics_scrolled.png (sleep analytics only)
**Files analyzed:** WeeklyAnalyticsView.swift, MonthlyAnalyticsView.swift, LongTermProgressView.swift, HabitDifficultyInsightsView.swift, HabitSuccessTrendsView.swift
**Domain score:** 29/40

Analytics views are data-dense. Code shows heavy use of custom chart components and design system tokens. The sleep analytics screenshots demonstrate good data visualization with 30-day charts, trend lines, and statistical summaries. However, the analytics domain has the highest density of `.font(.system(size:))` calls (InsightsOverviewView.swift alone has 12), suggesting more hardcoded styling than other domains.

### Discovery Domain
**Screenshots reviewed:** None in this run
**Files analyzed:** TemplateBrowserView.swift, HabitDiscoveryView.swift, HabitCategoriesView.swift, RecommendedHabitsView.swift, HabitPackDetailView.swift
**Domain score:** 30/40

Code inspection shows a well-organized template browser system with categories, recommendations, and habit packs. Template cards use design system tokens consistently. The domain lacks screenshots for visual verification.

### Notifications Domain
**Screenshots reviewed:** 01_notifications.png
**Files analyzed:** NotificationCenterView.swift, NotificationDetailView.swift, ReminderSettingsView.swift
**Domain score:** 29/40

The notification center empty state ("All Caught Up! You're on top of your game.") is positive but the screen feels underdeveloped. No loading state, no refresh action, no navigation to notification settings. When notifications exist, NotificationDetailView.swift has 5 `.font(.system(size:))` calls and 31 design token references -- reasonable but the detail view is relatively small.

---

## Design System Health

- **Token coverage:** ~92% of views use design tokens (3,428 design system token references vs 298 `.font(.system(size:))` calls). The remaining 8% is primarily icon sizing where `@ScaledMetric` + `min()` replaces `HLFont` -- this is an acceptable pattern for icons but could be formalized.
- **Consistency score:** High -- The `.hlCard()` modifier, `HLSpacing` constants, `HLFont` functions, and `Color.hl*` palette are used consistently across virtually all view files.
- **Missing tokens:**
  - No `HLIconSize` struct exists as a standalone file (though icon sizes are declared per-view with `@ScaledMetric`, which is actually the correct pattern since `@ScaledMetric` cannot be used on static properties)
  - No spacing tokens for "section gap" vs "card gap" vs "element gap" -- views use `HLSpacing.md` (16) for most gaps but some use `.lg` (24) for section breaks. A semantic layer (e.g., `HLSpacing.sectionGap`, `HLSpacing.cardGap`) would improve consistency.
  - No elevation/shadow tokens beyond the existing `HLShadow` levels -- all cards use `.sm` shadow, creating flat visual depth.
- **Recommendations:**
  1. Create semantic spacing aliases: `sectionGap = lg`, `cardGap = md`, `elementGap = sm`, `inlineGap = xs`
  2. Vary shadow levels by card importance: featured cards could use `.md`, standard cards `.sm`
  3. Formalize the `@ScaledMetric` icon size pattern with a documented convention (the current per-view approach is correct but the naming varies: `flameSize`, `flameIconSize`, `iconSize`, `smallIconSize`, etc.)
  4. Add a dark mode contrast checker to the design system (automated test that verifies all text/background combinations meet WCAG AA)

---

## Files Analyzed

### Screenshot Files (40 total)
- 01_home_top.png, 01_home_mid.png, 01_home_bottom.png
- 01_notifications.png, 01_create_habit_sheet.png, 01_pomodoro.png, 01_daily_overview.png
- 02_habits_list.png, 02_habits_scrolled.png, 02_habit_detail_top.png, 02_habit_detail_mid.png, 02_habit_detail_bottom.png
- 02_edit_habit.png, 02_edit_habit_scrolled.png, 02_create_form_empty.png, 02_create_form_mid.png, 02_create_form_bottom.png
- 03_sleep_dashboard.png, 03_sleep_scrolled.png, 03_sleep_bottom.png, 03_sleep_saved.png
- 03_log_sleep_form.png, 03_log_sleep_scrolled.png
- 03_sleep_history.png, 03_sleep_history_scrolled.png
- 03_sleep_analytics.png, 03_sleep_analytics_scrolled.png
- 04_social_hub.png, 04_friends_scrolled.png, 04_friend_profile.png, 04_friend_profile_scrolled.png
- 04_leaderboard.png, 04_leaderboard_scrolled.png, 04_challenges.png, 04_create_challenge.png
- 04_invite_friends.png
- 05_profile_top.png, 05_profile_scrolled.png, 05_profile_bottom.png
- 05_personal_stats.png, 05_personal_stats_scrolled.png

### Design System Files
- `/Users/azc/works/HabitLand/HabitLand/DesignSystem/Theme.swift`
- `/Users/azc/works/HabitLand/HabitLand/DesignSystem/Effects.swift`

### Screen View Files (65 files across 11 domains)
- Home: HomeDashboardView, DailyHabitsOverview, PomodoroView, WeeklyProgressView, StreakSummaryView, InsightsOverviewView, HabitChainView, HabitTimerView
- Habits: HabitListView, HabitDetailView, CreateHabitView, EditHabitView, HabitArchiveView, HabitHistoryView, HabitNotesView, HabitReminderView, HabitScheduleView, HabitStatisticsView
- Sleep: SleepDashboardView, LogSleepView, SleepHistoryView, SleepAnalyticsView, SleepInsightsView
- Social: SocialHubView, FriendsListView, FriendProfileView, LeaderboardView, SharedChallengesView, CreateChallengeView, SocialFeedView, InviteFriendsView, NudgesSheetView, PendingRequestsView
- Profile: UserProfileView, PersonalStatisticsView, EditProfileView, AchievementsShowcaseView, AvatarPickerView
- Settings: GeneralSettingsView, AppearanceSettingsView, NotificationSettingsView, DataExportView, HabitSettingsView, PrivacySettingsView
- Premium: PaywallView, PremiumGateView, LegalView
- Analytics: WeeklyAnalyticsView, MonthlyAnalyticsView, LongTermProgressView, HabitDifficultyInsightsView, HabitSuccessTrendsView
- Discovery: TemplateBrowserView, HabitDiscoveryView, HabitCategoriesView, RecommendedHabitsView, HabitPackDetailView
- Notifications: NotificationCenterView, NotificationDetailView, ReminderSettingsView
- Onboarding: OnboardingView, HabitPreferenceView, NotificationSetupView, OnboardingCompleteView, StarterHabitsView, ThemeOnboardingView
- Gamification: AchievementsView, MilestonesView, RewardsView, StreakOverviewView, LevelProgressView

### Component Files (32 total)
- Cards: HabitCard, AchievementCard, SleepCard, StreakCard, ProgressCard
- Common: EmptyStateView, HLButton, LoadingView, SectionHeader, SpotlightCoachingView
- Navigation: TabBarView, HeaderView, FloatingActionButton
- Social: FriendCard, LeaderboardRow, ChallengeCard, AvatarView
- Inputs: HLTextField, HLSlider, HLTimePicker, HLToggle
- Analytics: CircularProgressRing, WeeklyChart, SleepQualityGraph, HabitAnalyticsGraph
- Gamification: AchievementBadge, LevelBadge, MilestoneBadge, StreakFlame
- Other: AmbientSoundPicker, ReferralCodeEntryView, UndoToast
