# ISSUE-003: Navigation Title Changes When Switching Social Sub-Tabs

**Category:** UI / Navigation
**Severity:** Medium

## Description

Each sub-view inside SocialHubView (Friends, Leaderboard, Challenges, Feed) has its own `NavigationStack` with its own `navigationTitle`. This causes the navigation bar title to change when swiping between sections (e.g., "Social" -> "Friends" -> "Challenges"), creating a jarring experience.

The parent SocialHubView sets `navigationTitle("Social")`, but child views override it with their own titles ("Friends", "Challenges").

## Steps to Reproduce

1. Navigate to the Social tab
2. Observe navigation title shows "Friends" (not "Social")
3. Swipe to Leaderboard - title changes to "Challenges"
4. Swipe to Challenges - title stays "Challenges"

## Expected Result

The navigation title should remain "Social" consistently, or change in a coordinated way with the section picker.

## Actual Result

Navigation title flickers between different values as child views each control their own NavigationStack.

## File Reference

- `HabitLand/Screens/Social/SocialHubView.swift` line 56: `.navigationTitle("Social")`
- `HabitLand/Screens/Social/FriendsListView.swift` line 51: `.navigationTitle("Friends")`
- `HabitLand/Screens/Social/SharedChallengesView.swift` line 45: `.navigationTitle("Challenges")`

## Recommended Fix

Remove `NavigationStack` wrappers from child views (FriendsListView, LeaderboardView, SharedChallengesView, SocialFeedView) since SocialHubView already provides one. Only the parent should set the navigationTitle.
