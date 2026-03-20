import SwiftData
import Foundation

enum SharedModelContainer {
    static let appGroupID = "group.azc.HabitLand"

    static var container: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitCompletion.self,
            SleepLog.self,
            UserProfile.self,
            Achievement.self,
            Friend.self,
            Challenge.self,
            AppNotification.self,
        ])

        let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
            .appending(path: "HabitLand.sqlite")

        let config = ModelConfiguration(schema: schema, url: url)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }()
}
