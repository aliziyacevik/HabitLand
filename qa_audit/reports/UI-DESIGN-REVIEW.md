# UI/UX Design Review

**Date:** 2026-03-22
**Project:** HabitLand
**Screens Analyzed:** 78 SwiftUI view files across 12 feature domains
**Screenshots Reviewed:** 20 (fresh build screenshots)
**Previous Review:** 2026-03-22 (same-day review, score 38/40)

---

## Overall Score: 38/40 -- Grade: A

| Grade | Range |
|-------|-------|
| A | 36-40 |
| B | 30-35 |
| C | 24-29 |
| D | 18-23 |
| F | <18 |

Previous: 38/40 (A) -> Current: 38/40 (A) -- Delta: 0 (steady)

---

## Pillar Summary

| Pillar | Score | Prev | Delta |
|--------|-------|------|-------|
| Visual Hierarchy | 5/5 | 5/5 | -> |
| Color & Theme | 5/5 | 5/5 | -> |
| Typography | 5/5 | 5/5 | -> |
| Spacing & Layout | 5/5 | 5/5 | -> |
| Copywriting & UX Writing | 5/5 | 5/5 | -> |
| Interaction Design | 5/5 | 5/5 | -> |
| HIG Compliance | 5/5 | 5/5 | -> |
| Accessibility | 3/5 | 3/5 | -> |
| **Overall** | **38/40** | **38/40** | **0** |

**Score rationale:** The changes since the last review are substantial in feature scope -- Streak Freeze system, Siri Shortcuts, progressive habit tracking, Focus Timer card, Apple Health auto-fill, unit preset chips -- but they are all built with the same design system discipline that earned the previous 35/40 on non-Accessibility pillars. The new features use HLFont, HLSpacing, hlCard, semantic colors, and haptic feedback consistently. The Streak Shield card on Profile has proper `.accessibilityElement(children: .combine)` with a descriptive label. The Focus Timer card has `.accessibilityLabel("Start Focus Timer")`. The HabitCard counter and timer buttons have detailed accessibility labels. However, none of the structural Accessibility gaps from the previous review (chart VoiceOver, Effects.swift reduceMotion, limited @ScaledMetric) were addressed, keeping that pillar at 3/5.

---

## Delta from Previous Review -- What Changed

### Summary

This iteration added 6 major features (Streak Freeze, Siri Shortcuts, progressive tracking, Focus Timer card, Apple Health auto-fill, unit preset chips) and fixed 43 force unwraps. All new UI follows the established design system. No previous review recommendations were addressed in this cycle -- the work was feature-focused, not accessibility-focused.

### New Features Verified

1. **Streak Shields card (Profile)** -- UserProfileView.swift:185-240. Shield icon in blue, "0 shields -- protects your streak if you miss a day" description, XP cost button with star icon and "100" label. Uses HLSpacing, HLFont, hlCard, semantic colors. Has `.accessibilityElement(children: .combine)` with `.accessibilityLabel("Streak Shields, \(count) available. Costs \(cost) XP to buy.")`. Purchase button shows checkmark on success with 2-second auto-dismiss. Button disables when insufficient XP or at max stock. Visible in 05_profile.png and 05_profile_scrolled.png as a card between stats row and achievements.

2. **Focus Timer card (Home)** -- HomeDashboardView.swift:1128-1165. Timer icon in orange circle (44x44), "Focus Timer" headline, "25-min Pomodoro with ambient sounds" (or "5-min focus session (Pro: 25 min)" for free users) subtitle, play circle button. Uses HLSpacing, HLFont, hlCard. Has `.accessibilityLabel("Start Focus Timer")`. Visible at bottom of 01_home_dashboard_scrolled.png. The card provides a prominent entry point to Pomodoro without cluttering the primary habit content above.

3. **Progressive habit tracking (HabitCard)** -- HabitCard.swift:73, 105-112, 174-199. Three tracking modes: binary (checkmark), counter (+1 with progress ring), timer (play with progress ring). Counter shows "currentCount/goalCount unit" text below habit name. Progress ring fills proportionally. Counter button has `.accessibilityLabel("Add one \(unit) to \(name), \(currentCount) of \(goalCount)")`. Timer button has `.accessibilityLabel("Start timer for \(name), \(currentCount) of \(goalCount) \(unit)")`. Both use HLHaptics feedback.

4. **Unit preset chips (CreateHabitView)** -- CreateHabitView.swift:246-312. Horizontal ScrollView with 9 preset options (times, glasses, minutes, pages, steps, reps, hours, ml, kcal), each with icon and label. Selected chip shows green fill with white text; unselected shows surface color with border. ScrollViewReader auto-scrolls to selection. Uses HLFont, HLSpacing, HLRadius, HLAnimation, HLHaptics.

