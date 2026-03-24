# Issue ID
ISSUE-005

# Title
Sleep quality icons render as "?" in Sleep History and Log Sleep form

# Category
Visual

# Severity
Medium

# Priority
P2

# Screen / Feature
SleepHistoryView, SleepDashboardView, LogSleepView

# Steps to Reproduce
1. Navigate to Sleep tab
2. View "Last Night" card — quality icon shows "?"
3. Open Sleep History — all entries show "?" instead of quality emoji
4. Open Log Sleep — quality options show "?" next to each choice

# Expected Result
Quality emojis should render: 😫 Terrible, 😴 Poor, 😐 Fair, 😊 Good, 🤩 Excellent

# Actual Result
All quality icons render as "?" in a rounded rectangle

# Evidence
Screenshots: 03_sleep_dashboard.png, 03_sleep_history.png, 03_log_sleep_form.png

# Suspected Root Cause
Emoji rendering issue — the SleepQuality.icon returns emoji strings (😫, 😴, etc.)
rendered via `Text(log.quality.icon).font(.title2)`. May be a simulator-specific
rendering issue or font fallback problem. Need real device verification.

Models.swift:527-533 defines the icon property returning emoji strings.
SleepHistoryView.swift:87 renders via `Text(log.quality.icon)`

# Recommended Fix
1. Test on real device first — may be simulator-only
2. If persists, replace emojis with SF Symbols:
   - terrible: "face.dashed" or custom
   - poor: "zzz"
   - fair: "minus.circle"
   - good: "hand.thumbsup"
   - excellent: "star.fill"

# Notes for Next Agent
Verify on physical device before changing code. Simulator emoji rendering can differ.
