import Testing
import Foundation
@testable import HabitLand

// MARK: - Habit Model Tests

struct HabitTests {
    @Test func newHabitHasDefaultValues() {
        let habit = Habit(name: "Test Habit")
        #expect(habit.name == "Test Habit")
        #expect(habit.icon == "checkmark.circle")
        #expect(habit.colorHex == "#34C759")
        #expect(habit.category == .health)
        #expect(habit.frequency == .daily)
        #expect(habit.isArchived == false)
        #expect(habit.completions.isEmpty)
        #expect(habit.goalCount == 1)
    }

    @Test func todayCompletedReturnsFalseWhenNoCompletions() {
        let habit = Habit(name: "Exercise")
        #expect(habit.todayCompleted == false)
    }

    @Test func todayCompletedReturnsTrueWhenCompletedToday() {
        let habit = Habit(name: "Exercise")
        let completion = HabitCompletion(date: Date())
        completion.habit = habit
        habit.completions.append(completion)
        #expect(habit.todayCompleted == true)
    }

    @Test func todayCompletedReturnsFalseForYesterdayCompletion() {
        let habit = Habit(name: "Exercise")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let completion = HabitCompletion(date: yesterday)
        completion.habit = habit
        habit.completions.append(completion)
        #expect(habit.todayCompleted == false)
    }

    @Test func todayProgressCalculation() {
        let habit = Habit(name: "Drink Water", goalCount: 3)
        #expect(habit.todayProgress == 0.0)

        let c1 = HabitCompletion(date: Date())
        c1.habit = habit
        habit.completions.append(c1)
        // 1 of 3
        #expect(abs(habit.todayProgress - (1.0/3.0)) < 0.01)
    }

    @Test func totalCompletionsCount() {
        let habit = Habit(name: "Read")
        let c1 = HabitCompletion(date: Date())
        c1.habit = habit
        habit.completions.append(c1)

        let c2 = HabitCompletion(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        c2.habit = habit
        habit.completions.append(c2)

        #expect(habit.totalCompletions == 2)
    }

    @Test func currentStreakCalculation() {
        let habit = Habit(name: "Meditate")
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Add completions for today and 2 days prior (consecutive)
        for dayOffset in 0...2 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let c = HabitCompletion(date: date)
            c.habit = habit
            habit.completions.append(c)
        }

        #expect(habit.currentStreak == 3)
    }

    @Test func currentStreakBreaksOnGap() {
        let habit = Habit(name: "Meditate")
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Today
        let c1 = HabitCompletion(date: today)
        c1.habit = habit
        habit.completions.append(c1)

        // 2 days ago (gap yesterday)
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let c2 = HabitCompletion(date: twoDaysAgo)
        c2.habit = habit
        habit.completions.append(c2)

        #expect(habit.currentStreak == 1)
    }

    @Test func bestStreakCalculation() {
        let habit = Habit(name: "Exercise")
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 5-day streak 10 days ago
        for i in 10...14 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let c = HabitCompletion(date: date)
            c.habit = habit
            habit.completions.append(c)
        }

        // 2-day current streak
        for i in 0...1 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let c = HabitCompletion(date: date)
            c.habit = habit
            habit.completions.append(c)
        }

        #expect(habit.bestStreak >= 5)
    }

    @Test func weekCompletionRate() {
        let habit = Habit(name: "Read")
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Complete 3 of the last 7 days
        for i in [0, 2, 4] {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let c = HabitCompletion(date: date)
            c.habit = habit
            habit.completions.append(c)
        }

        #expect(abs(habit.weekCompletionRate - (3.0/7.0)) < 0.01)
    }

    @Test func colorFromHex() {
        let habit = Habit(name: "Test", colorHex: "#34C759")
        // Just verify it doesn't crash and returns a color
        let _ = habit.color
    }
}

// MARK: - UserProfile Tests

struct UserProfileTests {
    @Test func defaultProfileValues() {
        let profile = UserProfile(name: "Test", username: "@test", avatarEmoji: "🌱")
        #expect(profile.name == "Test")
        #expect(profile.username == "@test")
        #expect(profile.level == 1)
        #expect(profile.xp == 0)
    }

    @Test func levelProgressCalculation() {
        let profile = UserProfile(name: "Test", username: "@test", avatarEmoji: "🌱")
        profile.xp = 50
        // levelProgress should be between 0 and 1
        #expect(profile.levelProgress >= 0)
        #expect(profile.levelProgress <= 1)
    }

    @Test func xpForNextLevelPositive() {
        let profile = UserProfile(name: "Test", username: "@test", avatarEmoji: "🌱")
        #expect(profile.xpForNextLevel > 0)
    }

    @Test func levelTitleNotEmpty() {
        let profile = UserProfile(name: "Test", username: "@test", avatarEmoji: "🌱")
        #expect(!profile.levelTitle.isEmpty)
    }
}

// MARK: - HabitCompletion Tests

struct HabitCompletionTests {
    @Test func defaultCompletionIsCompleted() {
        let completion = HabitCompletion(date: Date())
        #expect(completion.isCompleted == true)
        #expect(completion.count == 1)
    }
}

// MARK: - SleepLog Tests

struct SleepLogTests {
    @Test func durationHoursCalculation() {
        let bedtime = Calendar.current.date(from: DateComponents(hour: 23, minute: 0))!
        let wakeup = Calendar.current.date(byAdding: .hour, value: 8, to: bedtime)!
        let log = SleepLog(bedTime: bedtime, wakeTime: wakeup, quality: .good)
        #expect(abs(log.durationHours - 8.0) < 0.01)
    }
}

// MARK: - Achievement Tests