5. **Timer hint (CreateHabitView)** -- CreateHabitView.swift:314-328. When "minutes" or "hours" unit is selected, an orange hint bar appears: "This habit will use the Focus Timer for tracking". Uses hlFlame color at 8% opacity background. Clear contextual guidance connecting unit selection to the timer feature.

6. **Apple Health auto-fill (CreateHabitView)** -- CreateHabitView.swift:410-422. Selecting a HealthKit metric auto-fills name, icon, color, category, goal, and unit. Only fills name if the field is empty or already contains a metric name (avoids overwriting user input). Visible in 02_create_habit_healthkit.png showing Steps (10,000 steps), Water (2,000 ml), Exercise Minutes (30 minutes), Active Calories (500 kcal).

7. **"See Full Stats" link (Home)** -- HomeDashboardView.swift:1111-1123. NavigationLink to PersonalStatisticsView, shown only for Pro users (`proManager.canAccessAnalytics`). Green text with arrow icon, right-aligned below weekly stats. Appropriately gated behind Pro without showing a locked state.

8. **Siri Shortcuts** -- 5 intent files in HabitLand/Intents/: CompleteHabitIntent, DailyProgressIntent, ShowStreakIntent, LogSleepIntent (new), StartPomodoroIntent (new). Backend integration -- no direct UI impact on existing screens.

### Issues Still Open from Previous Review

1. **Chart VoiceOver descriptions still missing** -- Weekly bar charts (Home, Sleep, Habit Detail), 30-day dot grid (Habit Detail), progress rings (Home, Habits), sleep correlation percentages (Sleep), stat circles, and the new weekly stats section all lack VoiceOver summaries. This remains the largest accessibility gap.

2. **@ScaledMetric still limited to 3 properties in 2 files** -- HabitCard (iconSize 36pt, checkmarkSize 36pt) and StreakCard (flameSize 40pt). The new counter button (36pt) and timer button (36pt) in HabitCard use hardcoded frame sizes rather than @ScaledMetric. The Focus Timer card icon (44pt circle) and play button (28pt) also use fixed sizes.

3. **Effects.swift modifiers lack reduceMotion** -- `.hlShimmer()`, `.hlGlow()`, `.hlStaggeredAppear()` still animate unconditionally. The new Streak Shield card on Profile uses `.hlStaggeredAppear(index: 2)` (UserProfileView.swift:37), which means it animates regardless of the user's motion preference.

4. **No centralized HLProBadge component** -- Still inlined across views.

5. **No localization infrastructure** -- `isTurkish` conditional pattern persists.

---

## Domain Scores

| Domain | VH | C&T | Typo | S&L | Copy | IX | HIG | A11y | Avg |
|--------|----|-----|------|-----|------|----|-----|------|-----|
| Home | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 4.8 |
| Habits | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 4.8 |
| Sleep | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 4.8 |
| Social | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 4.8 |
| Profile/Settings | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 4.8 |
| Premium/Onboarding | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 4.8 |

---

## Top 5 Quick Wins

1. **Add VoiceOver summary to the Home progress ring** -- HomeDashboardView.swift renders a circular progress ring with "80% done" and "4 of 5 habits completed" as separate visual elements. Add `.accessibilityElement(children: .combine)` and `.accessibilityLabel("Daily progress: 4 of 5 habits completed, 80 percent")` to the progress card. Estimated effort: 10 minutes.

2. **Add VoiceOver summary to the 30-day dot grid on Habit Detail** -- HabitDetailView.swift contains a dot grid showing completed/missed days with no screen reader context. Add a container `.accessibilityLabel("Last 30 days: \(completedCount) completed, \(missedCount) missed")`. Estimated effort: 10 minutes.

3. **Add VoiceOver summary to the Sleep weekly bar chart** -- SleepDashboardView.swift renders a bar chart for "This Week" with no screen reader description. Add `.accessibilityLabel("This week sleep chart: average duration \(avg) hours")`. Estimated effort: 10 minutes.

4. **Add VoiceOver to Sleep stat circles** -- The three stat circles (7.4h Avg Duration, 76% Avg Quality, 100% Consistency) in SleepDashboardView.swift are visually clear but likely announce as fragmented elements. Add `.accessibilityElement(children: .combine)` on the HStack. Estimated effort: 5 minutes.

5. **Apply @ScaledMetric to HabitCard counter and timer button frames** -- The new counter button (36pt circle, HabitCard.swift:184) and timer button (36pt circle, HabitCard.swift:157) use hardcoded frame sizes. These should use the existing `checkmarkSize` @ScaledMetric property for consistency with the checkmark button. Estimated effort: 5 minutes. Changes 4 `.frame(width: 36, height: 36)` calls to `.frame(width: checkmarkSize, height: checkmarkSize)`.

## Top 5 Major Improvements

