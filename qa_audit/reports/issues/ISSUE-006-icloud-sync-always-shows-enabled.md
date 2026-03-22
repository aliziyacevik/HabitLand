# ISSUE-006: iCloud Sync Status Always Shows "Enabled" in Settings

**Category:** UI / Misleading Information
**Severity:** Medium

## Description

In GeneralSettingsView, the iCloud Sync status row always displays "Enabled" with a green indicator dot, regardless of the actual iCloud account status. The value is hardcoded.

## Steps to Reproduce

1. Sign out of iCloud on the device
2. Open HabitLand > Profile > Settings
3. Observe "iCloud Sync" row shows "Enabled" with green dot

## Expected Result

Should reflect actual iCloud status (Available/Unavailable/Not Signed In).

## Actual Result

Always shows "Enabled" with green dot.

## File Reference

`HabitLand/Screens/Settings/GeneralSettingsView.swift` lines 116-124:
```swift
HStack {
    settingsRow(icon: "icloud.fill", color: .blue, title: "iCloud Sync")
    Spacer()
    Text("Enabled")
        .font(HLFont.caption())
        .foregroundStyle(Color.hlTextSecondary)
    Circle()
        .fill(Color.green)
        .frame(width: 8, height: 8)
}
```

## Recommended Fix

Use `CloudKitManager.shared.iCloudAvailable` to dynamically show the actual status, similar to how HealthKit status is already dynamically displayed in the same settings section.
