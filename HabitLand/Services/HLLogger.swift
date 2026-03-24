import os

enum HLLogger {
    static let storekit = Logger(subsystem: "com.azc.HabitLand", category: "storekit")
    static let cloudkit = Logger(subsystem: "com.azc.HabitLand", category: "cloudkit")
    static let healthkit = Logger(subsystem: "com.azc.HabitLand", category: "healthkit")
    static let app = Logger(subsystem: "com.azc.HabitLand", category: "app")
    static let data = Logger(subsystem: "com.azc.HabitLand", category: "data")
    static let export = Logger(subsystem: "com.azc.HabitLand", category: "export")
    static let audio = Logger(subsystem: "com.azc.HabitLand", category: "audio")
    static let quests = Logger(subsystem: "com.azc.HabitLand", category: "quests")
}
