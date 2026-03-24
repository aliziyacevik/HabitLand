# Issue ID
ISSUE-008

# Title
Effects.swift celebration overlays use hardcoded 44pt icon sizes

# Category
Accessibility

# Severity
Medium

# Priority
P2

# Screen / Feature
Effects.swift — celebration and confetti overlays

# Steps to Reproduce
1. Enable Accessibility Large Text
2. Complete all habits (trigger celebration)
3. Celebration icon doesn't scale with Dynamic Type

# Expected Result
Celebration icons scale with accessibility settings

# Actual Result
Effects.swift:625 and :754 use `.font(.system(size: 44))` without @ScaledMetric

# Evidence
Code inspection

# Suspected Root Cause
Celebration effects are decorative and were built without DynamicType consideration

# Recommended Fix
Add @ScaledMetric wrapper with min() cap

# Notes for Next Agent
Low user impact since celebrations are transient, but still violates accessibility guidelines
