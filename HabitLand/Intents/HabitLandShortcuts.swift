import AppIntents

// MARK: - App Shortcuts Provider

struct HabitLandShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CompleteHabitIntent(),
            phrases: [
                "Complete \(\.$habit) in \(.applicationName)",
                "Mark \(\.$habit) done in \(.applicationName)",
                "I finished \(\.$habit) in \(.applicationName)",
                "Log \(\.$habit) in \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource("Complete Habit", table: "AppIntents"),
            systemImageName: "checkmark.circle.fill"
        )

        AppShortcut(
            intent: DailyProgressIntent(),
            phrases: [
                "Show my progress in \(.applicationName)",
                "How am I doing in \(.applicationName)",
                "Daily progress in \(.applicationName)",
                "What's my progress in \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource("Daily Progress", table: "AppIntents"),
            systemImageName: "chart.bar.fill"
        )

        AppShortcut(
            intent: ShowStreakIntent(),
            phrases: [
                "Show my streak in \(.applicationName)",
                "What's my streak in \(.applicationName)",
                "How long is my streak in \(.applicationName)",
                "My habit streak in \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource("My Streak", table: "AppIntents"),
            systemImageName: "flame.fill"
        )

        AppShortcut(
            intent: LogSleepIntent(),
            phrases: [
                "Log sleep in \(.applicationName)",
                "Record my sleep in \(.applicationName)",
                "How did I sleep in \(.applicationName)",
                "Track sleep in \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource("Log Sleep", table: "AppIntents"),
            systemImageName: "moon.fill"
        )

        AppShortcut(
            intent: StartPomodoroIntent(),
            phrases: [
                "Start pomodoro in \(.applicationName)",
                "Start focus session in \(.applicationName)",
                "Focus time in \(.applicationName)",
                "Start timer in \(.applicationName)",
            ],
            shortTitle: LocalizedStringResource("Start Pomodoro", table: "AppIntents"),
            systemImageName: "timer"
        )
    }
}
