import Testing
import Foundation
@testable import HabitLand

// MARK: - StreakFreezeManager Tests

struct StreakFreezeManagerTests {

    // MARK: - Purchase Freeze

    @Test @MainActor func purchaseFreezeSucceedsWithEnoughXP() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.xp = 200
        profile.streakFreezeCount = 0

        let result = StreakFreezeManager.shared.purchaseFreeze(profile: profile)
        #expect(result == true)
        #expect(profile.xp == 100) // 200 - 100
        #expect(profile.streakFreezeCount == 1)
    }

    @Test @MainActor func purchaseFreezeFailsWithInsufficientXP() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.xp = 50
        profile.streakFreezeCount = 0

        let result = StreakFreezeManager.shared.purchaseFreeze(profile: profile)
        #expect(result == false)
        #expect(profile.xp == 50) // unchanged
        #expect(profile.streakFreezeCount == 0) // unchanged
    }

    @Test @MainActor func purchaseFreezeFailsAtMaxStock() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.xp = 500
        profile.streakFreezeCount = StreakFreezeManager.maxFreezeStock // 5

        let result = StreakFreezeManager.shared.purchaseFreeze(profile: profile)
        #expect(result == false)
        #expect(profile.xp == 500) // unchanged
        #expect(profile.streakFreezeCount == 5) // unchanged
    }

    @Test @MainActor func purchaseMultipleFreezes() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.xp = 300
        profile.streakFreezeCount = 0

        let r1 = StreakFreezeManager.shared.purchaseFreeze(profile: profile)
        let r2 = StreakFreezeManager.shared.purchaseFreeze(profile: profile)
        let r3 = StreakFreezeManager.shared.purchaseFreeze(profile: profile)

        #expect(r1 == true)
        #expect(r2 == true)
        #expect(r3 == true)
        #expect(profile.xp == 0)
        #expect(profile.streakFreezeCount == 3)
    }

    @Test @MainActor func purchaseFreezeExactlyAtCost() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.xp = 100
        profile.streakFreezeCount = 0

        let result = StreakFreezeManager.shared.purchaseFreeze(profile: profile)
        #expect(result == true)
        #expect(profile.xp == 0)
        #expect(profile.streakFreezeCount == 1)
    }

    // MARK: - Use Freeze

    @Test @MainActor func useFreezeSucceeds() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.streakFreezeCount = 2
        profile.streakFreezeUsedDates = []

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = StreakFreezeManager.shared.useFreeze(profile: profile, for: yesterday)

        #expect(result == true)
        #expect(profile.streakFreezeCount == 1)
        #expect(profile.streakFreezeUsedDates.count == 1)
    }

    @Test @MainActor func useFreezeFailsWithNoFreezes() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.streakFreezeCount = 0
        profile.streakFreezeUsedDates = []

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = StreakFreezeManager.shared.useFreeze(profile: profile, for: yesterday)

        #expect(result == false)
        #expect(profile.streakFreezeCount == 0)
    }

    @Test @MainActor func useFreezeRejectsDuplicateDay() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.streakFreezeCount = 3
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        profile.streakFreezeUsedDates = [Calendar.current.startOfDay(for: yesterday)]

        let result = StreakFreezeManager.shared.useFreeze(profile: profile, for: yesterday)

        #expect(result == false)
        #expect(profile.streakFreezeCount == 3) // unchanged
        #expect(profile.streakFreezeUsedDates.count == 1) // unchanged
    }

    @Test @MainActor func useFreezeDifferentDays() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.streakFreezeCount = 3
        profile.streakFreezeUsedDates = []
        let calendar = Calendar.current

        let day1 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let day2 = calendar.date(byAdding: .day, value: -2, to: Date())!

        let r1 = StreakFreezeManager.shared.useFreeze(profile: profile, for: day1)
        let r2 = StreakFreezeManager.shared.useFreeze(profile: profile, for: day2)

        #expect(r1 == true)
        #expect(r2 == true)
        #expect(profile.streakFreezeCount == 1)
        #expect(profile.streakFreezeUsedDates.count == 2)
    }

    // MARK: - Is Day Frozen

    @Test @MainActor func isDayFrozenReturnsTrueForFrozenDay() {
        let profile = UserProfile(name: "Test", username: "@test")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        profile.streakFreezeUsedDates = [Calendar.current.startOfDay(for: yesterday)]

        let result = StreakFreezeManager.shared.isDayFrozen(yesterday, profile: profile)
        #expect(result == true)
    }

    @Test @MainActor func isDayFrozenReturnsFalseForNonFrozenDay() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.streakFreezeUsedDates = []

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = StreakFreezeManager.shared.isDayFrozen(yesterday, profile: profile)
        #expect(result == false)
    }

    // MARK: - Constants

    @Test func freezeCostIs100XP() {
        #expect(StreakFreezeManager.freezeCostXP == 100)
    }

    @Test func maxFreezeStockIs5() {
        #expect(StreakFreezeManager.maxFreezeStock == 5)
    }

    // MARK: - Auto-Freeze

    @Test @MainActor func checkAndAutoFreezeDoesNothingWithNoActiveHabits() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.streakFreezeCount = 3
        profile.streakFreezeUsedDates = []

        // No habits with active streaks
        let habits: [Habit] = []
        StreakFreezeManager.shared.checkAndAutoFreeze(profile: profile, habits: habits)

        #expect(profile.streakFreezeCount == 3) // unchanged
    }

    @Test @MainActor func checkAndAutoFreezeDoesNothingWhenAllArchived() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.streakFreezeCount = 3
        profile.streakFreezeUsedDates = []

        let habit = Habit(name: "Test")
        habit.isArchived = true
        StreakFreezeManager.shared.checkAndAutoFreeze(profile: profile, habits: [habit])

        #expect(profile.streakFreezeCount == 3) // unchanged
    }
}
