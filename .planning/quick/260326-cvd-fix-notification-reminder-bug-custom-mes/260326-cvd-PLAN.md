---
phase: quick
plan: 260326-cvd
type: execute
wave: 1
depends_on: []
files_modified:
  - HabitLand/Models/Models.swift
  - HabitLand/Services/NotificationManager.swift
  - HabitLand/Screens/Habits/HabitReminderView.swift
  - HabitLand/Screens/Habits/CreateHabitView.swift
  - HabitLand/Screens/Habits/EditHabitView.swift
  - HabitLandTests/NotificationReminderTests.swift
autonomous: true
requirements: []
must_haves:
  truths:
    - "Custom reminder message entered in HabitReminderView is persisted on the Habit model"
    - "Scheduled notification uses the custom message as body (or default if empty)"
    - "HabitReminderView loads saved custom message when reopened"
    - "Save button in HabitReminderView schedules/cancels notification"
    - "Preview in HabitReminderView matches what the actual notification will show"
  artifacts:
    - path: "HabitLand/Models/Models.swift"
      provides: "reminderMessage property on Habit"
      contains: "reminderMessage"
    - path: "HabitLand/Services/NotificationManager.swift"
      provides: "scheduleHabitReminder with customMessage parameter"
      contains: "customMessage"
    - path: "HabitLand/Screens/Habits/HabitReminderView.swift"
      provides: "Load/save custom message, schedule notification on save"
  key_links:
    - from: "HabitReminderView.saveButton"
      to: "NotificationManager.scheduleHabitReminder"
      via: "calls schedule on save with custom message"
    - from: "HabitReminderView.init"
      to: "Habit.reminderMessage"
      via: "initializes customMessage state from model"
    - from: "NotificationManager.scheduleHabitReminder"
      to: "UNMutableNotificationContent.body"
      via: "uses customMessage param or default fallback"
---

<objective>
Fix the notification reminder system so custom messages are actually persisted and sent.

Purpose: Currently HabitReminderView has a custom message text field that does nothing -- the message is never saved to the model (no property exists), never passed to NotificationManager, and the notification always sends a hardcoded string. Additionally, HabitReminderView doesn't schedule notifications on save.

Output: Working end-to-end custom reminder message flow: model property, NotificationManager accepts custom message, HabitReminderView saves and schedules correctly.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@HabitLand/Models/Models.swift
@HabitLand/Services/NotificationManager.swift
@HabitLand/Screens/Habits/HabitReminderView.swift
@HabitLand/Screens/Habits/CreateHabitView.swift
@HabitLand/Screens/Habits/EditHabitView.swift
</context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Add reminderMessage to Habit model and update NotificationManager</name>
  <files>HabitLand/Models/Models.swift, HabitLand/Services/NotificationManager.swift, HabitLandTests/NotificationReminderTests.swift</files>
  <behavior>
    - Test: Habit model has reminderMessage property, defaults to empty string
    - Test: scheduleHabitReminder with custom message uses that message as notification body
    - Test: scheduleHabitReminder with empty/nil message uses default "Time for {habitName}!" as body
  </behavior>
  <action>
    1. In Models.swift, add `var reminderMessage: String = ""` to the Habit class (after reminderEnabled). Add `reminderMessage: String = ""` parameter to the init and assign it.

    2. In NotificationManager.swift, update `scheduleHabitReminder` signature to:
       `func scheduleHabitReminder(habitId: UUID, habitName: String, at time: Date, customMessage: String = "")`
       Change the body assignment to:
       `content.body = customMessage.isEmpty ? "Time for \(habitName)!" : customMessage`
       This also fixes the preview/actual mismatch -- both now use "Time for {name}!" as default.

    3. In CreateHabitView.swift line 519, the existing call already works because the new `customMessage` parameter has a default value of "". No change needed there (CreateHabitView doesn't have custom message UI).

    4. In EditHabitView.swift line 378, same -- existing call works with default param. No change needed.

    5. Create NotificationReminderTests.swift with tests for the behavior described above.
  </action>
  <verify>
    <automated>cd /Users/azc/works/HabitLand && xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:HabitLandTests/NotificationReminderTests -quiet 2>&1 | tail -20</automated>
  </verify>
  <done>Habit model has reminderMessage property; NotificationManager accepts and uses custom message with proper fallback; existing callers unaffected; tests pass</done>
</task>

<task type="auto">
  <name>Task 2: Wire HabitReminderView to save message and schedule notification</name>
  <files>HabitLand/Screens/Habits/HabitReminderView.swift</files>
  <action>
    1. In `init(habit:)`, initialize customMessage from the habit model:
       `_customMessage = State(initialValue: habit.reminderMessage)`

    2. In `saveButton` action, add the following before `dismiss()`:
       - Save custom message: `habit.reminderMessage = customMessage`
       - Cancel existing notification: `NotificationManager.shared.cancelHabitReminder(habitId: habit.id)`
       - Schedule new notification if enabled:
         ```swift
         if reminderEnabled {
             NotificationManager.shared.scheduleHabitReminder(
                 habitId: habit.id,
                 habitName: habit.name,
                 at: reminderTime,
                 customMessage: customMessage
             )
         }
         ```
       - Add modelContext save: get `@Environment(\.modelContext) private var modelContext` and call `try? modelContext.save()` after mutations.

    3. In `testButton` action, actually send a test notification using the current customMessage:
       ```swift
       let content = UNMutableNotificationContent()
       content.title = "Time for \(habit.name)"
       content.body = customMessage.isEmpty ? "Time for \(habit.name)!" : customMessage
       content.sound = .default
       let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
       let request = UNNotificationRequest(identifier: "test-\(habit.id.uuidString)", content: content, trigger: trigger)
       UNUserNotificationCenter.current().add(request)
       ```

    4. The preview section (line 164) already shows the correct text: `customMessage.isEmpty ? "Time for \(habit.name)!" : customMessage` -- this now matches the actual notification body from Task 1.
  </action>
  <verify>
    <automated>cd /Users/azc/works/HabitLand && xcodebuild build -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16' -quiet 2>&1 | tail -10</automated>
  </verify>
  <done>HabitReminderView loads saved custom message on open; saves message to model on save; schedules/cancels notification on save; test button sends actual notification with custom message; modelContext.save() called after mutations</done>
</task>

</tasks>

<verification>
1. Build succeeds with no warnings on modified files
2. Unit tests pass for custom message logic
3. Full data flow: HabitReminderView init reads habit.reminderMessage -> user edits -> save writes habit.reminderMessage + schedules notification with custom message -> reopen reads saved message
</verification>

<success_criteria>
- Custom reminder message persists across HabitReminderView open/close cycles
- Notification body uses custom message when provided, falls back to "Time for {habitName}!" when empty
- Preview text in HabitReminderView matches actual notification body
- Save button schedules notification (was missing entirely)
- Test notification button actually sends a notification
- Existing CreateHabitView and EditHabitView callers unaffected (default param)
- modelContext.save() called after model mutations
</success_criteria>

<output>
After completion, create `.planning/quick/260326-cvd-fix-notification-reminder-bug-custom-mes/260326-cvd-SUMMARY.md`
</output>
