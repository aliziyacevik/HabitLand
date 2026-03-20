# Issue ID
ISSUE-001

# Title
Force unwrap crash risk in InsightsOverviewView strongestHabitCard

# Category
Bug / Crash

# Severity
Critical

# Priority
P0

# Screen / Feature
InsightsOverviewView — Strongest Habit Card

# Environment
All — code-level finding

# Preconditions
User has at least one active habit

# Steps to Reproduce
1. Open Insights view
2. Have habits where computedStrongestHabit could briefly be nil during re-render
3. View crashes on `computedStrongestHabit!` force unwrap

# Expected Result
Safe optional handling, no crash

# Actual Result
Line 418: `let strongest = computedStrongestHabit!` — force unwrap will crash if the computed property returns nil during a SwiftUI re-render cycle

# Frequency
Rare (race condition during view updates)

# Evidence
InsightsOverviewView.swift:418

# Suspected Root Cause
The view guards with `if computedStrongestHabit != nil` on line 245, but SwiftUI can re-evaluate the body and the computed property independently. Between the check and the force unwrap, the habits array could change.

# Code References
- InsightsOverviewView.swift:418 (`let strongest = computedStrongestHabit!`)
- InsightsOverviewView.swift:245 (guard condition)
- InsightsOverviewView.swift:112-134 (computed property)

# Impact
App crash — complete loss of user session. If triggered during daily use, causes frustration and potential data loss.

# Recommended Fix Direction
Replace `let strongest = computedStrongestHabit!` with `guard let strongest = computedStrongestHabit else { return EmptyView().eraseToAnyView() }` or restructure to use `if let` binding.

# Notes for Next Agent
This is a P0 crash bug. The fix is a one-line change. Replace the force unwrap with safe optional binding. Search for `computedStrongestHabit!` in InsightsOverviewView.swift.
