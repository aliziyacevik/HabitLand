import AppIntents
import SwiftData
import Foundation

// MARK: - Show Streak Intent

struct ShowStreakIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("Show My Streak", table: "AppIntents")
    static var description: IntentDescription = IntentDescription(
        LocalizedStringResource("Shows your current and best habit streaks", table: "AppIntents"),
        categoryName: LocalizedStringResource("Habits", table: "AppIntents")
    )

    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Habit.self, HabitCompletion.self)
        let context = container.mainContext

        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { !$0.isArchived })
        let habits = try context.fetch(descriptor)

        if habits.isEmpty {
            return .result(dialog: IntentDialog(LocalizedStringResource("No habits found. Open HabitLand to get started!", table: "AppIntents")))
        }

        // Find the habit with the longest current streak
        let sorted = habits.sorted { $0.currentStreak > $1.currentStreak }
        guard let best = sorted.first else {
            return .result(dialog: IntentDialog(LocalizedStringResource("No habits found.", table: "AppIntents")))
        }
        let totalStreaks = habits.map(\.currentStreak).reduce(0, +)
        let activeStreaks = habits.filter { $0.currentStreak > 0 }.count

        if best.currentStreak == 0 {
            return .result(dialog: IntentDialog(LocalizedStringResource("No active streaks right now. Complete a habit to start one!", table: "AppIntents")))
        }

        let msg = LocalizedStringResource("Your best streak: '\(best.name)' at \(best.currentStreak) days! \(activeStreaks) active streaks across your habits.", table: "AppIntents")
        return .result(dialog: IntentDialog(msg))
    }
}
