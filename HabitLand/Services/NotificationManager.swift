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

    func scheduleHabitReminders(habits: [(id: UUID, name: String, icon: String, reminderTime: Date)]) {
        let reminderIds = habits.map { "habit-\($0.id.uuidString)" }
        center.removePendingNotificationRequests(withIdentifiers: reminderIds + ["habit-group"])

        let calendar = Calendar.current
        var grouped: [String: [String]] = [:]
        for habit in habits {
            let key = "\(calendar.component(.hour, from: habit.reminderTime)):\(calendar.component(.minute, from: habit.reminderTime))"
            grouped[key, default: []].append(habit.name)
        }

        for (timeKey, names) in grouped {
            let parts = timeKey.split(separator: ":").compactMap { Int($0) }
            guard parts.count == 2 else { continue }

            let content = UNMutableNotificationContent()
            if names.count == 1 {
                content.title = "Time for \(names[0])"
                content.body = "Don't break the chain! Complete your habit now."
            } else {
                content.title = "\(names.count) Habits Waiting"
                let listed = names.prefix(3).joined(separator: ", ")
                content.body = names.count <= 3
                    ? "Time for \(listed)"
                    : "Time for \(listed) and \(names.count - 3) more"
            }
            content.sound = .default
            content.categoryIdentifier = "habitReminder"

            var components = DateComponents()
            components.hour = parts[0]
            components.minute = parts[1]
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let identifier = names.count == 1 ? "habit-\(timeKey)" : "habit-group-\(timeKey)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        }
    }

    func scheduleHabitReminder(habitId: UUID, habitName: String, icon: String = "", at time: Date, customMessage: String = "") {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(habitName)"
        content.body = customMessage.isEmpty ? "Time for \(habitName)!" : customMessage
        content.sound = .default

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

    func rescheduleAll(habits: [(id: UUID, name: String, icon: String, reminderTime: Date, customMessage: String)]) {
        center.removeAllPendingNotificationRequests()
        for habit in habits {
            scheduleHabitReminder(habitId: habit.id, habitName: habit.name, icon: habit.icon, at: habit.reminderTime, customMessage: habit.customMessage)
        }
    }

    // MARK: - Morning Motivation (08:00, daily)

    func scheduleMorningMotivation(habitCount: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["morning-motivation"])

        let messages: [(String, String)] = [
            ("Good Morning! ☀️", "\(habitCount) habit\(habitCount == 1 ? "" : "s") waiting for you. Let's make today count!"),
            ("Rise and Shine! 🌅", "Start your day with a small win — complete your first habit."),
            ("New Day, New Streak! 🔥", "Every completed habit brings you closer to your goals."),
            ("Fresh Start! 💪", "Yesterday is done. Today you can be even better."),
        ]

        guard let pick = messages.randomElement() else { return }
        let content = UNMutableNotificationContent()
        content.title = pick.0
        content.body = pick.1
        content.sound = .default

        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "morning-motivation", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Evening Reminder (20:00, only if pending habits)

    func scheduleEveningReminder(pendingCount: Int, bestStreakAtRisk: Int?) {
        center.removePendingNotificationRequests(withIdentifiers: ["evening-reminder"])
        guard pendingCount > 0 else { return }

        let content = UNMutableNotificationContent()

        if let streak = bestStreakAtRisk, streak >= 3 {
            content.title = "\(streak)-day streak at risk! 🔥"
            content.body = "You have \(pendingCount) habit\(pendingCount == 1 ? "" : "s") left. Don't let your streak break!"
        } else {
            content.title = "\(pendingCount) Habit\(pendingCount == 1 ? "" : "s") Left Today"
            content.body = "You still have time! Complete your habits before the day ends."
        }
        content.sound = .default

        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "evening-reminder", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Weekly Recap (Sunday 19:00)

    func scheduleWeeklyRecap(completedThisWeek: Int, totalThisWeek: Int, bestStreak: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["weekly-recap"])

        let content = UNMutableNotificationContent()
        let rate = totalThisWeek > 0 ? Int(Double(completedThisWeek) / Double(totalThisWeek) * 100) : 0
        content.title = "Your Week in Review 📊"
        content.body = "You completed \(completedThisWeek) habits (\(rate)%) with a \(bestStreak)-day best streak!"
        content.sound = .default

        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 19
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "weekly-recap", content: content, trigger: trigger)
        center.add(request)
    }

    func cancelWeeklySummary() {
        center.removePendingNotificationRequests(withIdentifiers: ["weekly-recap"])
    }

    // MARK: - Daily Scheduling (call from app lifecycle)

    func scheduleDailyNotifications(habits: [(id: UUID, name: String, streak: Int, completed: Bool)]) {
        let completed = habits.filter(\.completed).count
        let total = habits.count
        let pending = total - completed

        // 1. Morning motivation (repeating daily)
        scheduleMorningMotivation(habitCount: total)

        // 2. Evening reminder (only if incomplete habits, includes streak risk)
        let bestAtRiskStreak = habits.filter { !$0.completed && $0.streak >= 3 }.map(\.streak).max()
        scheduleEveningReminder(pendingCount: pending, bestStreakAtRisk: bestAtRiskStreak)

        // 3. Weekly recap (repeating Sundays)
        let bestStreak = habits.map(\.streak).max() ?? 0
        scheduleWeeklyRecap(completedThisWeek: completed, totalThisWeek: total, bestStreak: bestStreak)
    }

    // MARK: - Remove All

    func removeAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
