import Foundation
import UIKit
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

    func scheduleHabitReminder(habitId: UUID, habitName: String, icon: String = "", at time: Date, customMessage: String = "") {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(habitName)"
        content.body = customMessage.isEmpty ? "Time for \(habitName)!" : customMessage
        content.sound = .default

        if !icon.isEmpty, let attachment = createIconAttachment(systemName: icon, identifier: habitId.uuidString) {
            content.attachments = [attachment]
        }

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "habit-\(habitId.uuidString)",
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    private func createIconAttachment(systemName: String, identifier: String) -> UNNotificationAttachment? {
        let size: CGFloat = 100
        let config = UIImage.SymbolConfiguration(pointSize: size * 0.6, weight: .medium)
        guard let symbol = UIImage(systemName: systemName, withConfiguration: config) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { ctx in
            UIColor.systemBackground.setFill()
            ctx.fill(CGRect(origin: .zero, size: CGSize(width: size, height: size)))

            let symbolSize = symbol.size
            let origin = CGPoint(x: (size - symbolSize.width) / 2, y: (size - symbolSize.height) / 2)
            symbol.withTintColor(.label, renderingMode: .alwaysOriginal)
                .draw(at: origin)
        }

        guard let pngData = image.pngData() else { return nil }

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("habit-icon-\(identifier).png")
        do {
            try pngData.write(to: fileURL)
            return try UNNotificationAttachment(identifier: "icon-\(identifier)", url: fileURL, options: [
                UNNotificationAttachmentOptionsThumbnailHiddenKey: false
            ])
        } catch {
            return nil
        }
    }

    func scheduleTestNotification(habitId: UUID, habitName: String, icon: String, customMessage: String) {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(habitName)"
        content.body = customMessage.isEmpty ? "Time for \(habitName)!" : customMessage
        content.sound = .default

        if !icon.isEmpty, let attachment = createIconAttachment(systemName: icon, identifier: "test-\(habitId.uuidString)") {
            content.attachments = [attachment]
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-\(habitId.uuidString)",
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

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let pick = messages[dayOfYear % messages.count]
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
