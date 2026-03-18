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

    // MARK: - Remove All

    func removeAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
