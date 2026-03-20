import AppIntents
import SwiftData
import Foundation

// MARK: - Complete Habit Intent

struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("Complete Habit", table: "AppIntents")
    static var description: IntentDescription = IntentDescription(
        LocalizedStringResource("Mark a habit as completed for today", table: "AppIntents"),
        categoryName: LocalizedStringResource("Habits", table: "AppIntents")
    )

    static var openAppWhenRun: Bool = false

    @Parameter(
        title: LocalizedStringResource("Habit", table: "AppIntents"),
        description: LocalizedStringResource("The habit to complete", table: "AppIntents")
    )
    var habit: HabitEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Habit.self, HabitCompletion.self, UserProfile.self)
        let context = container.mainContext

        let habitId = habit.id
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == habitId })
        guard let habitModel = try context.fetch(descriptor).first else {
            return .result(dialog: IntentDialog(LocalizedStringResource("Habit not found.", table: "AppIntents")))
        }

        // Check if already completed today
        if habitModel.todayCompleted {
            let alreadyDone = LocalizedStringResource("'\(habitModel.name)' is already completed today! Keep it up!", table: "AppIntents")
            return .result(dialog: IntentDialog(alreadyDone))
        }

        // Create completion
        let completion = HabitCompletion(date: Date(), isCompleted: true)
        completion.habit = habitModel
        context.insert(completion)

        // Award XP
        let profileDescriptor = FetchDescriptor<UserProfile>()
        if let profile = try context.fetch(profileDescriptor).first {
            profile.xp += 10
            if profile.xp >= profile.xpForNextLevel {
                profile.xp -= profile.xpForNextLevel
                profile.level += 1
            }
        }

        try context.save()

        // Donate to Spotlight
        CompleteHabitIntent.donate(habit: habit)

        let streak = habitModel.currentStreak + 1
        let successMsg = LocalizedStringResource("Done! '\(habitModel.name)' completed. \(streak)-day streak!", table: "AppIntents")
        return .result(dialog: IntentDialog(successMsg))
    }

    static func donate(habit: HabitEntity) {
        let intent = CompleteHabitIntent()
        intent.habit = habit
        Task {
            try? await intent.donate()
        }
    }
}
