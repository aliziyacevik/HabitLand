# Issue ID
ISSUE-007

# Title
Home dashboard scroll stops mid-page — bottom content not reachable

# Category
UX

# Severity
Low

# Priority
P3

# Screen / Feature
HomeDashboardView

# Steps to Reproduce
1. Open Home tab
2. Scroll down past habits list
3. Continue scrolling — content stops at Focus Timer / Track to Transform cards
4. Multiple swipe-ups show identical content (no more scrollable content)

# Expected Result
All cards below the fold should be reachable with scrolling

# Actual Result
Screenshots 01_home_mid, 01_home_bottom, 01_home_deep from first run
are identical — suggesting either:
a) The scroll content genuinely ends there (not a bug, just shallow page)
b) Scroll bounce prevents reaching content below

# Evidence
Screenshots: 01_home_mid.png = 01_home_bottom.png = 01_home_deep.png (identical)

# Suspected Root Cause
Home content may simply end at Focus Timer + Insight card. Not a bug per se
but worth noting that the page feels short for a dashboard.

# Recommended Fix
Consider adding more content below the fold: weekly recap, habit streaks chart,
or "Explore Habits" discovery card. But this is a product decision, not a bug fix.

# Notes for Next Agent
Low priority — verify this is expected content depth, not a clipping issue
