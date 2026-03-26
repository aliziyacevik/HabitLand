# ISSUE-002: Force unwraps in CloudKitManager

**Severity:** Low (CloudKit is disabled)
**Category:** Code Safety
**File:** `HabitLand/Services/CloudKitManager.swift:15,59,73`

## Description

CloudKitManager uses `_container!.publicCloudDatabase` and `_container!.accountStatus()` which are force unwraps on an optional. The code comment says "all public methods guard on _container != nil first" but this relies on discipline rather than compiler enforcement.

## Impact

Since CloudKit is disabled (no entitlement), `_container` is nil and these force unwraps would crash if any method path bypassed the guard. Currently no crash path exists because all public methods check `isCloudKitReady` first.

## Fix

Use `guard let container = _container else { return }` pattern instead of force unwrap, or make the `publicDB` computed property return an optional.
