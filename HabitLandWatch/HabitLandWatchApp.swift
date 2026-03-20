import SwiftUI
import SwiftData

@main
struct HabitLandWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchHomeView()
        }
        .modelContainer(SharedModelContainer.container)
    }
}
