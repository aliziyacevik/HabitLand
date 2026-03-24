# Issue ID
ISSUE-004

# Title
Hardcoded font sizes missing @ScaledMetric for Dynamic Type accessibility

# Category
Accessibility

# Severity
Medium

# Priority
P2

# Screen / Feature
Multiple screens — Effects.swift, OnboardingView, AchievementsShowcaseView, HomeDashboardView, SpotlightCoachingView, PersonalStatisticsView

# Steps to Reproduce
1. Go to iOS Settings > Accessibility > Larger Text
2. Set to "Accessibility XL" or larger
3. Navigate through app — hardcoded icons don't scale

# Expected Result
All icons and text scale with Dynamic Type

# Actual Result
15+ locations use hardcoded font sizes without @ScaledMetric:
- Effects.swift:625,754 — `.font(.system(size: 44))`
- OnboardingView.swift:1361 — `.font(.system(size: 60, weight: .medium))`
- AchievementsShowcaseView.swift:56 — `.font(.system(size: 40))`
- HomeDashboardView.swift:322 — `.font(.system(size: 14))`
- HomeDashboardView.swift:847 — `.font(.system(size: 8))`
- HomeDashboardView.swift:901 — `.font(.system(size: 11))`
- HomeDashboardView.swift:1009 — `.font(.system(size: 10))`
- SpotlightCoachingView.swift:89 — `.font(.system(size: 24))`
- PersonalStatisticsView.swift:181 — `.font(.system(size: 40))`

# Evidence
Code inspection — grep for `.font(.system(size:` without @ScaledMetric wrapper

# Suspected Root Cause
Development shortcuts — many of these are newer additions

# Recommended Fix
Wrap each with @ScaledMetric property and use `min()` cap. Example:
```swift
@ScaledMetric(relativeTo: .title3) private var iconSize: CGFloat = 44
// then: .font(.system(size: min(iconSize, 52)))
```

# Notes for Next Agent
Prioritize HomeDashboardView (most visible) and OnboardingView (first impression)
