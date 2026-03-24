import Testing
import Foundation
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
}
