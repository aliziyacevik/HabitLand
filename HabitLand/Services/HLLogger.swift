import os

enum HLLogger {
    static let storekit = Logger(subsystem: "com.azc.HabitLand", category: "storekit")
    static let cloudkit = Logger(subsystem: "com.azc.HabitLand", category: "cloudkit")
    static let healthkit = Logger(subsystem: "com.azc.HabitLand", category: "healthkit")
    static let app = Logger(subsystem: "com.azc.HabitLand", category: "app")
    static let data = Logger(subsystem: "com.azc.HabitLand", category: "data")
}
