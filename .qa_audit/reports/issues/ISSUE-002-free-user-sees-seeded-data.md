# ISSUE-002

## Title
Free user test shows seeded data from prior Pro test — test isolation issue

## Category
Testing

## Severity
Low

## Priority
P3

## Screen / Feature
QA test suite — test isolation

## Root Cause
The `testPremiumGatesAsFreeUser` test runs on the same simulator that already has seeded data from `testFullAppAuditWithData`. The data persists between test runs because they share the same SwiftData database. This is NOT an app bug — real fresh installs show empty state correctly.

## Recommended Fix
Add database cleanup at the start of `testPremiumGatesAsFreeUser`, or use `XCUIApplication.launchArguments` with a `-resetData` flag.