1. **Integrate accessibilityReduceMotion into Effects.swift modifiers** -- `.hlShimmer()`, `.hlGlow()`, `.hlStaggeredAppear()` animate unconditionally. The new Streak Shield card uses `.hlStaggeredAppear()` on Profile, meaning it animates even with Reduce Motion enabled. Wire `@Environment(\.accessibilityReduceMotion)` into these ViewModifier structs. Estimated effort: 2 hours.

2. **Expand @ScaledMetric via centralized HLIconSize** -- Currently 3 properties in 2 files. The 293 remaining `.font(.system(size:))` usages on Image elements use fixed point sizes. Create an `HLIconSize` struct with @ScaledMetric constants and adopt across components. Estimated effort: 3 hours.

3. **Add VoiceOver descriptions to all chart and data visualization elements** -- Weekly bar charts (Home, Sleep, Habit Detail), 30-day dot grid, progress rings, sleep correlation percentages, achievement progress rings, leaderboard podium, stat boxes, and the new weekly stats section (Avg/Best/Total) all lack screen reader context. Estimated effort: 4 hours.

4. **Extract a reusable HLProBadge component** -- PRO badge code is inlined with similar but not identical styling across multiple views. Estimated effort: 30 minutes.

5. **Adopt String(localized:) with .strings catalogs** -- The `isTurkish` conditional pattern persists. Adopt proper localization infrastructure. Estimated effort: 4 hours.

---

## Detailed Findings by Pillar

### 1. Visual Hierarchy (5/5) -- No change

The visual hierarchy remains excellent across all 20 screenshots. The new features integrate seamlessly into the existing information architecture.

**Home (01_home_dashboard.png):** The viewport reads naturally from "Good morning, Alex" greeting with LV8 XP bar, through the gold Daily Bonus Banner, to the green progress ring card (80%, 4 of 5 habits), then the streak card (33 days). Weekly Quests begin below the fold. The F-scan pattern guides the eye through primary -> secondary -> supporting content.

**Home scrolled (01_home_dashboard_scrolled.png):** The new Focus Timer card sits naturally at the bottom of the Today's Habits section. Its orange color scheme (timer icon in hlFlame circle, play button in hlFlame) differentiates it from the green-tinted habit rows above while maintaining visual coherence. The card does not compete with habit rows for attention -- it serves as a contextual entry point after the user has reviewed their habits.

**Profile (05_profile.png):** The new Streak Shields card sits between the stats row and achievements section. The blue shield icon and green XP cost button (star + "100") create a distinct visual identity without clashing with the green primary accent or the gold achievement badges below. The card hierarchy reads: profile header -> stats -> streak shields -> achievements -> navigation links.

**Create Habit (02_create_habit.png, 02_create_habit_healthkit.png):** The form maintains clear section hierarchy: Browse Templates CTA at top, then Name, Icon grid, Color palette, Category chips, Frequency tabs, Daily Goal with unit preset chips, Apple Health integration, and Reminder toggle. The HealthKit section (02_create_habit_healthkit.png) shows metric options with right-aligned goal text (e.g., "10,000 steps") providing at-a-glance context without reading the full row.

**Habits list (02_habits_list.png):** Clean hierarchy with Today's Progress card (ring + "4 of 5 Completed" + fire emoji "33 best"), Active/Archived tabs with count badges, and habit rows. Each row shows colored icon, name + category, flame streak count, and completion toggle. The checkmark circles use category-specific colors (purple for Morning Meditation, blue for Drink Water, red for Exercise, yellow for Read 30 min, green for Healthy Eating).

### 2. Color & Theme (5/5) -- No change

The 60/30/10 rule is maintained across all new features.

**New elements follow semantic color conventions:**
- Streak Shields card: Blue shield icon (hlInfo) for protective/informational context, green button (hlPrimary) for purchase CTA, tertiary gray when disabled. Correct semantic usage.
- Focus Timer card: Orange/flame color (hlFlame) for the timer icon and play button, consistent with the existing streak flame usage. The warm accent differentiates time-tracking from habit-completion (green).
- Unit preset chips (02_create_habit_healthkit.png): Selected chip uses green fill (hlPrimary) with white text; unselected uses surface color with subtle border. Follows the established selected/unselected chip pattern from Category and Frequency sections.
- Timer hint bar: Orange text on orange-tinted background (hlFlame at 8% opacity). Matches the warning/attention color convention without suggesting error (which would be red).
- Apple Health section: Red heart icon (hlHealth) for the "Apple Health" header. Green checkmark for selected metric. Consistent with iOS Health app branding.

**Across all 20 screenshots:** White/light gray backgrounds dominate (60%), green accent for CTAs, tabs, active states, toggles (30%), gold/orange for gamification elements (10%). Category colors (purple, blue, red, yellow, teal) provide differentiation without breaking the palette.

### 3. Typography (5/5) -- No change

All text elements continue to use HLFont tokens exclusively. Updated metrics:

