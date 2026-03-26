import Testing
import Foundation
@testable import HabitLand

// MARK: - NotificationManager Tests

struct NotificationManagerTests {

    // MARK: - Morning Motivation

    @Test @MainActor func scheduleMorningMotivation() {
        let manager = NotificationManager.shared
        manager.scheduleMorningMotivation(habitCount: 5)
    }

    @Test @MainActor func scheduleMorningMotivationZeroHabits() {
        let manager = NotificationManager.shared
        manager.scheduleMorningMotivation(habitCount: 0)
    }

    // MARK: - Evening Reminder

    @Test @MainActor func scheduleEveningReminderWithPending() {
        let manager = NotificationManager.shared
        manager.scheduleEveningReminder(pendingCount: 3, bestStreakAtRisk: 7)
    }

    @Test @MainActor func scheduleEveningReminderNoStreakRisk() {
        let manager = NotificationManager.shared
        manager.scheduleEveningReminder(pendingCount: 2, bestStreakAtRisk: nil)
    }

    @Test @MainActor func noEveningReminderWhenAllComplete() {
        let manager = NotificationManager.shared
        manager.scheduleEveningReminder(pendingCount: 0, bestStreakAtRisk: nil)
    }

    // MARK: - Weekly Recap

    @Test @MainActor func scheduleWeeklyRecap() {
        let manager = NotificationManager.shared
        manager.scheduleWeeklyRecap(completedThisWeek: 15, totalThisWeek: 21, bestStreak: 7)
    }

    @Test @MainActor func cancelWeeklySummary() {
        let manager = NotificationManager.shared
        manager.cancelWeeklySummary()
    }

    // MARK: - Daily Notifications (composite)

    @Test @MainActor func dailyNotificationsScheduling() {
        let manager = NotificationManager.shared
        let habits: [(id: UUID, name: String, streak: Int, completed: Bool)] = [
            (UUID(), "Meditate", 5, true),
            (UUID(), "Exercise", 3, false),
        ]
        manager.scheduleDailyNotifications(habits: habits)
    }

    @Test @MainActor func dailyNotificationsAllComplete() {
        let manager = NotificationManager.shared
        let habits: [(id: UUID, name: String, streak: Int, completed: Bool)] = [
            (UUID(), "Meditate", 5, true),
            (UUID(), "Exercise", 3, true),
        ]
        manager.scheduleDailyNotifications(habits: habits)
    }

    // MARK: - Remove All

    @Test @MainActor func removeAllDoesNotCrash() {
        let manager = NotificationManager.shared
        manager.removeAll()
    }
}
