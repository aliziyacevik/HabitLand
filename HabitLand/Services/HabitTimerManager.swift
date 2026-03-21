import Foundation
import UserNotifications
import SwiftUI

@MainActor
final class HabitTimerManager: ObservableObject {
    static let shared = HabitTimerManager()

    @Published var isRunning = false
    @Published var remainingSeconds: Int = 0
    @Published var totalSeconds: Int = 0
    @Published var habitID: UUID?
    @Published var habitName: String = ""
    @Published var habitIcon: String = ""
    @Published var habitColor: Color = .hlPrimary

    private var timer: Timer?
    private var backgroundDate: Date?

    private init() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleBackground()
            }
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleForeground()
            }
        }
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    func start(habit: (id: UUID, name: String, icon: String, color: Color, minutes: Int)) {
        stop()
        habitID = habit.id
        habitName = habit.name
        habitIcon = habit.icon
        habitColor = habit.color
        totalSeconds = habit.minutes * 60
        remainingSeconds = totalSeconds
        isRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingSeconds = 0
        totalSeconds = 0
        habitID = nil
        cancelTimerNotification()
    }

    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func resume() {
        guard remainingSeconds > 0, habitID != nil else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            complete()
            return
        }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            complete()
        }
    }

    private func complete() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        HLHaptics.success()
        // Post notification for completion handling
        NotificationCenter.default.post(name: .habitTimerCompleted, object: habitID)
    }

    // MARK: - Background Support

    private func handleBackground() {
        guard isRunning, remainingSeconds > 0 else { return }
        backgroundDate = Date()
        timer?.invalidate()
        timer = nil
        scheduleTimerNotification()
    }

    private func handleForeground() {
        cancelTimerNotification()
        guard let bg = backgroundDate, habitID != nil else { return }
        let elapsed = Int(Date().timeIntervalSince(bg))
        backgroundDate = nil
        remainingSeconds = max(0, remainingSeconds - elapsed)
        if remainingSeconds == 0 {
            complete()
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.tick()
                }
            }
        }
    }

    private func scheduleTimerNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(habitName) Complete!"
        content.body = "Your timer has finished. Great job!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(remainingSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: "habit-timer", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelTimerNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["habit-timer"])
    }
}

extension Notification.Name {
    static let habitTimerCompleted = Notification.Name("habitTimerCompleted")
}
