import Testing
import Foundation
import SwiftUI
@testable import HabitLand

// MARK: - Habit Model Edge Cases

struct HabitModelEdgeCaseTests {

    // MARK: - Safe Completions

    @Test func safeCompletionsWithNilReturnsEmpty() {
        let habit = Habit(name: "Test")
        habit.completions = nil
        #expect(habit.safeCompletions.isEmpty)
    }

    @Test func safeCompletionsWithEmptyArrayReturnsEmpty() {
        let habit = Habit(name: "Test")
        habit.completions = []
        #expect(habit.safeCompletions.isEmpty)
    }

    // MARK: - Streak Edge Cases

    @Test func currentStreakWithNoCompletions() {
        let habit = Habit(name: "Test")
        #expect(habit.currentStreak == 0)
    }

    @Test func currentStreakWithNilCompletions() {
        let habit = Habit(name: "Test")
        habit.completions = nil
        #expect(habit.currentStreak == 0)
    }

    @Test func bestStreakWithNoCompletions() {
        let habit = Habit(name: "Test")
        #expect(habit.bestStreak == 0)
    }

    @Test func bestStreakWithSingleCompletion() {
        let habit = Habit(name: "Test")
        let c = HabitCompletion(date: Date())
        c.habit = habit
        habit.completions = [c]
        #expect(habit.bestStreak == 1)
    }

    @Test func bestStreakIgnoresIncompleteEntries() {
        let habit = Habit(name: "Test")
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Add completed and incomplete
        let c1 = HabitCompletion(date: today, isCompleted: true)
        c1.habit = habit
        let c2 = HabitCompletion(date: calendar.date(byAdding: .day, value: -1, to: today)!, isCompleted: false)
        c2.habit = habit
        let c3 = HabitCompletion(date: calendar.date(byAdding: .day, value: -2, to: today)!, isCompleted: true)
        c3.habit = habit

        habit.completions = [c1, c2, c3]
        // c2 is not completed, so best streak = 1 (just today or just day-2)
        #expect(habit.bestStreak == 1)
    }

    @Test func bestStreakHandlesDuplicateDays() {
        let habit = Habit(name: "Test")
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Two completions on the same day
        let c1 = HabitCompletion(date: today, isCompleted: true)
        c1.habit = habit
        let c2 = HabitCompletion(date: today, isCompleted: true)
        c2.habit = habit

        habit.completions = [c1, c2]
        #expect(habit.bestStreak == 1) // Same day, still 1
    }

    // MARK: - Today Progress Edge Cases

    @Test func todayProgressIsZeroWithNoCompletion() {
        let habit = Habit(name: "Test")
        #expect(habit.todayProgress == 0.0)
    }

    @Test func todayProgressIsOneWithCompletion() {
        let habit = Habit(name: "Test")
        let c1 = HabitCompletion(date: Date())
        c1.habit = habit
        habit.completions = [c1]
        #expect(habit.todayProgress == 1.0)
    }

    // MARK: - Week Completion Rate Edge Cases

    @Test func weekCompletionRateWithNoTargetDays() {
        let habit = Habit(name: "Test", targetDays: [])
        // expectedDays = max(0, 1) = 1
        #expect(habit.weekCompletionRate >= 0)
    }

    // MARK: - Total Completions

    @Test func totalCompletionsIgnoresIncomplete() {
        let habit = Habit(name: "Test")
        let c1 = HabitCompletion(date: Date(), isCompleted: true)
        c1.habit = habit
        let c2 = HabitCompletion(date: Date(), isCompleted: false)
        c2.habit = habit
        habit.completions = [c1, c2]
        #expect(habit.totalCompletions == 1)
    }
}

// MARK: - HabitMastery Tests

struct HabitMasteryTests {

    @Test func forStreakReturnsCorrectMastery() {
        #expect(HabitMastery.forStreak(0) == .none)
        #expect(HabitMastery.forStreak(29) == .none)
        #expect(HabitMastery.forStreak(30) == .bronze)
        #expect(HabitMastery.forStreak(59) == .bronze)
        #expect(HabitMastery.forStreak(60) == .silver)
        #expect(HabitMastery.forStreak(89) == .silver)
        #expect(HabitMastery.forStreak(90) == .gold)
        #expect(HabitMastery.forStreak(365) == .gold)
    }

