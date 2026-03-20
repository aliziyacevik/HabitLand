# Issue ID
ISSUE-012

# Title
CloudKitManager checks wrong container for iCloud status

# Category
Bug

# Severity
High

# Priority
P1

# Screen / Feature
Social features — iCloud availability check

# Preconditions
User has iCloud signed in

# Steps to Reproduce
1. Open Social tab
2. CloudKitManager.checkiCloudStatus() is called
3. It checks `CKContainer.default()` instead of the custom container `iCloud.azc.HabitLand`

# Expected Result
Should check the status of the app's custom CloudKit container

# Actual Result
Checks the default container, which may have a different status than the custom container

# Frequency
Always

# Suspected Root Cause
Line 39 in CloudKitManager.swift uses `CKContainer.default()` instead of `self.container`

# Code References
- `HabitLand/Services/CloudKitManager.swift:39` — `CKContainer.default().accountStatus()`

# Impact
If the default container differs from the custom container, the iCloud availability check could give wrong results, potentially hiding or showing social features incorrectly.

# Recommended Fix Direction
Change `CKContainer.default().accountStatus()` to `container.accountStatus()`

# Notes for Next Agent
Simple one-line fix on line 39 of CloudKitManager.swift.
