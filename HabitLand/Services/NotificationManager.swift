import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private let center = UNUserNotificationCenter.current()

    private init() {
        Task { await checkAuthorization() }
    }

    // MARK: - Authorization

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    func checkAuthorization() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Habit Reminders

    func scheduleHabitReminder(habitId: UUID, habitName: String, icon: String, at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(habitName)"
        content.body = "Don't break the chain! Complete your habit now."
        content.sound = .default
        content.categoryIdentifier = "habitReminder"

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "habit-\(habitId.uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func cancelHabitReminder(habitId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: ["habit-\(habitId.uuidString)"])
    }

    func rescheduleAll(habits: [(id: UUID, name: String, icon: String, reminderTime: Date)]) {
        center.removeAllPendingNotificationRequests()
        for habit in habits {
            scheduleHabitReminder(habitId: habit.id, habitName: habit.name, icon: habit.icon, at: habit.reminderTime)
        }
    }

    // MARK: - Streak Alerts

    func scheduleStreakReminder(habitId: UUID, habitName: String, streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"
        content.body = "You're on a \(streakDays)-day streak for \(habitName). Complete it today!"
        content.sound = .default
        content.categoryIdentifier = "streakAlert"

        // Fire at 8pm if not completed
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "streak-\(habitId.uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Weekly Summary

    func scheduleWeeklySummary() {
        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Recap is Ready!"
        content.body = "See how you did this week — check your progress and keep the momentum going!"
        content.sound = .default
        content.categoryIdentifier = "weeklySummary"

        // Every Sunday at 19:00
        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 19
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "weekly-summary",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func cancelWeeklySummary() {
        center.removePendingNotificationRequests(withIdentifiers: ["weekly-summary"])
    }

    // MARK: - Streak At-Risk Evening Reminder

    func scheduleStreakAtRiskReminders(habits: [(id: UUID, name: String, streak: Int, completed: Bool)]) {
        // Remove old streak risk notifications
        let ids = habits.map { "streak-risk-\($0.id.uuidString)" }
        center.removePendingNotificationRequests(withIdentifiers: ids)

        // Schedule for uncompleted habits with active streaks
        let atRisk = habits.filter { $0.streak > 0 && !$0.completed }
        guard !atRisk.isEmpty else { return }

        if atRisk.count == 1, let habit = atRisk.first {
            let content = UNMutableNotificationContent()
            content.title = "\(habit.streak)-day streak at risk!"
            content.body = "Complete \(habit.name) before midnight to keep your streak alive."
            content.sound = .default

            var components = DateComponents()
            components.hour = 21
            components.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "streak-risk-\(habit.id.uuidString)", content: content, trigger: trigger)
            center.add(request)
        } else {
            let content = UNMutableNotificationContent()
            content.title = "\(atRisk.count) streaks at risk!"
            let names = atRisk.prefix(3).map(\.name).joined(separator: ", ")
            content.body = "Complete \(names) before midnight to protect your streaks."
            content.sound = .default

            var components = DateComponents()
            components.hour = 21
            components.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "streak-risk-batch", content: content, trigger: trigger)
            center.add(request)
        }
    }

    // MARK: - Morning Motivation

    func scheduleMorningMotivation() {
        let messages = [
            ("Rise and Shine!", "Start your day with a small win — complete your first habit."),
            ("New Day, New Streak!", "Every completed habit brings you closer to your goals."),
            ("Good Morning!", "Your habits are waiting. Let's make today count!"),
            ("Fresh Start!", "Yesterday is done. Today you can be even better."),
        ]

        guard let pick = messages.randomElement() else { return }
        let content = UNMutableNotificationContent()
        content.title = pick.0
        content.body = pick.1
        content.sound = .default

        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "morning-motivation", content: content, trigger: trigger)
        center.add(request)
    }

    func cancelMorningMotivation() {
        center.removePendingNotificationRequests(withIdentifiers: ["morning-motivation"])
    }

    // MARK: - Daily Scheduling (call from app lifecycle)

    func scheduleDailyNotifications(habits: [(id: UUID, name: String, streak: Int, completed: Bool)]) {
        scheduleStreakAtRiskReminders(habits: habits)
        scheduleMorningMotivation()
    }

    // MARK: - Remove All

    func removeAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