    @Test func masteryMinStreakValues() {
        #expect(HabitMastery.none.minStreak == 0)
        #expect(HabitMastery.bronze.minStreak == 30)
        #expect(HabitMastery.silver.minStreak == 60)
        #expect(HabitMastery.gold.minStreak == 90)
    }

    @Test func masteryLabels() {
        #expect(HabitMastery.none.label == "")
        #expect(HabitMastery.bronze.label == "Apprentice")
        #expect(HabitMastery.silver.label == "Master")
        #expect(HabitMastery.gold.label == "Grand Master")
    }

    @Test func masteryIcons() {
        #expect(HabitMastery.none.icon == "")
        #expect(!HabitMastery.bronze.icon.isEmpty)
        #expect(!HabitMastery.silver.icon.isEmpty)
        #expect(!HabitMastery.gold.icon.isEmpty)
    }

    @Test func habitMasteryProperty() {
        let habit = Habit(name: "Test")
        // No completions → bestStreak = 0 → mastery = .none
        #expect(habit.mastery == .none)
    }
}

// MARK: - SleepLog Edge Cases

struct SleepLogEdgeCaseTests {

    @Test func durationCalculation() {
        let bedtime = Date()
        let wakeup = bedtime.addingTimeInterval(8 * 3600) // 8 hours
        let log = SleepLog(bedTime: bedtime, wakeTime: wakeup)
        #expect(abs(log.duration - 28800) < 1) // 8h = 28800s
        #expect(abs(log.durationHours - 8.0) < 0.01)
    }

    @Test func durationFormattedString() {
        let bedtime = Date()
        let wakeup = bedtime.addingTimeInterval(7 * 3600 + 30 * 60) // 7h 30m
        let log = SleepLog(bedTime: bedtime, wakeTime: wakeup)
        #expect(log.durationFormatted == "7h 30m")
    }

    @Test func zeroDuration() {
        let now = Date()
        let log = SleepLog(bedTime: now, wakeTime: now)
        #expect(log.duration == 0)
        #expect(log.durationHours == 0)
        #expect(log.durationFormatted == "0h 0m")
    }

    @Test func defaultQualityIsGood() {
        let bedtime = Date()
        let wakeup = bedtime.addingTimeInterval(8 * 3600)
        let log = SleepLog(bedTime: bedtime, wakeTime: wakeup)
        #expect(log.quality == .good)
    }

    @Test func defaultMoodIs3() {
        let bedtime = Date()
        let wakeup = bedtime.addingTimeInterval(8 * 3600)
        let log = SleepLog(bedTime: bedtime, wakeTime: wakeup)
        #expect(log.mood == 3)
    }
}

// MARK: - UserProfile Referral Code Tests

struct UserProfileReferralTests {

    @Test func generateReferralCodeReturnsLength6() {
        let uuid = UUID()
        let code = UserProfile.generateReferralCode(from: uuid)
        #expect(code.count == 6)
    }

    @Test func generateReferralCodeUsesAllowedChars() {
        let allowed = Set("ABCDEFGHJKMNPQRSTUVWXYZ23456789")
        for _ in 0..<10 {
            let code = UserProfile.generateReferralCode(from: UUID())
            for char in code {
                #expect(allowed.contains(char))
            }
        }
    }

    @Test func generateReferralCodeIsDeterministic() {
        let uuid = UUID()
        let code1 = UserProfile.generateReferralCode(from: uuid)
        let code2 = UserProfile.generateReferralCode(from: uuid)
        #expect(code1 == code2)
    }

    @Test func displayReferralCodeFormat() {
        let profile = UserProfile(name: "Test")
        profile.referralCode = "ABC123"
        #expect(profile.displayReferralCode == "HBT-ABC123")
    }

    @Test func displayReferralCodeEmptyWhenNil() {
        let profile = UserProfile(name: "Test")
        profile.referralCode = nil
        #expect(profile.displayReferralCode == "")
    }
}

// MARK: - AchievementRarity Tests

struct AchievementRarityTests {

    @Test func allRaritiesHavePositiveXP() {
        for rarity in AchievementRarity.allCases {
            #expect(rarity.xpReward > 0)
        }
    }

