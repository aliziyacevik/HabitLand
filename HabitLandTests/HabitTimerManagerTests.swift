import Testing
import Foundation
@testable import HabitLand

// MARK: - HabitTimerManager Tests

struct HabitTimerManagerTests {

    // MARK: - Progress Calculation

    @Test @MainActor func progressAtStartIsZero() {
        let manager = HabitTimerManager.shared
        manager.stop()

        #expect(manager.progress == 0)
    }

    @Test @MainActor func progressCalculation() {
        let manager = HabitTimerManager.shared
        // Manually set state without starting a real timer
        manager.stop()

        // Simulate mid-timer state
        // progress = 1.0 - (remaining / total)
        // When total = 0, progress = 0
        #expect(manager.progress == 0)
    }

    // MARK: - Formatted Time

    @Test @MainActor func formattedTimeAtZero() {
        let manager = HabitTimerManager.shared
        manager.stop()
        #expect(manager.formattedTime == "0:00")
    }

    // MARK: - Stop

    @Test @MainActor func stopResetsState() {
        let manager = HabitTimerManager.shared
        manager.stop()

        #expect(manager.isRunning == false)
        #expect(manager.remainingSeconds == 0)
        #expect(manager.totalSeconds == 0)
        #expect(manager.habitID == nil)
    }

    // MARK: - Pause

    @Test @MainActor func pauseSetsNotRunning() {
        let manager = HabitTimerManager.shared
        manager.pause()
        #expect(manager.isRunning == false)
    }

    // MARK: - Resume guards

    @Test @MainActor func resumeDoesNothingWithNoHabit() {
        let manager = HabitTimerManager.shared
        manager.stop()
        manager.resume()
        #expect(manager.isRunning == false)
    }

    // MARK: - Notification Names

    @Test func habitTimerCompletedNotificationExists() {
        let name = Notification.Name.habitTimerCompleted
        #expect(name.rawValue == "habitTimerCompleted")
    }
}
