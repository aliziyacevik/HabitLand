import AppIntents
import SwiftData
import Foundation

// MARK: - Daily Progress Intent

struct DailyProgressIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("Show Daily Progress", table: "AppIntents")
    static var description: IntentDescription = IntentDescription(
        LocalizedStringResource("Shows how many habits you've completed today", table: "AppIntents"),
        categoryName: LocalizedStringResource("Habits", table: "AppIntents")
    )

    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Habit.self, HabitCompletion.self)
        let context = container.mainContext

        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { !$0.isArchived })
        let habits = try context.fetch(descriptor)

        let today = Calendar.current.startOfDay(for: Date())
        let completed = habits.filter { $0.todayCompleted }
        let total = habits.count
        let completedCount = completed.count

        if total == 0 {
            return .result(dialog: IntentDialog(LocalizedStringResource("You don't have any habits yet. Open HabitLand to create one!", table: "AppIntents")))
        }

        let percentage = total > 0 ? Int(Double(completedCount) / Double(total) * 100) : 0

        if completedCount == total {
            let msg = LocalizedStringResource("All \(total) habits completed today! \(percentage)% — amazing work!", table: "AppIntents")
            return .result(dialog: IntentDialog(msg))
        } else {
            let remaining = total - completedCount
            let msg = LocalizedStringResource("\(completedCount)/\(total) habits done (\(percentage)%). \(remaining) left — you've got this!", table: "AppIntents")
            return .result(dialog: IntentDialog(msg))
        }
    }
}
