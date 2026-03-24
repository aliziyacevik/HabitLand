# Issue ID
ISSUE-001

# Title
Pomodoro fullScreenCover blocks tab navigation

# Category
Navigation

# Severity
High

# Priority
P1

# Screen / Feature
Home Dashboard → Pomodoro Timer

# Steps to Reproduce
1. Open Home tab
2. Tap "Focus Timer" card to open Pomodoro
3. Try to navigate to another tab while Pomodoro is open

# Expected Result
Tab navigation should either dismiss Pomodoro or be blocked with clear UX

# Actual Result
fullScreenCover persists, blocking the underlying tab view. In XCUITest, tab taps land on Pomodoro screen instead of destination tab.

# Evidence
qa_02_habits_list.png shows Pomodoro instead of Habits list

# Suspected Root Cause
PomodoroView is presented as `.fullScreenCover` which overlays the entire tab bar

# Recommended Fix
This is by-design for fullScreenCover. The test automation issue is that the test didn't dismiss Pomodoro before navigating. Not a real user bug — users would tap X to dismiss first.

# Status
LOW RISK — Test automation timing issue, not a user-facing bug
