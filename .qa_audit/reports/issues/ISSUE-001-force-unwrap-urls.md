# Issue ID
ISSUE-001

# Title
Force unwrap on URL string creation can crash

# Category
Crash

# Severity
Critical

# Priority
P0

# Screen / Feature
SharedChallengesView, InviteFriendsView

# Steps to Reproduce
1. Navigate to Challenges tab
2. Share a challenge (triggers URL creation)
3. If URL string is malformed, app crashes

# Expected Result
Graceful handling of invalid URL

# Actual Result
Force unwrap `URL(string: challengeShareURL)!` will crash if URL is malformed

# Evidence
Code inspection:
- SharedChallengesView.swift:213 — `item: URL(string: challengeShareURL)!`
- InviteFriendsView.swift:126 — `item: URL(string: appStoreURL)!`

# Suspected Root Cause
Force unwrap on optional URL initializer

# Recommended Fix
Replace with `guard let url = URL(string: ...) else { return }` or use nil-coalescing

# Notes for Next Agent
Search for `URL(string:` followed by `!` across entire codebase
