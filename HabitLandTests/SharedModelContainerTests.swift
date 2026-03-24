import Testing
import Foundation
import SwiftData
@testable import HabitLand

// MARK: - SharedModelContainer Tests

struct SharedModelContainerTests {

    @Test func appGroupIDIsCorrect() {
        #expect(SharedModelContainer.appGroupID == "group.azc.HabitLand")
    }

    @Test func containerIsNotNil() {
        // The container should always be created (with fallbacks)
        let container = SharedModelContainer.container
        let _ = container // Should not crash
    }

    @Test @MainActor func containerSchemaIncludesAllModels() {
        // Verify the container can handle all model types
        let container = SharedModelContainer.container
        let context = container.mainContext

        // Should be able to fetch each model type without crash
        let _ = try? context.fetchCount(FetchDescriptor<Habit>())
        let _ = try? context.fetchCount(FetchDescriptor<HabitCompletion>())
        let _ = try? context.fetchCount(FetchDescriptor<SleepLog>())
        let _ = try? context.fetchCount(FetchDescriptor<UserProfile>())
        let _ = try? context.fetchCount(FetchDescriptor<Achievement>())
        let _ = try? context.fetchCount(FetchDescriptor<Friend>())
        let _ = try? context.fetchCount(FetchDescriptor<Challenge>())
        let _ = try? context.fetchCount(FetchDescriptor<AppNotification>())
    }
}
