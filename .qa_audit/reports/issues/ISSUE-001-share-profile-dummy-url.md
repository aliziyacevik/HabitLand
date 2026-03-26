# ISSUE-001

## Title
Share Profile uses placeholder App Store URL

## Category
Product

## Severity
Medium

## Priority
P2

## Screen / Feature
Profile → Share Profile

## Steps to Reproduce
1. Go to Profile tab
2. Tap "Share Profile"
3. Share sheet opens with text containing `id0000000000`

## Expected Result
Real App Store URL or disabled until app is published

## Actual Result
ShareLink text contains `https://apps.apple.com/app/habitland/id0000000000` — dummy ID

## Suspected Root Cause
`UserProfileView.swift:303` — hardcoded placeholder URL in ShareLink

## Recommended Fix
Replace with actual App Store ID once published, or hide the Share Profile button until real ID is available
