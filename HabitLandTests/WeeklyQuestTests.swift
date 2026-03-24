import Testing
import Foundation
import SwiftData
@testable import HabitLand

// MARK: - WeeklyQuest Model Tests

struct WeeklyQuestModelTests {

    @Test func progressFractionCalculation() {
        var quest = WeeklyQuest(
            id: "test",
            title: "Test Quest",
            description: "Test",
            icon: "star.fill",
            target: 10,
            progress: 5,
            xpReward: 50,
            type: .totalCompletions,
            isCompleted: false
        )
        #expect(abs(quest.progressFraction - 0.5) < 0.01)

        quest.progress = 10
        #expect(abs(quest.progressFraction - 1.0) < 0.01)

        quest.progress = 15 // over target
        #expect(abs(quest.progressFraction - 1.0) < 0.01) // capped at 1.0
    }

    @Test func progressFractionWithZeroTarget() {
        let quest = WeeklyQuest(
            id: "test",
            title: "Test",
            description: "Test",
            icon: "star.fill",
            target: 0,
            progress: 5,
            xpReward: 50,
            type: .totalCompletions,
            isCompleted: false
        )
        #expect(quest.progressFraction == 0)
    }

    @Test func questTypeRawValues() {
        #expect(WeeklyQuest.QuestType.totalCompletions.rawValue == "totalCompletions")
        #expect(WeeklyQuest.QuestType.perfectDays.rawValue == "perfectDays")
        #expect(WeeklyQuest.QuestType.sleepLogs.rawValue == "sleepLogs")
        #expect(WeeklyQuest.QuestType.categoryVariety.rawValue == "categoryVariety")
        #expect(WeeklyQuest.QuestType.streakMaintain.rawValue == "streakMaintain")
    }

    @Test func questIsCodable() throws {
        let quest = WeeklyQuest(
            id: "test-123",
            title: "Habit Machine",
            description: "Complete 15 habits",
            icon: "checkmark.circle.fill",
            target: 15,
            progress: 7,
            xpReward: 50,
            type: .totalCompletions,
            isCompleted: false
        )

        let data = try JSONEncoder().encode(quest)
        let decoded = try JSONDecoder().decode(WeeklyQuest.self, from: data)

        #expect(decoded.id == quest.id)
        #expect(decoded.title == quest.title)
        #expect(decoded.target == quest.target)
        #expect(decoded.progress == quest.progress)
        #expect(decoded.xpReward == quest.xpReward)
        #expect(decoded.type == quest.type)
        #expect(decoded.isCompleted == quest.isCompleted)
    }

    @Test func questIdentifiable() {
        let quest = WeeklyQuest(
            id: "unique-id",
            title: "Test",
            description: "Test",
            icon: "star.fill",
            target: 5,
            progress: 0,
            xpReward: 50,
            type: .perfectDays,
            isCompleted: false
        )
        #expect(quest.id == "unique-id")
    }
}

// MARK: - WeeklyQuestManager Tests

@Suite(.serialized)
struct WeeklyQuestManagerTests {

    private let questsKey = "weeklyQuests"
    private let weekKey = "weeklyQuestsWeek"

    private func clearKeys() {
        UserDefaults.standard.removeObject(forKey: questsKey)
        UserDefaults.standard.removeObject(forKey: weekKey)
    }

    @Test @MainActor func loadOrGenerateCreatesQuests() {
        clearKeys()
        let manager = WeeklyQuestManager.shared
        manager.loadOrGenerate()

        #expect(!manager.quests.isEmpty)
        #expect(manager.quests.count == 3)

        clearKeys()
    }

    @Test @MainActor func generatedQuestsHave3Items() {
        clearKeys()
        let manager = WeeklyQuestManager.shared
        manager.loadOrGenerate()

        #expect(manager.quests.count == 3)
        for quest in manager.quests {
            #expect(!quest.title.isEmpty)
            #expect(!quest.description.isEmpty)
            #expect(!quest.icon.isEmpty)
            #expect(quest.target > 0)
            #expect(quest.xpReward > 0)
            #expect(quest.progress == 0)
            #expect(quest.isCompleted == false)
        }

        clearKeys()
    }

    @Test @MainActor func generatedQuestsPreferUniqueTypes() {
        clearKeys()
        let manager = WeeklyQuestManager.shared
        manager.loadOrGenerate()

        let types = Set(manager.quests.map(\.type))
        // Should try to have unique types (3 different types)
        #expect(types.count >= 2) // At minimum 2, ideally 3

        clearKeys()
    }

