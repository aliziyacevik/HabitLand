import AppIntents
import Foundation

// MARK: - Start Pomodoro Intent

struct StartPomodoroIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("Start Pomodoro", table: "AppIntents")
    static var description: IntentDescription = IntentDescription(
        LocalizedStringResource("Start a Pomodoro focus session in HabitLand", table: "AppIntents"),
        categoryName: LocalizedStringResource("Focus", table: "AppIntents")
    )

    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Post notification so the app can open the Pomodoro view
        NotificationCenter.default.post(
            name: Notification.Name("openPomodoro"),
            object: nil
        )

        return .result(dialog: IntentDialog(LocalizedStringResource("Starting your Pomodoro focus session. Stay focused!", table: "AppIntents")))
    }
}