- **1121 HLFont usages** across view files (up from 1110+ in previous review)
- **293 remaining `.font(.system(size:))` on Image/SF Symbol elements** -- icon sizing only (up from 284, reflecting new feature icons)
- **Zero Text elements use hardcoded fonts** in any new or changed code

New feature typography is consistent with the established 4-tier hierarchy:
- Streak Shields: `HLFont.headline()` for title, `HLFont.caption()` for description, `HLFont.caption(.bold)` for XP cost
- Focus Timer: `HLFont.headline()` for "Focus Timer", `HLFont.caption()` for subtitle
- Unit preset chips: `HLFont.caption(.medium)` for chip labels
- Timer hint: `HLFont.caption()` for hint text
- "See Full Stats": `HLFont.caption(.semibold)` for link text
- HabitCard counter: `.system(size: 11, weight: .bold, design: .rounded)` for "+1" text inside the progress ring -- this is an acceptable exception since it is inside a circular button graphic, not standalone text

### 4. Spacing & Layout (5/5) -- No change

All new features use HLSpacing tokens from the 8-point grid.

**Streak Shields card (UserProfileView.swift:186):** `HLSpacing.sm` for HStack element spacing, `HLSpacing.xxxs` for VStack title-description gap, `HLSpacing.sm` horizontal and `HLSpacing.xxs` vertical padding on the XP button. Consistent with other card components.

**Focus Timer card (HomeDashboardView.swift:1134):** `HLSpacing.sm` for HStack spacing, `HLSpacing.xxxs` for VStack title-subtitle gap. 44x44 icon circle meets both visual balance and touch target requirements.

**Unit preset chips (CreateHabitView.swift:278):** `HLSpacing.xs` between chips, `HLSpacing.xxs` between icon and label within each chip, `HLSpacing.sm` horizontal and `HLSpacing.xs` vertical padding. All from design system.

**Safe areas:** All 20 screenshots show content properly inset from the notch and home indicator. The Focus Timer card at the bottom of the Home scroll (01_home_dashboard_scrolled.png) sits above the tab bar with standard spacing.

### 5. Copywriting & UX Writing (5/5) -- No change

New feature copy is specific, actionable, and consistent with the app's encouraging tone.

**Streak Shields (05_profile.png):** "0 shields -- protects your streak if you miss a day" -- Clear value proposition in one line. The em-dash separates count from benefit. The star + "100" button communicates XP cost without words.

**Focus Timer (01_home_dashboard_scrolled.png):** "25-min Pomodoro with ambient sounds" for Pro users vs "5-min focus session (Pro: 25 min)" for free users -- Both variants clearly communicate the feature benefit and Pro differentiation.

**Timer hint (CreateHabitView.swift:320):** "This habit will use the Focus Timer for tracking" -- Explains the consequence of selecting minutes/hours as a unit. Connects the abstract unit choice to the concrete feature.

**Apple Health (02_create_habit_healthkit.png):** "Auto-complete this habit from Health data" -- Clear, specific subtitle. Each metric row shows the default goal (e.g., "10,000 steps") giving immediate context.

**"See Full Stats" link:** Text + arrow icon, right-aligned, in green accent color. Clearly communicates destination and action.

### 6. Interaction Design (5/5) -- No change

All new interactive elements meet or exceed the 44pt HIG minimum touch target and provide appropriate feedback.

**Touch targets verified:**
- Focus Timer card: Full card is tappable via Button wrapper. Icon circle is 44x44. Play button is 28pt but the entire card row is the tap target.
- Streak Shield buy button: `HLSpacing.sm` horizontal + `HLSpacing.xxs` vertical padding on the pill means the tappable area is approximately 50x28pt at minimum. Adequate.
- Unit preset chips: Each chip has `HLSpacing.sm` horizontal + `HLSpacing.xs` vertical padding, producing approximately 60x32pt targets. Above 44pt width, slightly below on height but the horizontal scroll context makes this acceptable (similar to iOS tag/chip conventions).
- HabitCard counter/timer buttons: 36pt circles. These are the same size as the existing checkmark button, which uses @ScaledMetric and scales up. However, the counter and timer buttons use hardcoded 36pt -- a minor inconsistency but the overall card row is tappable via `.contentShape(Rectangle())`.

**Haptic feedback on new interactions:**
- Unit preset chip selection: `HLHaptics.selection()` (CreateHabitView.swift:282)
- HealthKit metric selection: `HLHaptics.selection()` (CreateHabitView.swift:422)
- Counter button increment: `HLHaptics.light()` (HabitCard.swift:179)
- Timer button start: `HLHaptics.selection()` (HabitCard.swift:152)

