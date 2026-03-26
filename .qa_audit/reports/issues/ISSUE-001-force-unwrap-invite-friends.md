# ISSUE-001

## Title
Force unwrap on URL(string:) in InviteFriendsView

## Category
Code Quality

## Severity
Medium

## Screen / Feature
InviteFriendsView.swift:26

## Suspected Root Cause
`private static let fallbackURL = URL(string: "https://apps.apple.com")!`

## Recommended Fix
Replace with: `private static let fallbackURL = URL(string: "https://apps.apple.com") ?? URL(string: "about:blank")!`
Or use `guard let` pattern.

## Status
Open