struct AchievementTests {
    @Test func newAchievementIsLocked() {
        let achievement = Achievement(
            name: "First Step",
            descriptionText: "Complete your first habit",
            icon: "star.fill",
            category: .completion
        )
        #expect(achievement.isUnlocked == false)
        #expect(achievement.progress == 0)
    }

    @Test func achievementUnlock() {
        let achievement = Achievement(
            name: "On Fire",
            descriptionText: "7-day streak",
            icon: "flame.fill",
            category: .streak
        )
        achievement.isUnlocked = true
        achievement.progress = 100
        achievement.unlockedAt = Date()
        #expect(achievement.isUnlocked == true)
        #expect(achievement.progress == 100)
    }
}

// MARK: - XP & Level System Tests

struct XPLevelTests {
    @Test func xpForNextLevelScalesWithLevel() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.level = 1
        #expect(profile.xpForNextLevel == 100)
        profile.level = 5
        #expect(profile.xpForNextLevel == 500)
        profile.level = 10
        #expect(profile.xpForNextLevel == 1000)
    }

    @Test func levelProgressIsCorrect() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.level = 1
        profile.xp = 50
        #expect(abs(profile.levelProgress - 0.5) < 0.01)
    }

    @Test func levelProgressAtZero() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.level = 1
        profile.xp = 0
        #expect(profile.levelProgress == 0)
    }

    @Test func xpGainLevelUp() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.level = 1
        profile.xp = 90
        // Simulate gainXP(10) — should level up
        profile.xp += 10
        if profile.xp >= profile.xpForNextLevel {
            profile.xp -= profile.xpForNextLevel
            profile.level += 1
        }
        #expect(profile.level == 2)
        #expect(profile.xp == 0)
    }

    @Test func xpGainMultipleLevelUps() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.level = 1
        profile.xp = 90
        // Simulate gaining a large amount of XP
        profile.xp += 210 // 90 + 210 = 300, should cross level 1 (100) and level 2 (200)
        while profile.xp >= profile.xpForNextLevel {
            profile.xp -= profile.xpForNextLevel
            profile.level += 1
        }
        #expect(profile.level == 3)
        #expect(profile.xp == 0)
    }

    @Test func xpRemoveBasic() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.level = 1
        profile.xp = 50
        // Simulate removeXP(10)
        profile.xp -= 10
        profile.xp = max(0, profile.xp)
        #expect(profile.xp == 40)
        #expect(profile.level == 1)
    }

    @Test func xpRemoveClampsAtZero() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.level = 1
        profile.xp = 5
        profile.xp -= 10
        while profile.xp < 0 && profile.level > 1 {
            profile.level -= 1
            profile.xp += profile.xpForNextLevel
        }
        profile.xp = max(0, profile.xp)
        #expect(profile.xp == 0)
        #expect(profile.level == 1)
    }

    @Test func xpRemoveLevelDown() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.level = 2
        profile.xp = 5
        // Remove 10 XP — should go back to level 1
        profile.xp -= 10
        while profile.xp < 0 && profile.level > 1 {
            profile.level -= 1
            profile.xp += profile.xpForNextLevel
        }
        profile.xp = max(0, profile.xp)
        #expect(profile.level == 1)
        #expect(profile.xp == 95) // was -5, + 100 (level 1 xpForNext) = 95
    }

    @Test func levelTitlesAreCorrect() {
        let profile = UserProfile(name: "Test", username: "@test")
        profile.level = 1
        #expect(profile.levelTitle == "Seedling")
        profile.level = 6
        #expect(profile.levelTitle == "Sprout")
        profile.level = 11
        #expect(profile.levelTitle == "Sapling")
        profile.level = 21
        #expect(profile.levelTitle == "Tree")
        profile.level = 36
        #expect(profile.levelTitle == "Forest")
        profile.level = 51
        #expect(profile.levelTitle == "Legend")
    }
}

// MARK: - SleepQuality Tests

struct SleepQualityTests {
    @Test func allQualitiesHaveEmoji() {
        for quality in SleepQuality.allCases {
            #expect(!quality.icon.isEmpty)
        }
    }

    @Test func qualityValuesAreOrdered() {
        let values = SleepQuality.allCases.map(\.value)
        for i in 1..<values.count {
            #expect(values[i] > values[i - 1])
        }
    }
}

// MARK: - Notification Type Tests

struct NotificationTypeTests {
    @Test func allTypesHaveRawValues() {
        for type in NotificationType.allCases {
            #expect(!type.rawValue.isEmpty)
        }
    }
}

// MARK: - HabitFrequency Tests

struct HabitFrequencyTests {
    @Test func allFrequenciesExist() {
        #expect(HabitFrequency.allCases.count == 4)
    }
}

// MARK: - Sample Data Tests

struct SampleDataTests {
    @Test func sampleHabitsExist() {
        #expect(SampleData.habits.count == 10)
    }

    @Test func sampleAchievementsExist() {
        #expect(SampleData.achievements.count == 11)
    }

    @Test func allSampleHabitsHaveValidCategory() {
        for (_, data) in SampleData.habits {
            #expect(!data.icon.isEmpty)
            #expect(data.color.hasPrefix("#"))
        }
    }

    @Test func allSampleAchievementsHaveIcons() {
        for a in SampleData.achievements {
            #expect(!a.icon.isEmpty)
            #expect(!a.name.isEmpty)
            #expect(!a.description.isEmpty)
        }
    }
}

// MARK: - HabitCategory Tests

struct HabitCategoryTests {
    @Test func allCategoriesHaveIcons() {
        for category in HabitCategory.allCases {
            #expect(!category.icon.isEmpty)
        }
    }

    @Test func allCategoriesHaveColorHex() {
        for category in HabitCategory.allCases {
            #expect(category.colorHex.hasPrefix("#"))
        }
    }
}