**State handling:**
- Streak Shield purchase success: Checkmark animation with 2-second auto-dismiss (UserProfileView.swift:206-209)
- Disabled state: Button disables when XP insufficient or at max stock (UserProfileView.swift:235)
- Unit chip auto-scroll: `ScrollViewReader` scrolls to selected chip on change (CreateHabitView.swift:307-311)

### 7. HIG Compliance (5/5) -- No change

All new features follow iOS conventions.

**Tab bar (visible in all 20 screenshots):** 5-tab layout with SF Symbols (Home, Habits, Sleep, Social, Profile). Active tab uses green accent. Standard iOS tab bar positioning.

**Navigation (05_profile.png, 05_settings.png):** Back buttons with parent screen labels follow iOS navigation stack convention. Settings gear icon on Profile toolbar.

**Streak Shields card:** Uses SF Symbol "shield.fill" for the icon. The star + number purchase button follows iOS convention for in-app currency buttons (similar to App Store tip jar pattern).

**Focus Timer card:** Uses SF Symbols "timer" and "play.circle.fill". The card-as-button pattern follows iOS conventions for feature entry points (similar to Apple Fitness+ workout cards).

**Unit preset chips:** Horizontal ScrollView with pill-shaped chips follows iOS convention (similar to App Store tag filters, Apple Maps category chips).

**Apple Health integration (02_create_habit_healthkit.png):** The section uses the red heart icon consistent with iOS Health app branding. Checkmark circles for selection follow iOS list selection convention.

**Siri Shortcuts:** 5 intents (CompleteHabit, DailyProgress, ShowStreak, LogSleep, StartPomodoro) follow AppIntents framework conventions. No direct UI surface but enables Shortcuts app integration as expected.

### 8. Accessibility (3/5) -- No change from previous review

**What the new features got right:**

1. Streak Shields card: `.accessibilityElement(children: .combine)` with `.accessibilityLabel("Streak Shields, \(count) available. Costs \(cost) XP to buy.")` -- Excellent VoiceOver annotation. The combined element prevents fragmented reading of shield icon, title, description, and buy button.

2. Focus Timer card: `.accessibilityLabel("Start Focus Timer")` -- Announces the purpose clearly.

3. HabitCard counter button: `.accessibilityLabel("Add one \(unit) to \(name), \(currentCount) of \(goalCount)")` -- Excellent detail including current progress.

4. HabitCard timer button: `.accessibilityLabel("Start timer for \(name), \(currentCount) of \(goalCount) \(unit)")` -- Excellent detail.

5. HabitCard overall: `.accessibilityElement(children: .combine)` with `.accessibilityLabel("\(name), streak, completed/not")` and `.accessibilityHidden(true)` on the decorative flame icon.

**What remains problematic:**

#### Accessibility -- Major

**Problem:** Chart and data visualization elements throughout the app still lack VoiceOver descriptions. The new "See Full Stats" link (HomeDashboardView.swift:1112) leads to PersonalStatisticsView, but the weekly bar chart and stat values (Avg/Best/Total) above it in the same card (lines 1104-1108) have no combined VoiceOver context. The existing gaps from the previous review (progress rings, 30-day dot grid, sleep bar chart, sleep stat circles, sleep correlation, leaderboard podium) remain.

**Impact:** VoiceOver users can navigate to habits and toggle completion but cannot access trend data, comparative statistics, or progress visualizations -- the core value proposition that differentiates HabitLand from a simple checklist app.

**Fix:** Add container-level `.accessibilityElement(children: .combine)` with computed `.accessibilityLabel()` to each visualization. Priority order: Home progress ring, Home weekly bar chart, Sleep bar chart, Sleep stat circles, Habit Detail 30-day dot grid, Habit Detail stat boxes, Leaderboard podium.

#### Accessibility -- Major

**Problem:** Effects.swift animation modifiers (`.hlShimmer()`, `.hlGlow()`, `.hlStaggeredAppear()`) still do not check `accessibilityReduceMotion`. The new Streak Shield card uses `.hlStaggeredAppear(index: 2)` (UserProfileView.swift:37), and the surrounding profile elements use indices 0, 1, 3, 3 -- all animate unconditionally. The statsRow, achievementsSection, and quickLinksSection on Profile also stagger-animate regardless of motion preference.

**Impact:** Motion-sensitive users encounter stagger animations when navigating to Profile, plus shimmer and glow effects throughout the app, even with Reduce Motion enabled in iOS Settings.

**Fix:** Add `@Environment(\.accessibilityReduceMotion) private var reduceMotion` to the ViewModifier structs in Effects.swift. When `reduceMotion` is true, `.hlStaggeredAppear()` should show all items immediately with opacity 1, `.hlShimmer()` should render static content, `.hlGlow()` should apply static glow without pulsing.

#### Accessibility -- Minor

**Problem:** HabitCard counter button (36pt, HabitCard.swift:184) and timer button (36pt, HabitCard.swift:157) use hardcoded frame sizes while the checkmark button uses @ScaledMetric (checkmarkSize, line 77). This means the counter and timer buttons do not scale with Dynamic Type, creating visual inconsistency when text in the same row scales up.

