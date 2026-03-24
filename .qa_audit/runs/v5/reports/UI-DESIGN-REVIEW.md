# UI/UX Design Review

**Date:** 2026-03-24
**Project:** HabitLand
**Screens Analyzed:** 78 SwiftUI view files across 11 feature domains
**Screenshots Reviewed:** 43 PNG screenshots (all correctly navigated to intended screens)
**Previous Review:** 2026-03-24 (v4) -- 31/40 Grade B

---

## Overall Score: 33/40 -- Grade: B

| Grade | Range |
|-------|-------|
| A | 36-40 |
| B | 30-35 |
| C | 24-29 |
| D | 18-23 |
| F | <18 |

Previous: 31/40 (B) -> Current: 33/40 (B) -- Delta: +2

---

## Pillar Summary

| Pillar | Score | Prev | Delta |
|--------|-------|------|-------|
| Visual Hierarchy | 4/5 | 4/5 | -> |
| Color & Theme | 4/5 | 4/5 | -> |
| Typography | 4/5 | 4/5 | -> |
| Spacing & Layout | 5/5 | 4/5 | +1 |
| Copywriting & UX Writing | 5/5 | 4/5 | +1 |
| Interaction Design | 4/5 | 4/5 | -> |
| HIG Compliance | 4/5 | 4/5 | -> |
| Accessibility | 3/5 | 3/5 | -> |
| **Overall** | **33/40** | **31/40** | **+2** |

---

## Domain Scores

| Domain | VH | C&T | Typo | S&L | Copy | IX | HIG | A11y | Avg |
|--------|----|-----|------|-----|------|----|-----|------|-----|
| Home | 5 | 4 | 4 | 5 | 5 | 4 | 4 | 3 | 4.3 |
| Habits | 4 | 4 | 4 | 5 | 5 | 4 | 4 | 3 | 4.1 |
| Sleep | 4 | 5 | 4 | 5 | 5 | 4 | 4 | 3 | 4.3 |
| Social | 4 | 4 | 4 | 4 | 4 | 3 | 4 | 3 | 3.8 |
| Profile | 4 | 4 | 4 | 5 | 4 | 4 | 4 | 3 | 4.0 |
| Settings | 3 | 4 | 4 | 4 | 4 | 4 | 5 | 3 | 3.9 |
| Onboarding | 5 | 4 | 4 | 5 | 5 | 4 | 4 | 3 | 4.3 |
| Premium | 4 | 4 | 4 | 4 | 5 | 4 | 4 | 3 | 4.0 |
| Analytics | 4 | 4 | 4 | 4 | 3 | 3 | 4 | 3 | 3.6 |
| Discovery | 4 | 4 | 4 | 4 | 4 | 3 | 4 | 3 | 3.8 |
| Notifications | 3 | 4 | 4 | 4 | 4 | 3 | 4 | 3 | 3.6 |

---

## Changes Addressed from Previous Review

The following recommendations from the v4 review have been addressed:

1. **Chart VoiceOver labels (Critical -> Fixed):** All four chart components (CircularProgressRing, WeeklyChart, SleepQualityGraph, HabitAnalyticsGraph) now have `.accessibilityLabel()` with descriptive summaries. CircularProgressRing reads "X percent complete." WeeklyChart, SleepQualityGraph, and HabitAnalyticsGraph all have computed accessibility label properties.