    @Test @MainActor func questsPersistToUserDefaults() {
        clearKeys()
        let manager = WeeklyQuestManager.shared
        manager.loadOrGenerate()

        let savedData = UserDefaults.standard.data(forKey: questsKey)
        #expect(savedData != nil)

        let savedWeek = UserDefaults.standard.string(forKey: weekKey)
        #expect(savedWeek != nil)
        #expect(savedWeek!.contains("-W"))

        clearKeys()
    }

    @Test @MainActor func loadOrGeneratePreservesExistingQuestsForSameWeek() {
        clearKeys()
        let manager = WeeklyQuestManager.shared
        manager.loadOrGenerate()

        let firstTitles = manager.quests.map(\.title)

        // Load again in the same week
        manager.loadOrGenerate()

        let secondTitles = manager.quests.map(\.title)
        #expect(firstTitles == secondTitles) // Should be identical

        clearKeys()
    }

    @Test @MainActor func questCompletionDetection() {
        var quest = WeeklyQuest(
            id: "test",
            title: "Test",
            description: "Test",
            icon: "star.fill",
            target: 5,
            progress: 4,
            xpReward: 50,
            type: .totalCompletions,
            isCompleted: false
        )

        // Not yet completed
        #expect(quest.isCompleted == false)

        // Simulate progress update
        quest.progress = 5
        if quest.progress >= quest.target {
            quest.isCompleted = true
        }
        #expect(quest.isCompleted == true)
    }