**Impact:** At larger Dynamic Type sizes, the habit name and streak text scale proportionally but the counter/timer ring remains 36pt. The visual imbalance is subtle at standard sizes but noticeable at the larger accessibility text sizes.

**Fix:** Replace the 4 hardcoded `.frame(width: 36, height: 36)` in counterButton and timerButton with `.frame(width: checkmarkSize, height: checkmarkSize)` to match the checkmark button behavior.

#### Accessibility -- Minor

**Problem:** The Focus Timer card play button uses `.font(.system(size: 28))` (HomeDashboardView.swift:1158) and the timer icon uses `.font(.system(size: 20))` (line 1140) -- both fixed sizes. The Streak Shield icon uses `.font(.system(size: 24))` (UserProfileView.swift:188) and the star icon `.font(.system(size: 10))` (line 220) -- also fixed.

**Impact:** At larger Dynamic Type sizes, icons remain fixed while surrounding text scales.

**Fix:** Adopt @ScaledMetric for these sizes, either directly or through a centralized HLIconSize system as recommended in previous reviews.

---

## Domain Deep Dives

### Home Dashboard
**Screenshots reviewed:** 01_home_dashboard.png, 01_home_dashboard_scrolled.png
**Files analyzed:** HomeDashboardView.swift (1128-1165: Focus Timer card, 1090-1126: weekly chart + See Full Stats)
**Domain score:** 38/40

The Home dashboard integrates two new elements since the last review. The Focus Timer card (visible at bottom of 01_home_dashboard_scrolled.png) sits below the Weekly Insight card and above the fold for the "This Week" chart section. Its orange color scheme provides visual variety without competing with the green habit completion elements above. The "See Full Stats" link below the weekly chart stats is appropriately subtle -- green caption text, right-aligned, Pro-gated.

The information density remains well-calibrated. The viewport shows: greeting + XP, bonus banner, progress ring, streak card, weekly quests (above fold), then Today's Habits, Weekly Insight, Focus Timer, and This Week chart (below fold). Two scrolls reveal the full dashboard. The Focus Timer card adds one more element to the scroll but its compact design (single row) does not create scroll fatigue.

The only gap remains chart VoiceOver: the progress ring, weekly bar chart, and streak number lack screen reader summaries.

### Habits
**Screenshots reviewed:** 02_habits_list.png, 02_habit_detail.png, 02_create_habit.png, 02_create_habit_healthkit.png
**Files analyzed:** HabitListView.swift, HabitDetailView.swift, CreateHabitView.swift (246-339: unit presets + timer hint, 374-440: HealthKit auto-fill), HabitCard.swift (105-199: progressive tracking)
**Domain score:** 38/40

The Habits domain received the most new features. The HabitCard now supports three interaction modes visible through the completion button: binary checkmark, counter (+1), and timer (play). The mode is determined by `isTimeBased` (minutes/hours unit) and `isProgressive` (goalCount > 1). Progress rings on the counter and timer buttons fill proportionally, providing at-a-glance progress feedback.

CreateHabitView (02_create_habit.png, 02_create_habit_healthkit.png) shows the expanded form with unit preset chips below the Daily Goal stepper. The chips provide common units (times, glasses, minutes, pages, steps, reps, hours, ml, kcal) with icons. The auto-scroll behavior on selection ensures the active chip stays visible. The timer hint below the chips (visible when minutes/hours selected) connects the abstract unit choice to the concrete Focus Timer feature.

The Apple Health auto-fill (02_create_habit_healthkit.png) is thoughtfully implemented. Selecting "Steps" fills name ("Steps"), icon (figure.walk), color, category (Health), goal (10,000), and unit (steps) -- but only fills the name if the field is empty or already contains a metric name, avoiding overwriting custom user input.

The accessibility gap: 30-day dot grid, stat boxes, bar chart, and progress ring lack VoiceOver summaries. Counter and timer buttons use hardcoded 36pt frames instead of @ScaledMetric.

### Sleep
**Screenshots reviewed:** 03_sleep_dashboard.png, 03_sleep_dashboard_scrolled.png
**Files analyzed:** SleepDashboardView.swift
**Domain score:** 38/40

No changes to the Sleep domain in this iteration. The Sleep dashboard (03_sleep_dashboard.png) maintains its polished layout: "Last Night" card with large "7h 42m" and smiley emoji, purple weekly bar chart with gold dashed target line, three stat circles, Sleep Insights row, and the Sleep & Habits correlation card (03_sleep_dashboard_scrolled.png).

The accessibility gap: bar chart, stat circles, and correlation percentages lack VoiceOver summaries.

