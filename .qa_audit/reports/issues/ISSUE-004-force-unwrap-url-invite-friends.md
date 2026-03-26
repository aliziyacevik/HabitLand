# ISSUE-004

## Title
Force unwrap on URL in InviteFriendsView

## Category
Crash Risk

## Severity
Medium

## Priority
P2

## Screen / Feature
Social → Invite Friends

## Suspected Root Cause
`InviteFriendsView.swift:26` — `URL(string: "https://apps.apple.com")!`

While this specific URL is always valid, force unwrap violates project standards.

## Recommended Fix
Use `guard let` or provide a safe fallback.
