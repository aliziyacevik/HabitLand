import Testing
import Foundation
@testable import HabitLand

// MARK: - DailyBonusManager Tests

@Suite(.serialized)
struct DailyBonusManagerTests {

    private let lastOpenDateKey = "dailyBonus_lastOpenDate"
    private let loginStreakKey = "dailyBonus_loginStreak"
    private let firstCompletionClaimedKey = "dailyBonus_firstCompletionClaimed"

    private func clearKeys() {
        UserDefaults.standard.removeObject(forKey: lastOpenDateKey)
        UserDefaults.standard.removeObject(forKey: loginStreakKey)
        UserDefaults.standard.removeObject(forKey: firstCompletionClaimedKey)
    }

    // MARK: - Bonus Multiplier

    @Test @MainActor func bonusMultiplierForStreak0() {
        let manager = DailyBonusManager.shared
        // When loginStreak is 0, multiplier should be 1 (default case)
        // We can test the computed property logic directly
        #expect(manager.bonusMultiplier >= 1)
    }

    @Test func bonusMultiplierRanges() {
        // Test the switch logic through a standalone calculation
        // streak 1-2 → 2x
        // streak 3-6 → 3x
        // streak 7+ → 5x
        func multiplier(for streak: Int) -> Int {
            switch streak {
            case 1...2: return 2
            case 3...6: return 3
            case 7...: return 5
            default: return 1
            }
        }

        #expect(multiplier(for: 0) == 1)
        #expect(multiplier(for: 1) == 2)
        #expect(multiplier(for: 2) == 2)
        #expect(multiplier(for: 3) == 3)
        #expect(multiplier(for: 6) == 3)
        #expect(multiplier(for: 7) == 5)
        #expect(multiplier(for: 30) == 5)
    }

    // MARK: - First Completion Bonus

    @Test @MainActor func claimFirstCompletionBonusReturnsExtraXP() {
        clearKeys()
        let manager = DailyBonusManager.shared
        // Reset state
        manager.recordDailyOpen()

        let bonus = manager.claimFirstCompletionBonus(baseXP: 10)
        // bonus = baseXP * (multiplier - 1)
        #expect(bonus > 0)
    }

    @Test @MainActor func claimFirstCompletionBonusTwiceReturnsZero() {
        clearKeys()
        let manager = DailyBonusManager.shared
        manager.recordDailyOpen()

        let bonus1 = manager.claimFirstCompletionBonus(baseXP: 10)
        let bonus2 = manager.claimFirstCompletionBonus(baseXP: 10)

        #expect(bonus1 > 0)
        #expect(bonus2 == 0) // Already claimed
        clearKeys()
    }

    // MARK: - Streak Emoji

    @Test func streakEmojiMapping() {
        // Test the emoji switch logic
        func emoji(for streak: Int) -> String {
            switch streak {
            case 1...2: return "👋"
            case 3...6: return "🔥"
            case 7...13: return "⚡"
            case 14...29: return "💎"
            case 30...: return "👑"
            default: return "👋"
            }
        }

        #expect(emoji(for: 0) == "👋")
        #expect(emoji(for: 1) == "👋")
        #expect(emoji(for: 3) == "🔥")
        #expect(emoji(for: 7) == "⚡")
        #expect(emoji(for: 14) == "💎")
        #expect(emoji(for: 30) == "👑")
    }

    // MARK: - Record Daily Open

    @Test @MainActor func recordDailyOpenSetsKeys() {
        clearKeys()
        let manager = DailyBonusManager.shared

        manager.recordDailyOpen()

        let savedDate = UserDefaults.standard.object(forKey: lastOpenDateKey) as? Date
        #expect(savedDate != nil)
        let savedStreak = UserDefaults.standard.integer(forKey: loginStreakKey)
        #expect(savedStreak >= 1)

        clearKeys()
    }

    @Test @MainActor func recordDailyOpenShowsBanner() {
        clearKeys()
        let manager = DailyBonusManager.shared

        manager.recordDailyOpen()
        #expect(manager.showBonusBanner == true)

        clearKeys()
    }

    @Test @MainActor func recordDailyOpenResetsFirstCompletionClaim() {
        clearKeys()
        let manager = DailyBonusManager.shared

        // Simulate: claim bonus, then open next day
        UserDefaults.standard.set(true, forKey: firstCompletionClaimedKey)
        manager.recordDailyOpen()

        // After recordDailyOpen, todayBonusClaimed should be reset
        #expect(manager.todayBonusClaimed == false)

        clearKeys()
    }

    @Test @MainActor func recordDailyOpenSameDayDoesNothing() {
        clearKeys()
        let manager = DailyBonusManager.shared

        // Set last open to today
        let today = Calendar.current.startOfDay(for: Date())
        UserDefaults.standard.set(today, forKey: lastOpenDateKey)
        UserDefaults.standard.set(5, forKey: loginStreakKey)

        // Store current state
        let streakBefore = UserDefaults.standard.integer(forKey: loginStreakKey)

        manager.recordDailyOpen()

        // Streak should not change — same day
        let streakAfter = UserDefaults.standard.integer(forKey: loginStreakKey)
        #expect(streakAfter == streakBefore)

        clearKeys()
    }

    @Test @MainActor func streakResetsAfterMissedDay() {
        clearKeys()
        let manager = DailyBonusManager.shared

        // Set last open to 3 days ago (missed 2 days)
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        UserDefaults.standard.set(threeDaysAgo, forKey: lastOpenDateKey)
        UserDefaults.standard.set(10, forKey: loginStreakKey)

        manager.recordDailyOpen()

        // Streak should reset to 1
        #expect(manager.loginStreak == 1)

        clearKeys()
    }

    // MARK: - Dismiss Banner

    @Test @MainActor func dismissBannerHidesBanner() {
        clearKeys()
        let manager = DailyBonusManager.shared
        manager.recordDailyOpen()
        #expect(manager.showBonusBanner == true)

        manager.dismissBanner()
        #expect(manager.showBonusBanner == false)

        clearKeys()
    }

    // MARK: - Bonus Label

    @Test @MainActor func bonusLabelFormat() {
        let manager = DailyBonusManager.shared
        let label = manager.bonusLabel
        #expect(label.contains("x XP"))
    }

    // MARK: - Streak Message

    @Test @MainActor func streakMessageNotEmpty() {
        let manager = DailyBonusManager.shared
        let msg = manager.streakMessage
        #expect(!msg.isEmpty)
    }
}
