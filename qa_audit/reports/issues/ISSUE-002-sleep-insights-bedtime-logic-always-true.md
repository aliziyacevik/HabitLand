# Issue ID
ISSUE-002

# Title
Sleep insights bedtime filter logic is always true — produces incorrect correlation data

# Category
Bug / Data

# Severity
Critical

# Priority
P0

# Screen / Feature
SleepInsightsView — Bedtime/quality correlation insight

# Environment
All — code-level finding

# Preconditions
User has logged sleep data (at least 3 entries)

# Steps to Reproduce
1. Log several sleep entries with varying bedtimes
2. Navigate to Sleep > Insights
3. Observe bedtime quality correlation insight

# Expected Result
"earlyBedLogs" should filter for bedtimes BEFORE 11pm. "lateBedLogs" should filter for bedtimes AT or AFTER 11pm.

# Actual Result
SleepInsightsView.swift:143-145:
```swift
let earlyBedLogs = sleepLogs.filter {
    let hour = calendar.component(.hour, from: $0.bedTime)
    return hour < 23 || hour >= 0  // BUG: Always true for any hour
}
```
The condition `hour < 23 || hour >= 0` is always true because every integer hour is either < 23 OR >= 0. This means earlyBedLogs contains ALL logs, making the insight meaningless.

# Frequency
Always

# Evidence
SleepInsightsView.swift:143-150

# Suspected Root Cause
Logical operator error. Should be `&&` (AND) instead of `||` (OR), or the condition should be `hour >= 0 && hour < 23` to mean "before 11pm". More likely intended: `hour < 23 && hour >= 18` (evening before 11pm) to contrast with `hour >= 23`.

# Code References
- SleepInsightsView.swift:143-150 (earlyBedLogs filter)
- SleepInsightsView.swift:147-150 (lateBedLogs filter — correct but never has data since earlyBedLogs takes everything)

# Impact
Sleep insights display incorrect data. The bedtime/quality correlation insight is based on faulty grouping, so users receive misleading health recommendations.

# Recommended Fix Direction
Change line 145 to: `return hour >= 0 && hour < 23` or better: `return hour >= 18 && hour < 23` to capture "evening before 11pm" bedtimes. The lateBedLogs filter at line 149 (`hour >= 23 && hour < 24`) is correct.

# Notes for Next Agent
This is a logic bug. The fix is changing `||` to `&&` on line 145 of SleepInsightsView.swift. Also consider whether the hour range for "early bed" makes sense — 0-22 is very broad. Probably should be 18-22 (6pm-10:59pm).
