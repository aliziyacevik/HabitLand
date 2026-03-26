# ISSUE-002: Paywall Advertises Removed Social Features

**Severity**: Medium (UX / Marketing Accuracy)
**Category**: Copy / Content
**Status**: Open

## Description
PaywallView.swift line 126 shows:
```
featureRow(icon: "person.2.fill", color: .hlSocial, title: "Social Features", subtitle: "Friends, leaderboard & challenges")
```
The Social tab was removed from the app. Users who upgrade expecting social features will be disappointed.

## Files
- `/Users/azc/works/HabitLand/HabitLand/Screens/Premium/PaywallView.swift:126`

## Recommendation
Either remove the "Social Features" row from the paywall, or replace with "Coming Soon" badge and clarify in subtitle.