    // MARK: - updateProgress Tests

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Habit.self, HabitCompletion.self, SleepLog.self,
                 UserProfile.self, Achievement.self, Friend.self,
                 Challenge.self, AppNotification.self,
            configurations: config
        )
        return ModelContext(container)
    }

    private func weekStart() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }

    @Test @MainActor func updateProgressCountsTotalCompletions() throws {
        clearKeys()
        let context = try makeContext()
        let manager = WeeklyQuestManager.shared

        // Set up quests with a known totalCompletions quest
        manager.quests = [
            WeeklyQuest(id: "tc", title: "Test", description: "Test", icon: "star.fill",
                        target: 3, progress: 0, xpReward: 50, type: .totalCompletions, isCompleted: false)
        ]

        // Create a habit with completions this week
        let habit = Habit(name: "Exercise")
        context.insert(habit)
        let ws = weekStart()
        for i in 0..<3 {
            let completion = HabitCompletion(date: ws.addingTimeInterval(Double(i) * 86400), isCompleted: true)
            completion.habit = habit
            context.insert(completion)
        }
        try context.save()

        manager.updateProgress(context: context)

        #expect(manager.quests[0].progress == 3)
        #expect(manager.quests[0].isCompleted == true)
        clearKeys()
    }

    @Test @MainActor func updateProgressCountsSleepLogs() throws {
        clearKeys()
        let context = try makeContext()
        let manager = WeeklyQuestManager.shared

        manager.quests = [
            WeeklyQuest(id: "sl", title: "Sleep", description: "Test", icon: "moon.fill",
                        target: 3, progress: 0, xpReward: 40, type: .sleepLogs, isCompleted: false)
        ]

        let ws = weekStart()
        for i in 0..<3 {
            let log = SleepLog(bedTime: ws.addingTimeInterval(Double(i) * 86400 + 3600 * 22),
                               wakeTime: ws.addingTimeInterval(Double(i) * 86400 + 3600 * 30))
            context.insert(log)
        }
        try context.save()

        manager.updateProgress(context: context)

        #expect(manager.quests[0].progress >= 3)
        #expect(manager.quests[0].isCompleted == true)
        clearKeys()
    }

    @Test @MainActor func updateProgressSkipsAlreadyCompletedQuests() throws {
        clearKeys()
        let context = try makeContext()
        let manager = WeeklyQuestManager.shared

        manager.quests = [
            WeeklyQuest(id: "done", title: "Done", description: "Test", icon: "star.fill",
                        target: 5, progress: 5, xpReward: 50, type: .totalCompletions, isCompleted: true)
        ]

        manager.updateProgress(context: context)

        // Progress should remain unchanged since quest is already completed
        #expect(manager.quests[0].progress == 5)
        #expect(manager.quests[0].isCompleted == true)
        clearKeys()
    }

    @Test @MainActor func updateProgressMarksCompletionWhenTargetReached() throws {
        clearKeys()
        let context = try makeContext()
        let manager = WeeklyQuestManager.shared

        manager.quests = [
            WeeklyQuest(id: "sm", title: "Streak", description: "Test", icon: "flame.fill",
                        target: 2, progress: 0, xpReward: 60, type: .streakMaintain, isCompleted: false)
        ]

        // Create a habit with a 3-day streak (today + yesterday + day before)
        let habit = Habit(name: "Read")
        context.insert(habit)
        let calendar = Calendar.current
        for i in 0..<3 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let completion = HabitCompletion(date: date, isCompleted: true)
            completion.habit = habit
            context.insert(completion)
        }
        try context.save()

        manager.updateProgress(context: context)

        #expect(manager.quests[0].progress >= 2)
        #expect(manager.quests[0].isCompleted == true)
        clearKeys()
    }

    // MARK: - claimReward Tests

    @Test @MainActor func claimRewardGrantsXP() throws {
        clearKeys()
        let context = try makeContext()
        let manager = WeeklyQuestManager.shared

        let profile = UserProfile()
        profile.xp = 0
        profile.level = 1
        context.insert(profile)
        try context.save()

        let quest = WeeklyQuest(
            id: "reward", title: "Test", description: "Test", icon: "star.fill",
            target: 5, progress: 5, xpReward: 50, type: .totalCompletions, isCompleted: true
        )

        let xpGained = manager.claimReward(quest: quest, context: context)

        #expect(xpGained == 50)
        #expect(profile.xp == 50)
        clearKeys()
    }

    @Test @MainActor func claimRewardReturnsZeroForIncompleteQuest() throws {
        clearKeys()
        let context = try makeContext()
        let manager = WeeklyQuestManager.shared

        let quest = WeeklyQuest(
            id: "incomplete", title: "Test", description: "Test", icon: "star.fill",
            target: 5, progress: 2, xpReward: 50, type: .totalCompletions, isCompleted: false
        )

        let xpGained = manager.claimReward(quest: quest, context: context)

        #expect(xpGained == 0)
        clearKeys()
    }

    @Test @MainActor func claimRewardTriggersLevelUp() throws {
        clearKeys()
        let context = try makeContext()
        let manager = WeeklyQuestManager.shared

        let profile = UserProfile()
        profile.xp = 80  // level 1 needs 100 XP
        profile.level = 1
        context.insert(profile)
        try context.save()

        let quest = WeeklyQuest(
            id: "lvlup", title: "Test", description: "Test", icon: "star.fill",
            target: 5, progress: 5, xpReward: 50, type: .totalCompletions, isCompleted: true
        )

        let xpGained = manager.claimReward(quest: quest, context: context)

        #expect(xpGained == 50)
        #expect(profile.level == 2)
        // 80 + 50 = 130, level 1 needs 100, so after level up: 130 - 100 = 30
        #expect(profile.xp == 30)
        clearKeys()
    }

    // MARK: - Quest Limit (Always 3)

    @Test @MainActor func questGenerationAlwaysProduces3Quests() {
        clearKeys()
        let manager = WeeklyQuestManager.shared

        // Run multiple times to account for randomness
        for _ in 0..<5 {
            clearKeys()
            manager.loadOrGenerate()
            #expect(manager.quests.count == 3)
        }
        clearKeys()
    }

    @Test @MainActor func questsAlwaysStartWithZeroProgress() {
        clearKeys()
        let manager = WeeklyQuestManager.shared
        manager.loadOrGenerate()

        for quest in manager.quests {
            #expect(quest.progress == 0)
            #expect(quest.isCompleted == false)
        }
        clearKeys()
    }

    @Test @MainActor func updateProgressWithCategoryVariety() throws {
        clearKeys()
        let context = try makeContext()
        let manager = WeeklyQuestManager.shared

        manager.quests = [
            WeeklyQuest(id: "cv", title: "Explorer", description: "Test", icon: "circle.grid.3x3.fill",
                        target: 3, progress: 0, xpReward: 50, type: .categoryVariety, isCompleted: false)
        ]

        let ws = weekStart()

        // Create habits in different categories with completions
        let categories: [(String, HabitCategory)] = [
            ("Run", .fitness), ("Read", .learning), ("Meditate", .mindfulness)
        ]
        for (name, category) in categories {
            let habit = Habit(name: name, category: category)
            context.insert(habit)
            let completion = HabitCompletion(date: ws.addingTimeInterval(3600), isCompleted: true)
            completion.habit = habit
            context.insert(completion)
        }
        try context.save()

        manager.updateProgress(context: context)

        #expect(manager.quests[0].progress == 3)
        #expect(manager.quests[0].isCompleted == true)
        clearKeys()
    }
}
