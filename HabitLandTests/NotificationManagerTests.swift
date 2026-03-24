import Testing
import Foundation
@testable import HabitLand

// MARK: - NotificationManager Tests

struct NotificationManagerTests {

    // MARK: - Evening Reminder

    @Test @MainActor func scheduleEveningReminderForPendingHabits() {
        let manager = NotificationManager.shared
        manager.scheduleEveningReminder(pendingCount: 3)
        // Verifies code path executes without crash
    }

    @Test @MainActor func scheduleEveningReminderSingleHabit() {
        let manager = NotificationManager.shared
        manager.scheduleEveningReminder(pendingCount: 1)
    }

    @Test @MainActor func noEveningReminderWhenAllComplete() {
        let manager = NotificationManager.shared
        // pendingCount = 0 → guard returns early
        manager.scheduleEveningReminder(pendingCount: 0)
    }

    // MARK: - Streak At Risk

    @Test @MainActor func streakAtRiskRemindersWithNoAtRiskHabits() {
        let manager = NotificationManager.shared
        let habits: [(id: UUID, name: String, streak: Int, completed: Bool)] = [
            (UUID(), "Exercise", 5, true),  // completed, not at risk
            (UUID(), "Read", 0, false),      // no streak, not at risk
        ]
        manager.scheduleStreakAtRiskReminders(habits: habits)
    }

    @Test @MainActor func streakAtRiskRemindersSingleHabit() {
        let manager = NotificationManager.shared
        let habits: [(id: UUID, name: String, streak: Int, completed: Bool)] = [
            (UUID(), "Meditate", 7, false),
        ]
        manager.scheduleStreakAtRiskReminders(habits: habits)
    }

    @Test @MainActor func streakAtRiskRemindersMultipleHabits() {
        let manager = NotificationManager.shared
        let habits: [(id: UUID, name: String, streak: Int, completed: Bool)] = [
            (UUID(), "Meditate", 7, false),
            (UUID(), "Exercise", 3, false),
            (UUID(), "Read", 10, false),
        ]
        manager.scheduleStreakAtRiskReminders(habits: habits)
    }

    // MARK: - Daily Notifications

    @Test @MainActor func dailyNotificationsScheduling() {
        let manager = NotificationManager.shared
        let habits: [(id: UUID, name: String, streak: Int, completed: Bool)] = [
            (UUID(), "Meditate", 5, true),
            (UUID(), "Exercise", 3, false),
        ]
        manager.scheduleDailyNotifications(habits: habits)
    }

    // MARK: - Habit Reminder

    @Test @MainActor func scheduleAndCancelHabitReminder() {
        let manager = NotificationManager.shared
        let id = UUID()
        manager.scheduleHabitReminder(habitId: id, habitName: "Exercise", icon: "figure.run", at: Date())
        manager.cancelHabitReminder(habitId: id)
        // No crash = success
    }

    // MARK: - Weekly Summary

    @Test @MainActor func scheduleAndCancelWeeklySummary() {
        let manager = NotificationManager.shared
        manager.scheduleWeeklySummary()
        manager.cancelWeeklySummary()
    }

    // MARK: - Morning Motivation

    @Test @MainActor func scheduleAndCancelMorningMotivation() {
        let manager = NotificationManager.shared
        manager.scheduleMorningMotivation()
        manager.cancelMorningMotivation()
    }

    // MARK: - Streak Coaching

    @Test @MainActor func streakCoachingAtMilestone() {
        let manager = NotificationManager.shared
        // currentStreak + 1 must match a milestone to schedule
        // Milestone at 3: currentStreak = 2
        manager.scheduleStreakCoaching(currentStreak: 2)
    }

    @Test @MainActor func streakCoachingAtNonMilestone() {
        let manager = NotificationManager.shared
        // currentStreak = 5 → next = 6, not a milestone
        manager.scheduleStreakCoaching(currentStreak: 5)
    }

    // MARK: - Weekly Recap

    @Test @MainActor func weeklyRecapScheduling() {
        let manager = NotificationManager.shared
        manager.scheduleWeeklyRecap(completedThisWeek: 15, bestStreak: 7)
    }

    // MARK: - Remove All

    @Test @MainActor func removeAllDoesNotCrash() {
        let manager = NotificationManager.shared
        manager.removeAll()
    }

    // MARK: - Reschedule All

    @Test @MainActor func rescheduleAllWithEmptyList() {
        let manager = NotificationManager.shared
        manager.rescheduleAll(habits: [])
    }

    @Test @MainActor func rescheduleAllWithHabits() {
        let manager = NotificationManager.shared
        let habits: [(id: UUID, name: String, icon: String, reminderTime: Date)] = [
            (UUID(), "Exercise", "figure.run", Date()),
            (UUID(), "Read", "book.fill", Date()),
        ]
        manager.rescheduleAll(habits: habits)
    }
}