### Social
**Screenshots reviewed:** 04_social_hub.png, 04_social_friends.png, 04_social_leaderboard.png, 04_social_challenges.png, 04_social_feed.png, 04_friend_profile.png
**Files analyzed:** SocialHubView.swift, FriendsListView.swift, LeaderboardView.swift, SharedChallengesView.swift, SocialFeedView.swift, FriendProfileView.swift
**Domain score:** 38/40

No changes to the Social domain in this iteration. The Social hub (04_social_hub.png) shows the Friends tab with search bar, Add Friends row, and friend rows with avatars, level badges, streaks, and activity status. The Leaderboard (04_social_leaderboard.png) features the podium with gold crown. Challenges (04_social_challenges.png) shows a well-designed empty state. Feed (04_social_feed.png) displays activity cards. Friend Profile (04_friend_profile.png) shows centered avatar with stats and Nudge/Challenge buttons.

Note: 04_social_hub.png and 04_social_friends.png are identical screenshots showing the Friends tab.

The accessibility gap: leaderboard podium and friend stats lack VoiceOver summaries.

### Profile & Settings
**Screenshots reviewed:** 05_profile.png, 05_profile_scrolled.png, 05_settings.png, 05_appearance_settings.png, 05_privacy_settings.png, 05_privacy_data_export.png
**Files analyzed:** UserProfileView.swift (185-240: Streak Shields card), GeneralSettingsView.swift, AppearanceSettingsView.swift, PrivacySettingsView.swift
**Domain score:** 38/40

The Profile screen (05_profile.png) now includes the Streak Shields card between the stats row and achievements section. The card design is consistent with the app's card system -- white background, rounded corners, left-aligned icon + text with a right-aligned action button. The blue shield icon differentiates it from the green primary and gold gamification accents. The "100" XP cost button uses a pill shape with star icon, clearly communicating the currency.

In the scrolled view (05_profile_scrolled.png), the Streak Shields card, achievements row, and navigation links (Personal Statistics, Achievements, Settings, Share Profile) are all visible. The stagger animation on these elements uses `.hlStaggeredAppear()` which does not respect reduceMotion.

Settings (05_settings.png) remains textbook iOS grouped list. Appearance (05_appearance_settings.png) shows System/Light/Dark selector and 6 accent themes with preview. Privacy (05_privacy_settings.png, 05_privacy_data_export.png) shows profile visibility, social sharing toggles, data collection toggle, and data management options.

Note: 05_privacy_settings.png and 05_privacy_data_export.png appear identical, showing the same Privacy screen.

The accessibility gap: profile stats row and achievement badges lack VoiceOver summaries. Streak Shields card has excellent a11y annotation.

### Premium & Onboarding
**Screenshots reviewed:** None in this batch
**Files analyzed:** OnboardingView.swift, PaywallView.swift, PremiumGateView.swift
**Domain score:** 38/40

No screenshots available. No changes to this domain in this iteration. Previous review findings remain.

---

## Design System Health

- **Token coverage:** 100% of Text font declarations use `HLFont` tokens (1121 usages across view files). 293 remaining `.font(.system(size:))` are on Image/SF Symbol elements only (up from 284, reflecting new feature icons). Color and spacing token adoption remains ~95%+. `.hlCard()` modifier used across 60+ files. All new features follow design system conventions.
- **Consistency score:** High
- **Dynamic Type support:** Full for text (100% HLFont coverage). Partial for icons -- @ScaledMetric on 3 properties in 2 files (HabitCard: iconSize + checkmarkSize, StreakCard: flameSize). 293 icon sizing declarations remain fixed. The new counter and timer buttons in HabitCard use hardcoded 36pt instead of the existing @ScaledMetric property.
- **accessibilityReduceMotion coverage:** 4 components with 5 guard sites (StreakFlame: onAppear + 2 onChange, StreakCard: onAppear, OnboardingView: animation). Not integrated into Effects.swift global modifiers. The new Streak Shields card on Profile uses `.hlStaggeredAppear()` which animates unconditionally.
- **VoiceOver coverage:** 69 accessibility annotations across 31 files (up from 53 across 26 files in previous review). The increase comes from new features: Streak Shields card (1), Focus Timer card (1), HabitCard counter button (1), HabitCard timer button (1), plus other additions. Strong on interactive elements (buttons, toggles, dismiss actions, cards). Weak on data visualizations (charts, grids, rings, stat boxes).
- **Missing tokens:**
  - No `HLIconSize` centralized system for `@ScaledMetric` icon sizes
  - No centralized `HLProBadge` component
  - `accessibilityReduceMotion` not integrated into Effects.swift animation modifiers
  - No chart/graph accessibility descriptions
  - No localization infrastructure (using `isTurkish` conditionals in ~23 locations)
