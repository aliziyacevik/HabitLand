import AppIntents
import SwiftData
import Foundation

// MARK: - Habit Entity for AppIntents

struct HabitEntity: AppEntity {
    static var defaultQuery = HabitQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("Habit", table: "AppIntents"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) habits", table: "AppIntents")
        )
    }

    var id: UUID
    var name: String
    var icon: String
    var category: String
    var currentStreak: Int
    var isCompletedToday: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(category) · \(currentStreak) day streak",
            image: .init(systemName: icon)
        )
    }
}

// MARK: - Habit Query

struct HabitQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [HabitEntity] {
        let container = try ModelContainer(for: Habit.self, HabitCompletion.self)
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { !$0.isArchived })
        let habits = try context.fetch(descriptor)
        return habits.filter { identifiers.contains($0.id) }.map { $0.toEntity() }
    }

    func suggestedEntities() async throws -> [HabitEntity] {
        let container = try ModelContainer(for: Habit.self, HabitCompletion.self)
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { !$0.isArchived })
        let habits = try context.fetch(descriptor)
        return habits.map { $0.toEntity() }
    }
}

// MARK: - Habit → Entity conversion

extension Habit {
    func toEntity() -> HabitEntity {
        HabitEntity(
            id: id,
            name: name,
            icon: icon,
            category: category.rawValue,
            currentStreak: currentStreak,
            isCompletedToday: todayCompleted
        )
    }
}
