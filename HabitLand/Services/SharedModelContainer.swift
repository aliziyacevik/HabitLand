import Foundation
import os
import SwiftData

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
            config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .private("iCloud.azc.HabitLand"))
        } else {
            config = ModelConfiguration(schema: schema, cloudKitDatabase: .private("iCloud.azc.HabitLand"))
        }

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Fallback: try without CloudKit sync if iCloud setup fails
            HLLogger.data.error("CloudKit ModelContainer failed, falling back to local-only: \(error.localizedDescription, privacy: .public)")
            let fallbackConfig: ModelConfiguration
            if let groupURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
                let url = groupURL.appending(path: "HabitLand.sqlite")
                fallbackConfig = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
            } else {
                fallbackConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            }
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                HLLogger.data.fault("ModelContainer creation failed completely: \(error.localizedDescription, privacy: .public)")
                // Last resort: in-memory container so app doesn't crash
                let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                do {
                    return try ModelContainer(for: schema, configurations: [inMemoryConfig])
                } catch {
                    assertionFailure("All ModelContainer creation paths failed: \(error)")
                    HLLogger.data.fault("All ModelContainer paths failed: \(error.localizedDescription, privacy: .public)")
                    return try! ModelContainer(for: schema)
                }
            }
        }
    }()
}
