# Issue ID
ISSUE-006

# Title
Achievement celebration overlay blocks tab navigation and user interaction

# Category
UX / Navigation

# Severity
High

# Priority
P1

# Screen / Feature
HomeDashboardView — Achievement celebrations

# Steps to Reproduce
1. Launch app in screenshot mode (seeds data triggering achievements)
2. Achievement "Dream Catcher" celebration appears
3. Try to switch to Habits tab
4. Celebration overlay blocks interaction with tab bar

# Expected Result
Tab bar should remain interactive even when celebration overlay is showing,
OR celebration should auto-dismiss after a timeout

# Actual Result
AchievementCelebrationOverlay covers the screen and prevents tab navigation.
The "Awesome!" button must be tapped to dismiss, but if it appears during
automated navigation, the user flow is interrupted.

# Evidence
Screenshots from run 1: 02_habits_list.png shows "Dream Catcher" overlay
blocking the habits tab content. Multiple subsequent screenshots show wrong
tab content because navigation was blocked.

# Suspected Root Cause
HomeDashboardView.swift:348 — `AchievementCelebrationOverlay` covers full screen
without auto-dismiss timeout. Combined with screenshot mode seeding achievements
that immediately unlock.

# Recommended Fix
1. Add auto-dismiss timeout (3-5 seconds) to AchievementCelebrationOverlay
2. Ensure tab bar remains tappable behind the overlay (use `.allowsHitTesting(false)` on non-interactive parts)
3. In screenshot mode, delay achievement checks by 5 seconds to let navigation settle

# Notes for Next Agent
This affects real users too — if they earn an achievement while navigating, the
celebration can block their intended action. Auto-dismiss is the safest fix.
