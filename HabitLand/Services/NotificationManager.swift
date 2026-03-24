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

    // MARK: - Habit Reminders (Grouped by Time)

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
        scheduleHabitReminders(habits: habits)
    }

    // MARK: - Streak Alerts

    func scheduleStreakReminder(habitId: UUID, habitName: String, streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"
        content.body = "You're on a \(streakDays)-day streak for \(habitName). Complete it today!"
        content.sound = .default
        content.categoryIdentifier = "streakAlert"

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

    // MARK: - Streak At-Risk Evening Reminder

    func scheduleStreakAtRiskReminders(habits: [(id: UUID, name: String, streak: Int, completed: Bool)]) {
        let ids = habits.map { "streak-risk-\($0.id.uuidString)" }
        center.removePendingNotificationRequests(withIdentifiers: ids + ["streak-risk-batch"])

        let atRisk = habits.filter { $0.streak > 0 && !$0.completed }
        guard !atRisk.isEmpty else { return }

        let content = UNMutableNotificationContent()
        if atRisk.count == 1, let habit = atRisk.first {
            content.title = "\(habit.streak)-day streak at risk!"
            content.body = "Complete \(habit.name) before midnight to keep your streak alive."
        } else {
            content.title = "\(atRisk.count) streaks at risk!"
            let names = atRisk.prefix(3).map(\.name).joined(separator: ", ")
            content.body = "Complete \(names) before midnight to protect your streaks."
        }
        content.sound = .default

        var components = DateComponents()
        components.hour = 21
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "streak-risk-batch", content: content, trigger: trigger)
        center.add(request)
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

    // MARK: - Evening Reminder

    func scheduleEveningReminder(pendingCount: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["evening-reminder"])
        guard pendingCount > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = pendingCount == 1 ? "1 Habit Left Today" : "\(pendingCount) Habits Left Today"
        content.body = "You still have time! Complete your habits before the day ends."
        content.sound = .default

        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "evening-reminder", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Daily Completion Summary (21:30)

    func scheduleDailySummary(completedCount: Int, totalCount: Int, xpEarned: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["daily-summary"])
        guard completedCount > 0 else { return }
        guard completedCount < totalCount else { return }

        let content = UNMutableNotificationContent()
        if completedCount == totalCount {
            content.title = "Perfect Day!"
            content.body = "All \(totalCount) habits done — you earned \(xpEarned) XP today!"
        } else {
            content.title = "Today's Progress: \(completedCount)/\(totalCount)"
            content.body = "You earned \(xpEarned) XP today. Complete the rest before midnight!"
        }
        content.sound = .default

        var components = DateComponents()
        components.hour = 21
        components.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "daily-summary", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Sleep Reminder (22:00)

    func scheduleSleepReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Wind Down"
        content.body = "Log your sleep before bed — tracking helps you build better habits."
        content.sound = .default

        var components = DateComponents()
        components.hour = 22
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        center.removePendingNotificationRequests(withIdentifiers: ["sleep-reminder"])
        let request = UNNotificationRequest(identifier: "sleep-reminder", content: content, trigger: trigger)
        center.add(request)
    }

    func cancelSleepReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["sleep-reminder"])
    }

    // MARK: - Weekly Recap (Sunday 19:00 — merged summary + recap)

    func scheduleWeeklyRecap(completedThisWeek: Int, totalThisWeek: Int, bestStreak: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["weekly-summary", "weekly-recap"])

        let content = UNMutableNotificationContent()
        let rate = totalThisWeek > 0 ? Int(Double(completedThisWeek) / Double(totalThisWeek) * 100) : 0
        content.title = "Your Week in Review"
        content.body = "You completed \(completedThisWeek) habits (\(rate)%) with a \(bestStreak)-day best streak. Tap to see your full recap!"
        content.sound = .default
        content.categoryIdentifier = "weeklySummary"

        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 19
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "weekly-recap", content: content, trigger: trigger)
        center.add(request)
    }

    func cancelWeeklySummary() {
        center.removePendingNotificationRequests(withIdentifiers: ["weekly-summary", "weekly-recap"])
    }

    // MARK: - Streak Milestone Coaching

    func scheduleStreakCoaching(currentStreak: Int) {
        let milestones: [(days: Int, title: String, body: String)] = [
            (3, "3-Day Streak!", "You're building momentum. Research shows it takes 21 days to form a habit — keep going!"),
            (7, "1 Week Strong!", "A full week! You're proving to yourself this time is different."),
            (14, "2 Weeks In!", "You're halfway to making this automatic. Your brain is rewiring itself right now."),
            (21, "21 Days — Habit Formed!", "Science says it takes 21 days. You did it! This habit is becoming part of who you are."),
            (30, "30-Day Champion!", "A full month of consistency. You're in the top 8% of habit builders."),
            (50, "50 Days — Unstoppable!", "Half a century of days. This isn't a habit anymore — it's a lifestyle."),
            (100, "100 Days — Legend!", "Triple digits! You've built something truly remarkable."),
        ]

        for milestone in milestones where milestone.days == currentStreak + 1 {
            let content = UNMutableNotificationContent()
            content.title = milestone.title
            content.body = milestone.body
            content.sound = .default

            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(identifier: "streak-milestone-\(milestone.days)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    // MARK: - Daily Scheduling (call from app lifecycle)

    func scheduleDailyNotifications(habits: [(id: UUID, name: String, streak: Int, completed: Bool)]) {
        scheduleStreakAtRiskReminders(habits: habits)
        scheduleMorningMotivation()

        let completed = habits.filter(\.completed).count
        let total = habits.count
        let pending = total - completed
        scheduleEveningReminder(pendingCount: pending)
        scheduleDailySummary(completedCount: completed, totalCount: total, xpEarned: completed * 10)

        if let bestStreak = habits.map(\.streak).max() {
            scheduleStreakCoaching(currentStreak: bestStreak)
            scheduleWeeklyRecap(completedThisWeek: completed, totalThisWeek: total, bestStreak: bestStreak)
        }
    }

    // MARK: - Remove All

    func removeAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
