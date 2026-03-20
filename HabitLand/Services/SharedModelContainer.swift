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

        let config: ModelConfiguration

        if let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let url = groupURL.appending(path: "HabitLand.sqlite")
            // Use CloudKit private database for automatic habit/completion sync across devices
            // Social features use CloudKitManager with the public database separately
            config = ModelConfiguration(schema: schema, url: url,
                                        cloudKitDatabase: .private("iCloud.azc.HabitLand"))
        } else {
            config = ModelConfiguration(schema: schema,
                                        cloudKitDatabase: .private("iCloud.azc.HabitLand"))
        }

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }()
}