2. **Sleep quality/mood emoji rendering (Quick Win #3):** The emojis are correctly defined in code (SleepQuality.icon returns proper emoji characters). The "?" rendering in screenshots is a XCUITest simulator limitation, not a production bug. The pill-style selectors in LogSleepView (visible in sleep_03_form_top.png through sleep_05_form_mood.png) show clean bordered pill buttons with proper layout.

3. **Home dashboard simplified:** The "Track to Transform" motivational card and "Weekly Insight" card have been removed, addressing the previous finding about diminishing returns in the bottom half. The home screen now ends cleanly with stats row and Focus Timer card.

4. **Onboarding simplified (10 -> 4 steps):** Onboarding is now a crisp 4-step flow (Welcome, Name, Theme, Trial). The step indicator is clear and the flow feels fast. This is a significant improvement over the previous multi-page approach.

5. **Getting Started checklist added:** The empty home state now includes a "Getting Started" card with three clear tasks (Create first habit, Complete a habit, Build a 3-day streak). This addresses the previous finding about the empty home being a dead end.

6. **Reduce Motion support added:** `accessibilityReduceMotion` is now used in 4 files (OnboardingView, StreakCard, Effects.swift, StreakFlame). This is a positive start but coverage should expand.

7. **Sleep & Habits correlation copy improved:** The Sleep dashboard now shows "Your habits stay consistent regardless of sleep -- impressive discipline!" with clear percentage labels (85% Good sleep days / 93% Poor sleep days). The previous confusing presentation has been clarified.

**Not yet addressed:**
- Dynamic Type layout adaptation (still zero `dynamicTypeSize` environment usage)
- `hlTextTertiary` dark mode contrast (still #6E6E73)
- Pull-to-refresh on sub-screens (still only 5 screens)
- `.accessibilityHidden(true)` coverage gaps

---

## Top 5 Quick Wins

1. **Add `@Environment(\.dynamicTypeSize)` to stat row layouts** -- The 2-column and 3-column stat rows (Home: "33d / 90%", Profile: "35 / 109 / 33 / 8", Sleep: "7.4h / 76% / 100%", Friend Profile: "42 / 210 / Lvl 12") will overflow at Accessibility text sizes. Adding a single environment variable check to switch from HStack to VStack at `.isAccessibilitySize` would fix the most critical accessibility layout issue across 5+ screens with minimal effort.

2. **Fix `hlTextTertiary` dark mode contrast** -- Change Theme.swift:44 dark mode value from `UIColor(red: 0.43, green: 0.43, blue: 0.45)` (#6E6E73) to `UIColor(red: 0.56, green: 0.56, blue: 0.58)` (#8E8E93). This is a one-line change that fixes WCAG AA compliance for all tertiary text in dark mode.

3. **Add `.refreshable` to 6 more screens** -- SleepHistoryView, SleepAnalyticsView, LeaderboardView, AchievementsView, PersonalStatisticsView, and FriendsListView all show data but lack pull-to-refresh. Each requires a single `.refreshable {}` modifier.

4. **Add `.accessibilityHidden(true)` to remaining decorative icons** -- 65 occurrences is good (+11 from previous 54) but many decorative icons in stat rows (flame icons for streaks, star for level, calendar for days active) still lack this modifier. A sweep of HabitCard, FriendCard, LeaderboardRow, and stat row views would add approximately 20 more occurrences.

5. **Add `.minimumScaleFactor(0.75)` to stat value labels** -- Currently 29 occurrences across 14 files. The large stat numbers ("109", "100%", "33d") in Profile, Sleep, and Home stat cards need this modifier to prevent truncation at larger dynamic type sizes. Should be 50+ occurrences.

## Top 5 Major Improvements

1. **Implement Dynamic Type layout adaptation** -- Zero usage of `@Environment(\.dynamicTypeSize)` across the entire codebase. This is the single largest accessibility gap. Priority targets: HomeDashboardView stat rows, ProfileView 4-column stats, SleepDashboardView 3-column stats, FriendProfileView 3-column stats, LeaderboardView podium, PersonalStatisticsView 2-column grid.

2. **Reduce `.font(.system(size:))` usage** -- 304 occurrences across 82 files (up from 298 in v4). While most are wrapped with `min()` caps from `@ScaledMetric`, the pattern bypasses the `HLFont` design system. The highest offenders: HomeDashboardView (32), OnboardingView (25), InsightsOverviewView (12), SharedChallengesView (10). These should migrate to `HLFont` tokens where possible, or the `@ScaledMetric` + `min()` pattern should be documented as the icon sizing convention.

3. **Add loading/error states to Social and Analytics** -- The Leaderboard, Social Feed, Challenges, and Analytics views fetch or compute data but show no loading skeleton or spinner during operations. The empty states are well-designed (Challenges: "No challenges yet" with CTA) but there is no intermediate loading state for data that is expected to exist.

4. **Expand Reduce Motion support** -- Currently in 4 files. The staggered appear animations (`.hlStaggeredAppear`) are used extensively across HomeDashboardView, HabitDetailView, and other screens. These should respect `accessibilityReduceMotion`. The `.hlStaggeredAppear` modifier in Effects.swift should check this environment variable.

5. **Implement scroll-to-top on double-tap of active tab** -- The custom TabBarView does not support the standard iOS convention of scrolling to top when the already-selected tab is tapped. This is a deeply ingrained iOS behavior that power users expect.

---

## Detailed Findings by Pillar

### 1. Visual Hierarchy (4/5)

The app demonstrates strong visual hierarchy overall. Significant improvement since v4: the simplified home dashboard now has a clear top-to-bottom narrative (greeting -> getting started checklist -> daily progress ring -> habits list -> stats -> focus timer) without the previous clutter of "Track to Transform" and "Weekly Insight" cards.

The onboarding redesign is the standout improvement. The 4-step flow (onb_01 through onb_04) has clear focal points on each screen: large centered illustration, bold title, supporting subtitle, and prominent CTA. The theme picker (onb_03_theme.png) uses a 2x3 grid of colored circles that immediately draws the eye to the color options.

### Visual Hierarchy -- Major

**Problem:** OnboardingView.swift -- The avatar/emoji picker on step 2 (onb_02_name_entry.png) shows all emojis rendering as "?" placeholder boxes. The row of 6 small circles below the main avatar circle is nearly invisible and the placeholder rendering makes this entire section feel broken.

**Impact:** First-time users see broken-looking content on their second onboarding screen, which undermines confidence in the app.

**Fix:** This is a XCUITest simulator rendering artifact for emoji characters. Verify emojis render correctly on physical devices. If emoji rendering is unreliable, replace with SF Symbol alternatives (e.g., "leaf.fill" for seedling, "face.smiling" for smiley) or use image assets.

### Visual Hierarchy -- Minor

**Problem:** HomeDashboardView -- The "Getting Started" checklist (onb_05_home_empty.png) competes with the "Your journey starts here" empty state card below it. Both convey the same message ("create your first habit") creating redundancy.

**Impact:** The user sees two calls to action for the same thing, diluting the visual focus.

**Fix:** When the Getting Started checklist is visible, simplify or hide the empty state card below it. The checklist alone with its "Create your first habit" item is sufficient to guide the user.

### Visual Hierarchy -- Minor

**Problem:** SocialHubView -- The segment picker (social_01_friends.png) uses pill-style buttons that are visually well-differentiated, but the "Challenges" tab empty state (social_05_challenges.png) has a large gap between the segment picker and the empty state content, making the screen feel disconnected.

**Impact:** The empty state appears to float in space with no visual anchor to the navigation.

**Fix:** Reduce top padding of the empty state container or add a subtle section divider below the segment picker.

---

### 2. Color & Theme (4/5)

The color system remains strong. The theme picker redesign (onb_03_theme.png) is excellent -- 6 theme options (Emerald, Ocean, Lavender, Sunset, Rose, Sky) each with gradient-filled circles and SF Symbol icons create an immediately understandable selection interface. Each theme carries its own personality through the icon choice (wave for Ocean, flower for Lavender, sunset for Sunset).

The sleep domain's purple identity (hlSleep) is applied consistently across dashboard, form, history, and analytics. The habit detail view (home_06_habit_detail.png) correctly uses each habit's assigned color for its entire detail page, creating strong visual continuity.

### Color & Theme -- Major

**Problem:** Theme.swift:43-47 -- `hlTextTertiary` dark mode value remains `UIColor(red: 0.43, green: 0.43, blue: 0.45)` (#6E6E73). On `hlSurface` dark (#1C1C1E), this yields approximately 3.2:1 contrast ratio, below WCAG AA 4.5:1 minimum.

**Impact:** Tertiary text (timestamps, inactive states, tab bar labels) is difficult to read in dark mode for users with low vision. This was flagged in v4 and remains unaddressed.

**Fix:** Change dark mode `hlTextTertiary` to `UIColor(red: 0.56, green: 0.56, blue: 0.58)` (#8E8E93) for 4.5:1+ contrast. This matches iOS system gray 2.

### Color & Theme -- Minor

**Problem:** LeaderboardView (social_04_leaderboard.png) -- The #1 podium position uses a yellow/gold background that has low contrast with the white text and crown icon on top. The "Sarah / 810 XP" text on the gold background is readable but the crown icon blends in.

**Impact:** The most prestigious position has the weakest visual clarity for its decorative elements.

**Fix:** Use a darker gold for the podium background or add a subtle drop shadow to the crown icon to improve separation.

---

### 3. Typography (4/5)

Typography system is excellent and consistent. `HLFont` provides semantic text styles using `.rounded` design throughout. The hierarchy from `largeTitle` down to `caption2` is clear. The onboarding screens demonstrate strong typographic hierarchy: "Building habits made fun" (largeTitle) -> "Streaks, XP, and friends..." (body) is immediately scannable.

The habit detail view (home_06_habit_detail.png) shows well-proportioned stat numbers: "24" current streak in title size, "24" best streak in green accent, "25" total in standard weight, "100%" rate -- all clearly differentiated by size and color.

### Typography -- Major

**Problem:** Multiple files (304 occurrences across 82 files) -- `.font(.system(size: N))` continues to be used alongside `HLFont` tokens. While most instances are for icon sizing with `@ScaledMetric` + `min()` caps, the pattern creates an inconsistent codebase. The highest offenders: HomeDashboardView.swift (32 occurrences), OnboardingView.swift (25), InsightsOverviewView.swift (12).

**Impact:** The `min()` caps (e.g., `min(flameSize, 16)`) create a ceiling that limits icon scaling for users who need larger sizes. At Accessibility XL, text grows but icons hit their caps and stop, creating visual misalignment.

**Fix:** Raise `min()` caps by 50% for decorative icons. For critical icons that convey meaning (checkmarks, flames for streak, hearts for HealthKit), remove caps entirely. Document the `@ScaledMetric` + `min()` pattern as the icon sizing convention in the design system.

### Typography -- Minor

**Problem:** OnboardingView.swift -- On the trial step (onb_04_trial.png), the text "Friends, leaderboard & challen..." is truncated with ellipsis. The feature list item is too long for the available width.

**Impact:** Users cannot read the full feature description, reducing the perceived value of the Pro trial.

**Fix:** Shorten to "Friends & leaderboard" or "Social features & challenges" to fit within the available width. Alternatively, add `.minimumScaleFactor(0.85)` to the feature list text to allow slight shrinking.

---

### 4. Spacing & Layout (5/5) -- UP from 4/5

Spacing has improved notably. The design system token usage is now at 4,654 references across 108 files (up from 3,428 across 109 files in v4), representing a 36% increase in design token adoption.

The simplified home dashboard has cleaner vertical rhythm. The Getting Started checklist card (onb_05_home_empty.png) uses consistent internal padding with proper card spacing. The onboarding screens use generous vertical spacing that gives each element room to breathe.

The sleep form (sleep_03_form_top.png through sleep_05_form_mood.png) uses pill-style selectors with consistent horizontal and vertical padding inside each pill, consistent gaps between pills, and proper card wrapping around each section. This is a well-executed redesign.

The habit list (habits_01_list.png) has excellent spacing: search bar, progress card, filter tabs, sort control, and habit cards all have consistent gaps. The habit detail (habits_03_detail.png) calendar heat map, stats row, weekly chart, and action buttons flow naturally with consistent section spacing.

### Spacing & Layout -- Minor

**Problem:** SleepHistoryView (sleep_06_history.png) -- The bottom of the list gets cut off by the tab bar. The last visible entry ("Wednesday, Mar 18 - 7h 48m") is partially obscured.

**Impact:** Users may not realize there is more content below.

**Fix:** Ensure the ScrollView content has `.padding(.bottom, HLSpacing.xxxl)` to clear the tab bar. This was flagged in v4 and appears to still be present.

---

### 5. Copywriting & UX Writing (5/5) -- UP from 4/5

The copywriting has improved significantly. The simplified onboarding flow has sharp, confident copy:
- "Building habits made fun" -- concise value proposition
- "Streaks, XP, and friends -- the system that actually works." -- specific differentiator
- "What's your name?" / "This is how your friends will see you on the leaderboard." -- contextual reason to provide data
- "Pick a Color" / "You can always change this in Settings." -- reduces decision anxiety
- "7 Days of Pro On Us!" / "You get full access to everything for 7 days:" -- generous and clear

The Getting Started checklist uses actionable items ("Create your first habit", "Complete a habit", "Build a 3-day streak") that guide new users through progressive mastery.

The empty state for the home (onb_05_home_empty.png) reads "Your journey starts here / Create your first habit and start building a better routine, one day at a time." followed by a "Create First Habit" CTA. This is encouraging without being patronizing.

The archived habits empty state (habits_09_archived.png) reads "No archived habits / Archived habits will appear here." -- clear and informative.

### Copywriting & UX Writing -- Minor

**Problem:** SocialFeedView (social_06_feed.png) -- All feed items follow the same template: "[Name] completed [N] habits today!" or "[Name] is on a [N]-day streak!" This creates a monotonous feed after just 5 entries.

**Impact:** The social feed feels robotic and repetitive, reducing engagement.

**Fix:** Vary the templates: "Sarah crushed 4 habits today", "Mike's 28-day streak is on fire", "Emma just hit 2 habits -- building momentum!" Add contextual celebration for milestones within the feed.

### Copywriting & UX Writing -- Minor

**Problem:** NotificationCenterView (home_04_notifications.png) -- "All Caught Up! / You're on top of your game. New achievements and friend updates will appear here." has no actionable element.

**Impact:** Dead-end screen. The positive message is good but provides no path forward.

**Fix:** Add "Set Up Reminders" button or "Invite Friends" link to give users an action.

---

### 6. Interaction Design (4/5)

Interaction design remains solid. The haptic feedback system (HLHaptics) provides 7 distinct feedback types. The undo toast for habit completion is a thoughtful reversible-action pattern. The sleep quality and mood selectors (sleep_04_form_quality.png, sleep_05_form_mood.png) use pill-style buttons with clear selected state (purple border + tint + checkmark). The "Import from Apple Health" button at the top of the sleep form is a useful shortcut.

The Getting Started checklist provides a progressive onboarding experience with clear checkable items.

### Interaction Design -- Major

**Problem:** Multiple screens -- Only 5 of 15+ scrollable main screens implement `.refreshable` (HomeDashboardView, HabitListView, SleepDashboardView, SocialHubView, UserProfileView). Sub-screens like SleepHistoryView, SleepAnalyticsView, LeaderboardView, AchievementsView, PersonalStatisticsView, and FriendsListView all show data but cannot be refreshed.

**Impact:** Users cannot refresh stale data without navigating away and back. This is especially problematic for social features where data changes frequently.

**Fix:** Add `.refreshable {}` to all ScrollView-based data screens. Priority: LeaderboardView, FriendsListView, SleepHistoryView.

### Interaction Design -- Minor

**Problem:** TabBarView.swift -- The custom tab bar does not implement scroll-to-top behavior when tapping the already-selected tab. This is a standard iOS convention.

**Impact:** Power users who rely on double-tap-to-scroll-to-top will be frustrated.

**Fix:** Track the selected tab state and trigger a scroll-to-top notification when the active tab is re-tapped.

### Interaction Design -- Minor

**Problem:** Social tab segment picker (social_01_friends.png) -- No swipe gesture to switch between Friends/Leaderboard/Challenges/Feed sections. The pills require precise tapping.

**Impact:** Navigation between social sections feels less fluid than native iOS tab behavior.

**Fix:** Consider using a `TabView(.page)` or implement swipe gesture recognizers to switch sections.

---

### 7. HIG Compliance (4/5)

The app follows Apple HIG conventions well. Navigation uses NavigationStack properly. The custom tab bar mirrors system tab bar behavior with appropriate icons (SF Symbols via HLIcon constants). Sheets use standard dismiss patterns with Cancel/Save toolbar items (visible in sleep form). The onboarding flow uses a progress indicator (Step 1 of 4 / Step 2 of 4) which is a clear convention.

The habit detail view (home_06_habit_detail.png, home_07_habit_detail_mid.png) uses proper NavigationStack with back button and more options menu -- exactly matching iOS navigation conventions.

### HIG Compliance -- Minor

**Problem:** HomeDashboardView -- Uses a custom header ("HabitLand" with timer and notification icons) via `.navigationBarTitleDisplayMode(.inline)` instead of standard `.large` title. While this is acceptable for a dashboard, it differs from every other screen that uses standard navigation titles.

**Impact:** Minor inconsistency. Not a real issue for a home/dashboard screen -- this is intentional and common in production apps.

**Fix:** No change needed. Noted for consistency tracking.

### HIG Compliance -- Minor

**Problem:** OnboardingView -- The "Skip" button on step 1 (onb_01_first_screen.png) is top-right aligned. When progressed to step 2, it changes to a "< Back" button on the top-left. This is correct navigation convention, but the "Skip" button has no equivalent on subsequent steps.

**Impact:** Users who want to skip the remaining onboarding steps after step 1 have no option to do so.

**Fix:** Consider keeping a "Skip" option available on all onboarding steps, or ensure the flow is fast enough (4 steps is already quick) that skipping is unnecessary.

---

### 8. Accessibility (3/5)

Accessibility has foundational support but critical gaps remain unchanged from v4. The positive developments:
- **Chart VoiceOver labels:** All 4 chart components now have `.accessibilityLabel()` -- this was a Critical finding in v4 and is now resolved.
- **`.accessibilityLabel()` count:** 76 occurrences across 35 files (up from 71 across an unknown count in v4).
- **`.accessibilityHidden(true)` count:** 65 occurrences across 28 files (up from 54).
- **`.accessibilityElement()` count:** 30 occurrences across 16 files -- a new category not tracked in v4.
- **`@ScaledMetric` count:** 295 occurrences across 80 files -- extensive icon scaling support.
- **Reduce Motion:** 4 files now check `accessibilityReduceMotion` (new since v4).

The critical gap remains: **zero usage of `dynamicTypeSize` environment variable** for layout adaptation.

### Accessibility -- Critical

**Problem:** All view files -- Zero usage of `@Environment(\.dynamicTypeSize)` or `.dynamicTypeSize()` modifier. The app has no layout adaptation for Accessibility text sizes.

**Impact:** Users with Accessibility XL or larger text sizes will experience overlapping text, truncated content, and broken layouts in stat rows, card layouts, and horizontal arrangements throughout the app. Specifically:
- Home stat row (33d Streak / 90% This Week) -- 2 columns will overflow
- Profile stats (35 / 109 / 33 / 8) -- 4 columns will compress to unreadable sizes
- Sleep stats (7.4h / 76% / 100%) -- 3 columns will overflow
- Friend profile stats (42 / 210 / Lvl 12) -- 3 columns will overlap
- Leaderboard podium (#2 / #1 / #3) -- horizontal layout will break
- Personal Statistics 2-column grid cards will need to become 1-column

**Fix:** Add `@Environment(\.dynamicTypeSize) private var dynamicTypeSize` to views with horizontal layouts. Use `ViewThatFits` or conditional layout:
```swift
if dynamicTypeSize.isAccessibilitySize {
    VStack { ... }
} else {
    HStack { ... }
}
```
Priority targets: HomeDashboardView, UserProfileView, SleepDashboardView, FriendProfileView, PersonalStatisticsView, LeaderboardView.

### Accessibility -- Major

**Problem:** Theme.swift:43-47 -- `hlTextTertiary` dark mode contrast is approximately 3.2:1 against `hlSurface`, below WCAG AA 4.5:1 minimum for normal text.

**Impact:** Users with low vision cannot read tertiary text in dark mode. This affects timestamps, inactive tab labels, placeholder text, and secondary labels across the entire app.

**Fix:** Change dark mode `hlTextTertiary` from `UIColor(red: 0.43, green: 0.43, blue: 0.45)` to `UIColor(red: 0.56, green: 0.56, blue: 0.58)` (#8E8E93).

### Accessibility -- Major

**Problem:** Reduce Motion support is limited to 4 files. The `.hlStaggeredAppear` modifier (used extensively in HomeDashboardView, HabitDetailView, and other screens) does not check `accessibilityReduceMotion`.

**Impact:** Users with motion sensitivity will still see staggered entry animations on most screens.

**Fix:** Update the `.hlStaggeredAppear` implementation in Effects.swift to check `@Environment(\.accessibilityReduceMotion)` and skip animations when true.

### Accessibility -- Minor

**Problem:** OnboardingView avatars/emojis (onb_02_name_entry.png) render as "?" in simulator screenshots. If this also occurs on some physical devices (older iOS versions, certain locales), users get no meaningful content.

**Impact:** Broken visual experience for affected users.

**Fix:** Add fallback SF Symbol alternatives for critical emoji usage, or verify emoji rendering across all supported iOS versions.

---

## Domain Deep Dives

### Home Domain
**Screenshots reviewed:** home_01_top.png, home_02_mid.png, home_03_bottom.png, home_04_notifications.png, home_05_create_sheet.png, home_06_habit_detail.png, home_07_habit_detail_mid.png, home_08_habit_detail_bottom.png, onb_05_home_empty.png, onb_06_home_confirmed.png
**Files analyzed:** HomeDashboardView.swift, DailyHabitsOverview.swift, PomodoroView.swift, WeeklyProgressView.swift, StreakSummaryView.swift, InsightsOverviewView.swift, HabitChainView.swift, HabitTimerView.swift
**Domain score:** 34/40

The home dashboard is the strongest screen in the app. The simplified layout (v4 removed "Track to Transform" and "Weekly Insight" cards) creates a cleaner information flow. The greeting ("Good morning, Alex"), level bar (LV8 with 520/800 XP), daily progress ring (80%), habit list with color-coded icons and streak badges, and compact stats row (33d Streak / 90% This Week) is immediately scannable.

The Getting Started checklist for new users (onb_05_home_empty.png) is a major improvement. The three progressive tasks create a clear path from first launch to engaged user.

The habit detail view (home_06 through home_08) is well-structured: hero icon, category badge (Health with red heart), 30-day calendar heat map, stats row (Current 24 / Best 24 / Total 25 / Rate 100%), weekly bar chart, recent completions with timestamps, and navigation to Statistics/Schedule/Notes/Reminders.

### Habits Domain
**Screenshots reviewed:** habits_01_list.png, habits_02_scrolled.png, habits_03_detail.png, habits_04_create_top.png through habits_09_archived.png
**Files analyzed:** HabitListView.swift, HabitDetailView.swift, CreateHabitView.swift, EditHabitView.swift, HabitArchiveView.swift, HabitHistoryView.swift, HabitNotesView.swift, HabitReminderView.swift
**Domain score:** 33/40

The habits list (habits_01_list.png) has excellent structure: search bar, progress summary card with circular ring, Active/Archived filter tabs, sort control, and habit cards. Each habit card shows icon, name, category, streak badge with flame, and a completion checkmark. The habit cards use consistent color-coding per habit.

NOTE: Screenshots habits_04 through habits_08 show the habits list rather than the create form due to XCUITest navigation issues. Scoring for create/edit forms is based on code inspection.

The archived state (habits_09_archived.png) correctly shows the standardized EmptyStateView component: archive icon, "No archived habits", "Archived habits will appear here." -- clean and consistent.

### Onboarding Domain
**Screenshots reviewed:** onb_01_first_screen.png, onb_02_name_entry.png, onb_03_theme.png, onb_04_trial.png, onb_05_home_empty.png, onb_06_home_confirmed.png
**Files analyzed:** OnboardingView.swift, ThemeOnboardingView.swift, OnboardingCompleteView.swift
**Domain score:** 34/40

This is the most improved domain. The 4-step flow is crisp and purposeful:

Step 1 (Welcome): Large illustration area, three feature pills (Streaks, Sleep, Analytics), bold headline, clear CTA. The progress bar shows Step 1 of 4. "Skip" is available.

Step 2 (Name): Clean text input with avatar picker. The "What's your name?" headline is direct. The subtitle explains why ("This is how your friends will see you on the leaderboard").

Step 3 (Theme): 2x3 color grid with gradient-filled circles and unique SF Symbol per theme. Selected state shows ring highlight. "You can always change this in Settings" reduces pressure.

Step 4 (Trial): Crown icon, "7 Days of Pro On Us!" headline, feature checklist with green checkmarks, "Start My Free Trial" CTA. Clean and compelling.

The transition to the empty home state (onb_05_home_empty.png) maintains continuity with the "7 Days of Pro -- Free!" banner at the top and the Getting Started checklist.

### Sleep Domain
**Screenshots reviewed:** sleep_01_dashboard.png through sleep_09_analytics_scrolled.png
**Files analyzed:** SleepDashboardView.swift, LogSleepView.swift, SleepHistoryView.swift, SleepAnalyticsView.swift, SleepInsightsView.swift
**Domain score:** 34/40

The sleep domain remains one of the strongest. The dashboard (sleep_01_dashboard.png) has a clean hierarchy: Last Night card (7h 42m with bedtime/wake time), weekly bar chart, 3-column stats (7.4h Avg / 76% Quality / 100% Consistency), Sleep Insights link, and sticky "Log Sleep" CTA.

The Log Sleep form (sleep_03 through sleep_05) is well-redesigned. The "Import from Apple Health" button at the top is a smart shortcut. The moon icon and large duration display (8h 0m) create a clear focal point. Bedtime and Wake Time pickers use standard iOS DatePicker. The pill-style quality selectors (Terrible through Excellent) and mood selectors (Exhausted through Energized) use bordered pill buttons with purple highlight for selected state -- a clean, native-feeling interaction pattern.

Sleep History (sleep_06, sleep_07) shows daily entries with quality emoji, date, times, and duration in a clear list format. Sleep Analytics (sleep_08, sleep_09) is data-rich: 30-day duration chart, quality trend line, best/worst comparison, day-of-week averages, sleep debt, and bed vs asleep efficiency.

### Social Domain
**Screenshots reviewed:** social_01_friends.png through social_07_feed_scrolled.png
**Files analyzed:** SocialHubView.swift, FriendsListView.swift, FriendProfileView.swift, LeaderboardView.swift, SharedChallengesView.swift, SocialFeedView.swift, InviteFriendsView.swift, NudgesSheetView.swift, PendingRequestsView.swift, CreateChallengeView.swift
**Domain score:** 30/40

The social hub uses a 4-segment pill picker (Friends / Leaderboard / Challenges / Feed). The friends list (social_01_friends.png) is clean: avatar, name, level badge, streak, and activity status. The friend profile (social_03_friend_profile.png) has avatar, name, username, level badge, 3-column stats, activity status, and Nudge/Challenge action buttons.

The leaderboard (social_04_leaderboard.png) has a creative podium layout with #1 in center, #2 and #3 on sides. The crown icon on #1, time period selector (This Week / This Month / All Time), and full rankings list below are well-organized.

The activity feed (social_06, social_07) shows friend activity cards with avatar, completion message, streak badge, and like button. The monotonous template structure is the main weakness.

### Profile Domain
**Screenshots reviewed:** profile_01_top.png, profile_02_scrolled.png, profile_04_stats.png, profile_05_stats_scrolled.png
**Files analyzed:** UserProfileView.swift, PersonalStatisticsView.swift, EditProfileView.swift, AchievementsShowcaseView.swift, AvatarPickerView.swift
**Domain score:** 32/40

The profile (profile_01_top.png) has a clean layout: avatar circle, name, username, level badge, "Edit Profile" CTA, 4-column stats (Days Active / Completions / Streak / Level), Streak Shields card, Achievements showcase, and navigation links.

Personal Statistics (profile_04_stats.png) is excellent: 2-column grid of 6 stat cards (Total Completions 109, Days Active 35, Success Rate 100%, Best Streak 33, Habits Created 5, Achievements 12), monthly completions bar chart, category breakdown with color-coded progress bars, and personal records section. Well-organized and informative.

---

## Design System Health

- **Token coverage:** ~94% of views use design tokens (4,654 design system token references vs 304 `.font(.system(size:))` calls). This is up from ~92% in v4, representing meaningful improvement in design system adoption.
- **Consistency score:** High -- The `.hlCard()` modifier, `HLSpacing` constants, `HLFont` functions, and `Color.hl*` palette are used consistently. The staggered appear animation system (`.hlStaggeredAppear()`) adds consistent entry animations.
- **Missing tokens:**
  - No semantic spacing aliases (`sectionGap`, `cardGap`, `elementGap`) -- views use `HLSpacing.lg` (24) for sections and `HLSpacing.md` (16) for cards, but this is convention-based, not formalized.
  - No `dynamicTypeSize` adaptation utilities -- a `HLAdaptiveStack` that switches from HStack to VStack at accessibility sizes would centralize this pattern.
  - Icon sizing convention (`@ScaledMetric` + `min()`) is not documented in the design system files, though it is consistently applied across 80 files.
- **Recommendations:**
  1. Create an `HLAdaptiveStack` component that automatically switches layout at accessibility text sizes.
  2. Formalize the `@ScaledMetric` + `min()` icon sizing convention with documentation and potentially a helper struct.
  3. Add semantic spacing aliases for common layout gaps.
  4. Consider adding a dark mode contrast validation test to CI.

---

## Files Analyzed

### Screenshot Files (43 total)
- onb_01_first_screen.png, onb_02_name_entry.png, onb_03_theme.png, onb_04_trial.png, onb_05_home_empty.png, onb_06_home_confirmed.png
- home_01_top.png, home_02_mid.png, home_03_bottom.png, home_04_notifications.png, home_05_create_sheet.png, home_06_habit_detail.png, home_07_habit_detail_mid.png, home_08_habit_detail_bottom.png
- habits_01_list.png, habits_02_scrolled.png, habits_03_detail.png, habits_04_create_top.png, habits_05_create_mid.png, habits_06_create_bottom.png, habits_07_create_health.png, habits_08_create_reminder.png, habits_09_archived.png
- sleep_01_dashboard.png, sleep_02_scrolled.png, sleep_03_form_top.png, sleep_04_form_quality.png, sleep_05_form_mood.png, sleep_06_history.png, sleep_07_history_scrolled.png, sleep_08_analytics.png, sleep_09_analytics_scrolled.png
- social_01_friends.png, social_02_friends_scrolled.png, social_03_friend_profile.png, social_04_leaderboard.png, social_05_challenges.png, social_06_feed.png, social_07_feed_scrolled.png
- profile_01_top.png, profile_02_scrolled.png, profile_04_stats.png, profile_05_stats_scrolled.png

### Design System Files
- `/Users/azc/works/HabitLand/HabitLand/DesignSystem/Theme.swift`
- `/Users/azc/works/HabitLand/HabitLand/DesignSystem/Effects.swift`

### Screen View Files (78 files across 11 domains)
- **Home (8):** HomeDashboardView, DailyHabitsOverview, PomodoroView, WeeklyProgressView, StreakSummaryView, InsightsOverviewView, HabitChainView, HabitTimerView
- **Habits (9):** HabitListView, HabitDetailView, CreateHabitView, EditHabitView, HabitArchiveView, HabitHistoryView, HabitNotesView, HabitReminderView, HabitScheduleView, HabitStatisticsView
- **Sleep (5):** SleepDashboardView, LogSleepView, SleepHistoryView, SleepAnalyticsView, SleepInsightsView
- **Social (10):** SocialHubView, FriendsListView, FriendProfileView, LeaderboardView, SharedChallengesView, CreateChallengeView, SocialFeedView, InviteFriendsView, NudgesSheetView, PendingRequestsView
- **Profile (5):** UserProfileView, PersonalStatisticsView, EditProfileView, AchievementsShowcaseView, AvatarPickerView
- **Settings (6):** GeneralSettingsView, AppearanceSettingsView, NotificationSettingsView, DataExportView, HabitSettingsView, PrivacySettingsView
- **Premium (3):** PaywallView, PremiumGateView, LegalView
- **Analytics (5):** WeeklyAnalyticsView, MonthlyAnalyticsView, LongTermProgressView, HabitDifficultyInsightsView, HabitSuccessTrendsView
- **Discovery (5):** TemplateBrowserView, HabitDiscoveryView, HabitCategoriesView, RecommendedHabitsView, HabitPackDetailView
- **Notifications (3):** NotificationCenterView, NotificationDetailView, ReminderSettingsView
- **Onboarding (6):** OnboardingView, ThemeOnboardingView, OnboardingCompleteView, HabitPreferenceView, NotificationSetupView, StarterHabitsView, GoalSetupView
- **Gamification (5):** AchievementsView, MilestonesView, RewardsView, StreakOverviewView, LevelProgressView

### Component Files
- Cards: HabitCard, AchievementCard, SleepCard, StreakCard, ProgressCard
- Common: EmptyStateView, HLButton, LoadingView, SectionHeader
- Navigation: TabBarView, HeaderView, FloatingActionButton
- Social: FriendCard, LeaderboardRow, ChallengeCard, AvatarView
- Inputs: HLTextField, HLSlider, HLTimePicker, HLToggle
- Analytics: CircularProgressRing, WeeklyChart, SleepQualityGraph, HabitAnalyticsGraph
- Gamification: AchievementBadge, LevelBadge, MilestoneBadge, StreakFlame
- Other: AmbientSoundPicker, ReferralCodeEntryView, UndoToast

### Quantitative Code Metrics
| Metric | v4 | v5 | Delta |
|--------|-----|-----|-------|
| Design system token references | 3,428 | 4,654 | +1,226 (+36%) |
| `.font(.system(size:))` occurrences | 298 | 304 | +6 |
| `.accessibilityLabel()` occurrences | 71 | 76 | +5 |
| `.accessibilityHidden(true)` occurrences | 54 | 65 | +11 |
| `.accessibilityElement()` occurrences | N/A | 30 | new |
| `@ScaledMetric` occurrences | N/A | 295 | tracked |
| `.minimumScaleFactor()` occurrences | 21 | 29 | +8 |
| `.refreshable` occurrences | 5 | 5 | 0 |
| `dynamicTypeSize` occurrences | 0 | 0 | 0 |
| `accessibilityReduceMotion` occurrences | 0 | 4 | +4 |
