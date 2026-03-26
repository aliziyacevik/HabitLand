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

        // 1) Try App Group container (works when entitlement is properly provisioned)
        if let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let url = groupURL.appending(path: "HabitLand.sqlite")
            let config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
            if let container = try? ModelContainer(for: schema, configurations: [config]) {
                return container
            }
            HLLogger.data.error("App Group ModelContainer failed, trying default location")
        }

        // 2) Try default SwiftData location (no App Group needed)
        let defaultConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        if let container = try? ModelContainer(for: schema, configurations: [defaultConfig]) {
            return container
        }
        HLLogger.data.error("Default ModelContainer failed, trying in-memory")

        // 3) In-memory fallback (data won't persist but app won't crash)
        let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        if let container = try? ModelContainer(for: schema, configurations: [inMemoryConfig]) {
            return container
        }

        // 4) Bare minimum
        if let bare = try? ModelContainer(for: schema) {
            return bare
        }

        fatalError("SwiftData cannot create any ModelContainer")
    }()
}
