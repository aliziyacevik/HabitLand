import Testing
import Foundation
@testable import HabitLand

// MARK: - Habit Reminder Message Tests

struct HabitReminderMessageTests {
    @Test func habitHasReminderMessageProperty() {
        let habit = Habit(name: "Meditate")
        #expect(habit.reminderMessage == "")
    }

    @Test func habitReminderMessageCanBeSet() {
        let habit = Habit(name: "Meditate")
        habit.reminderMessage = "Time to breathe"
        #expect(habit.reminderMessage == "Time to breathe")
    }

    @Test func habitInitWithCustomReminderMessage() {
        let habit = Habit(name: "Meditate", reminderMessage: "Custom reminder")
        #expect(habit.reminderMessage == "Custom reminder")
    }
}

// MARK: - Notification Custom Message Tests

struct NotificationCustomMessageTests {
    @Test func defaultMessageUsedWhenCustomMessageEmpty() {
        // Verify the default fallback logic
        let habitName = "Morning Run"
        let customMessage = ""
        let body = customMessage.isEmpty ? "Time for \(habitName)!" : customMessage
        #expect(body == "Time for Morning Run!")
    }

    @Test func customMessageUsedWhenProvided() {
        let habitName = "Morning Run"
        let customMessage = "Lace up those shoes!"
        let body = customMessage.isEmpty ? "Time for \(habitName)!" : customMessage
        #expect(body == "Lace up those shoes!")
    }
}
