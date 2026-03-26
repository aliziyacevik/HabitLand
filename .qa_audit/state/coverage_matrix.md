# Coverage Matrix — QA Audit v6 (2026-03-25)

## Runtime Coverage: 30+ screens tested | Code Audit: Complete

| Screen | Pro Test | Free Test | Screenshot | Notes |
|--------|---------|-----------|------------|-------|
| Home Dashboard | Pass | Pass | Y | Clean, all habit cards visible, progress ring |
| Home (scrolled) | Pass | - | Y | Streak summary, weekly stats |
| Notifications | Pass | - | Y | Empty state: "All Caught Up!" |
| Habit Detail | Pass | - | Y | 30-day heatmap, streak stats, weekly chart |
| Habit Detail (scrolled) | Pass | - | Y | Completions, Statistics, Schedule, Notes, Reminders links |
| Habit Edit | Pass | - | Y | Edit form opens from detail (via Edit button) |
| Habits List | Pass | Pass | Y | Summary header, Active/Archived filter, sort |
| Habits List (scrolled) | Pass | - | Y | |
| Habits Archived Filter | Pass | - | - | Tab switch works |
| Habits Sort Menu | Pass | - | Y | Custom/Name/Streak/Category/Newest options |
| Create Habit (Habits FAB) | Pass | - | Y | Browse Templates, name, icon, color, category, frequency |
| Create Habit (scrolled) | Pass | - | Y | Goal, reminder sections |
| Habit Detail from List | Pass | - | Y | Push navigation works |
| Sleep Dashboard | Pass | - | Y | Last Night card, This Week chart, stats row |
| Sleep Dashboard (scrolled) | Pass | - | Y | Insights, Sleep & Habits correlation |
| Sleep Premium Gate | - | Pass | Y | Blur overlay, lock icon, "Upgrade to Pro" |
| Log Sleep | Pass | - | Y | Duration, bedtime/wake, quality picker |
| Log Sleep (scrolled) | Pass | - | Y | Morning mood, notes |
| Profile | Pass | Pass | Y | Avatar, name, level badge, stats row, achievements |
| Profile (scrolled) | Pass | - | Y | Quick links: Statistics, Achievements, Share |
| Edit Profile | Pass | - | Y | Name, username, bio fields, Save Changes |
| Personal Statistics | Pass | - | Y | All-time stats, monthly chart, category breakdown |
| Personal Statistics (scrolled) | Pass | - | Y | Personal records |
| Personal Statistics Lock | - | Pass | Y | PRO badge on link, contextual paywall sheet |
| Achievements | Pass | - | Y* | Navigated via section header (partial) |
| Settings | - | Pass | Y | Full settings list visible |
| Settings "Upgrade to Pro" | - | Pass | Y | Crown icon, PRO badge |
| Paywall (from Settings) | - | Pass | Y | Feature list, plans (Yearly/Lifetime) |
| Paywall (from Habit Limit) | - | Pass | Y | FAB opens paywall when >= 3 active habits |
| Free Tier Banner | - | Pass | Y | "Habit limit reached" + Upgrade button |
| Onboarding (free) | - | Pass | - | Completed: pages, name, theme, pro offer |
| Final State | Pass | Pass | Y | |

## Flow Coverage

| Flow | Status | Notes |
|------|--------|-------|
| App launch (screenshotMode) | Pass | Seeded data loads, onboarding skipped |
| App launch (free user) | Pass | Onboarding shown and completed |
| Onboarding: pages -> name -> theme -> pro offer -> dismiss | Pass | "Maybe Later" completes onboarding |
| All 4 tab switches | Pass | No blocking popups |
| Habit card -> detail -> edit -> back | Pass | Full navigation chain |
| Create habit (Habits FAB) | Pass | Opens and dismisses |
| Create habit (FAB at limit) | Pass | Opens paywall (not alert) |
| Sleep log form | Pass | Full form visible |
| Premium gate (Sleep) | Pass | Blur + lock + CTA |
| Premium gate (Statistics) | Pass | PRO badge + paywall sheet |
| Settings -> Upgrade to Pro -> Paywall | Pass | Sheet presentation |
| Settings sub-screens | Partial | Tested in free user flow only |

## Premium Gate Coverage

| Gate | Free User | Pro User |
|------|-----------|----------|
| Sleep Tab | Blurred + lock + "Upgrade to Pro" | Full content |
| Personal Statistics | Lock + PRO badge -> paywall | Full stats |
| Settings "Upgrade to Pro" | Visible with crown icon | Hidden |
| Habit Limit (3 active) | FAB opens paywall | Unlimited |
| Tab bar crown icon | Shows on Sleep tab | Not shown |

## Code Audit Summary

| Category | Status | Notes |
|----------|--------|-------|
| Force unwraps | 3 in CloudKitManager (guarded) | CloudKit disabled, low risk |
| Division by zero | 1 potential (levelProgress) | Level defaults to 1, very low risk |
| Missing save() | None found | All mutations followed by save() |
| Hardcoded fonts | 0 | All use `min(scaledMetric, cap)` pattern |
| Stale social references | 1 (PremiumGateView "friends connected") | Conditional, only shows if Friend data exists |
| Stale trial references | Tests only (FIXED) | Removed stale test functions |

## Uncovered Areas

- Settings sub-screens (Appearance, Habit Settings, Notifications, Data & Export) in Pro mode
- Onboarding in Pro mode (screenshotMode skips onboarding)
- Template browser flow
- Habit history / statistics sub-screens
- Achievement showcase detail view