    @Test func xpRewardsAscend() {
        let rewards = AchievementRarity.allCases.map(\.xpReward)
        for i in 1..<rewards.count {
            #expect(rewards[i] > rewards[i - 1])
        }
    }

    @Test func allRaritiesHaveIcon() {
        for rarity in AchievementRarity.allCases {
            #expect(!rarity.icon.isEmpty)
        }
    }

    @Test func forAchievementMapping() {
        // Common
        #expect(AchievementRarity.forAchievement("Habit Creator") == .common)
        #expect(AchievementRarity.forAchievement("First Step") == .common)
        #expect(AchievementRarity.forAchievement("Early Bird") == .common)

        // Uncommon
        #expect(AchievementRarity.forAchievement("On Fire") == .uncommon)
        #expect(AchievementRarity.forAchievement("Century") == .uncommon)

        // Rare
        #expect(AchievementRarity.forAchievement("Unstoppable") == .rare)
        #expect(AchievementRarity.forAchievement("Perfect Week") == .rare)

        // Epic
        #expect(AchievementRarity.forAchievement("Iron Will") == .epic)
        #expect(AchievementRarity.forAchievement("Titanium") == .epic)

        // Legendary
        #expect(AchievementRarity.forAchievement("Eternal") == .legendary)
        #expect(AchievementRarity.forAchievement("Legendary") == .legendary)
    }

    @Test func unknownAchievementDefaultsToCommon() {
        #expect(AchievementRarity.forAchievement("Unknown Achievement") == .common)
    }
}

// MARK: - Color Hex Extension Tests

struct ColorHexTests {

    @Test func validHexReturnsColor() {
        let color = Color(hex: "#34C759")
        #expect(color != nil)
    }

    @Test func validHexWithoutHashReturnsColor() {
        let color = Color(hex: "34C759")
        #expect(color != nil)
    }

    @Test func invalidHexReturnsNil() {
        let color = Color(hex: "invalid")
        #expect(color == nil)
    }

    @Test func emptyStringReturnsNil() {
        let color = Color(hex: "")
        #expect(color == nil)
    }

    @Test func whiteHex() {
        let color = Color(hex: "#FFFFFF")
        #expect(color != nil)
    }

    @Test func blackHex() {
        let color = Color(hex: "#000000")
        #expect(color != nil)
    }
}

// MARK: - Challenge Tests

struct ChallengeTests {

    @Test func defaultChallengeIsActive() {
        let challenge = Challenge(name: "Test", descriptionText: "Desc")
        #expect(challenge.isActive == true)
        #expect(challenge.progress == 0)
    }

    @Test func daysRemainingCalculation() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let challenge = Challenge(name: "Test", descriptionText: "Desc", endDate: futureDate)
        #expect(challenge.daysRemaining >= 4 && challenge.daysRemaining <= 5)
    }

    @Test func daysRemainingForExpiredChallenge() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let challenge = Challenge(name: "Test", descriptionText: "Desc", endDate: pastDate)
        #expect(challenge.daysRemaining == 0)
    }
}

// MARK: - AppNotification Tests

struct AppNotificationTests {

    @Test func defaultNotificationIsUnread() {
        let notification = AppNotification(title: "Test", body: "Body")
        #expect(notification.isRead == false)
        #expect(notification.type == .general)
    }

    @Test func notificationWithCustomType() {
        let notification = AppNotification(title: "Test", body: "Body", type: .achievement)
        #expect(notification.type == .achievement)
    }
}

// MARK: - Friend Tests

struct FriendTests {

    @Test func defaultFriendValues() {
        let friend = Friend(name: "Test", username: "@test")
        #expect(friend.name == "Test")
        #expect(friend.username == "@test")
        #expect(friend.level == 1)
        #expect(friend.currentStreak == 0)
        #expect(friend.totalCompletions == 0)
    }

    @Test func friendAvatarTypeDefault() {
        let friend = Friend(name: "Test", username: "@test")
        #expect(friend.avatarType == .initial)
    }

    @Test func friendAvatarTypeSetter() {
        let friend = Friend(name: "Test", username: "@test")
        friend.avatarType = .animal(.fox)
        #expect(friend.avatarTypeRaw == "animal.fox")
        #expect(friend.avatarType == .animal(.fox))
    }
}