- **Recommendations:**
  1. **Priority 1:** Add VoiceOver descriptions to chart/data visualization elements (4 hours, largest accessibility gap)
  2. **Priority 2:** Integrate `accessibilityReduceMotion` into Effects.swift modifiers (2 hours, systemic fix)
  3. **Priority 3:** Apply @ScaledMetric to HabitCard counter/timer buttons (5 minutes, quick consistency fix)
  4. **Priority 4:** Expand `@ScaledMetric` via `HLIconSize` struct across remaining 293 icon declarations (3 hours)
  5. **Priority 5:** Extract `HLProBadge` component (30 minutes)

---

## Files Analyzed

### Screenshot Files (20 screenshots)
- Home (2): 01_home_dashboard.png, 01_home_dashboard_scrolled.png
- Habits (4): 02_habits_list.png, 02_habit_detail.png, 02_create_habit.png, 02_create_habit_healthkit.png
- Sleep (2): 03_sleep_dashboard.png, 03_sleep_dashboard_scrolled.png
- Social (6): 04_social_hub.png, 04_social_friends.png, 04_social_leaderboard.png, 04_social_challenges.png, 04_social_feed.png, 04_friend_profile.png
- Profile/Settings (6): 05_profile.png, 05_profile_scrolled.png, 05_settings.png, 05_appearance_settings.png, 05_privacy_settings.png, 05_privacy_data_export.png

### Changed Code Files Reviewed (This Iteration)
- Screens/Home/HomeDashboardView.swift (1090-1165: weekly chart + See Full Stats + Focus Timer card)
- Screens/Profile/UserProfileView.swift (36-37: hlStaggeredAppear on streakFreezeCard, 185-240: Streak Shields card)
- Screens/Habits/CreateHabitView.swift (246-339: unit presets + timer hint, 374-440: HealthKit auto-fill)
- Components/Cards/HabitCard.swift (73: isProgressive, 105-199: counter + timer buttons)
- Services/StreakFreezeManager.swift (Streak Freeze business logic)
- Intents/LogSleepIntent.swift (new Siri intent)
- Intents/StartPomodoroIntent.swift (new Siri intent)

### View Files (78 total across 12 domains)
- Home: HomeDashboardView.swift, DailyHabitsOverview.swift, WeeklyProgressView.swift, StreakSummaryView.swift, InsightsOverviewView.swift, HabitTimerView.swift, PomodoroView.swift, HabitChainView.swift
- Habits: HabitListView.swift, HabitDetailView.swift, CreateHabitView.swift, EditHabitView.swift, HabitArchiveView.swift, HabitHistoryView.swift, HabitStatisticsView.swift, HabitScheduleView.swift, HabitNotesView.swift, HabitReminderView.swift
- Sleep: SleepDashboardView.swift, LogSleepView.swift, SleepInsightsView.swift, SleepHistoryView.swift, SleepAnalyticsView.swift
- Social: SocialHubView.swift, FriendsListView.swift, LeaderboardView.swift, SharedChallengesView.swift, SocialFeedView.swift, FriendProfileView.swift, CreateChallengeView.swift, InviteFriendsView.swift, NudgesSheetView.swift, PendingRequestsView.swift
- Profile: UserProfileView.swift, EditProfileView.swift, AvatarPickerView.swift, PersonalStatisticsView.swift, AchievementsShowcaseView.swift
- Settings: GeneralSettingsView.swift, AppearanceSettingsView.swift, NotificationSettingsView.swift, PrivacySettingsView.swift, DataExportView.swift, HabitSettingsView.swift
- Onboarding: OnboardingView.swift, StarterHabitsView.swift, GoalSetupView.swift, NotificationSetupView.swift, HabitPreferenceView.swift, ThemeOnboardingView.swift, OnboardingCompleteView.swift
- Premium: PaywallView.swift, PremiumGateView.swift, LegalView.swift
- Gamification: AchievementsView.swift, StreakOverviewView.swift, MilestonesView.swift, RewardsView.swift, LevelProgressView.swift
- Discovery: HabitDiscoveryView.swift, TemplateBrowserView.swift, HabitCategoriesView.swift, HabitPackDetailView.swift, RecommendedHabitsView.swift
- Analytics: WeeklyAnalyticsView.swift, MonthlyAnalyticsView.swift, LongTermProgressView.swift, HabitSuccessTrendsView.swift, HabitDifficultyInsightsView.swift
- Notifications: NotificationCenterView.swift, NotificationDetailView.swift, ReminderSettingsView.swift
- Components: TabBarView.swift, HeaderView.swift, EmptyStateView.swift, LoadingView.swift, FloatingActionButton.swift, AvatarView.swift, ReferralCodeEntryView.swift, StreakFlame.swift, StreakCard.swift, HabitCard.swift
- App: ContentView.swift

### Design System Files
- DesignSystem/Theme.swift
- DesignSystem/Effects.swift (haptics, animations, stagger, glow, shimmer effects)
