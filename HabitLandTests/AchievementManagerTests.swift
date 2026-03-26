import Testing
import Foundation
import SwiftData
@testable import HabitLand

// MARK: - AchievementManager Tests

struct AchievementManagerTests {

    // MARK: - Helpers

    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Habit.self, HabitCompletion.self, SleepLog.self,
                 UserProfile.self, Achievement.self, Friend.self, Challenge.self,
            configurations: config
        )
        return ModelContext(container)
    }

    private func seedAchievement(_ name: String, context: ModelContext) -> Achievement {
        let match = SampleData.achievements.first { $0.name == name }
        let a = Achievement(
            name: name,
            descriptionText: match?.description ?? "",
            icon: match?.icon ?? "star.fill",
            category: match?.category ?? .special
        )
        context.insert(a)
        return a
    }

    private func addCompletions(to habit: Habit, count: Int, startingDaysAgo: Int = 0, context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        for i in 0..<count {
            let date = calendar.date(byAdding: .day, value: -(startingDaysAgo + i), to: today)!
            let c = HabitCompletion(date: date)
            c.habit = habit
            habit.completions = (habit.completions ?? []) + [c]
            context.insert(c)
        }
    }

    // MARK: - Completion Achievements

    @Test func habitCreatorUnlocksWhenHabitExists() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Habit Creator", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Habit Creator" })
    }

    @Test func habitCreatorStaysLockedWhenNoHabits() throws {
        let ctx = try makeContext()
        let a = seedAchievement("Habit Creator", context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.isEmpty)
        #expect(a.isUnlocked == false)
        #expect(a.progress == 0)
        #expect(a.targetValue == 1)
    }

    @Test func firstStepUnlocksOnFirstCompletion() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("First Step", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 1, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "First Step" })
    }

    @Test func firstStepShowsProgressWhenNoCompletions() throws {
        let ctx = try makeContext()
        let a = seedAchievement("First Step", context: ctx)
        try ctx.save()

        let _ = AchievementManager.checkAll(context: ctx)
        #expect(a.isUnlocked == false)
        #expect(a.targetValue == 1)
    }

    @Test func centuryUnlocksAt100Completions() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Century", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 100, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Century" })
    }

    @Test func centuryProgressAt50() throws {
        let ctx = try makeContext()
        let a = seedAchievement("Century", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 50, context: ctx)
        try ctx.save()

        let _ = AchievementManager.checkAll(context: ctx)
        #expect(a.isUnlocked == false)
        #expect(abs(a.progress - 0.5) < 0.01)
        #expect(a.targetValue == 100)
    }

    @Test func dedicatedUnlocksAt250() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Dedicated", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 250, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Dedicated" })
    }

    @Test func marathonerUnlocksAt500() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Marathoner", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 500, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Marathoner" })
    }

    @Test func legendaryUnlocksAt1000() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Legendary", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 1000, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Legendary" })
    }

    // MARK: - Streak Achievements

    @Test func onFireUnlocksAt7DayStreak() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("On Fire", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 7, startingDaysAgo: 0, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "On Fire" })
    }

    @Test func onFireProgressAt3Days() throws {
        let ctx = try makeContext()
        let a = seedAchievement("On Fire", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 3, startingDaysAgo: 0, context: ctx)
        try ctx.save()

        let _ = AchievementManager.checkAll(context: ctx)
        #expect(a.isUnlocked == false)
        #expect(a.targetValue == 7)
    }

    @Test func committedUnlocksAt14DayStreak() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Committed", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 14, startingDaysAgo: 0, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Committed" })
    }

    @Test func unstoppableUnlocksAt30DayStreak() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Unstoppable", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 30, startingDaysAgo: 0, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Unstoppable" })
    }

    @Test func ironWillUnlocksAt60DayStreak() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Iron Will", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 60, startingDaysAgo: 0, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Iron Will" })
    }

    @Test func titaniumUnlocksAt90DayStreak() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Titanium", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 90, startingDaysAgo: 0, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Titanium" })
    }

    @Test func diamondStreakUnlocksAt180DayStreak() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Diamond Streak", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 180, startingDaysAgo: 0, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Diamond Streak" })
    }

    @Test func eternalUnlocksAt365DayStreak() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Eternal", context: ctx)
        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 365, startingDaysAgo: 0, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Eternal" })
    }

    // MARK: - Social Achievements (deferred to v1.1)

    @Test func teamPlayerUnlocksWithCompletedChallenge() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Team Player", context: ctx)
        let challenge = Challenge(name: "Test Challenge", descriptionText: "Test")
        challenge.isActive = false
        challenge.progress = 1.0
        ctx.insert(challenge)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Team Player" })
    }

    @Test func challengerUnlocksWith3Challenges() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Challenger", context: ctx)
        for i in 0..<3 {
            let c = Challenge(name: "Challenge \(i)", descriptionText: "Test")
            ctx.insert(c)
        }
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Challenger" })
    }

    // MARK: - Sleep Achievements

    @Test func dreamCatcherUnlocksWith7SleepDays() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Dream Catcher", context: ctx)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        for i in 0..<7 {
            let bedTime = calendar.date(byAdding: .day, value: -i, to: today)!
            let wakeTime = calendar.date(byAdding: .hour, value: 8, to: bedTime)!
            let log = SleepLog(bedTime: bedTime, wakeTime: wakeTime, quality: .good)
            ctx.insert(log)
        }
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Dream Catcher" })
    }

    @Test func nightOwlUnlocksWith5LateNightLogs() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Night Owl", context: ctx)
        let calendar = Calendar.current
        for i in 0..<5 {
            // Create bedtime at 23:30 on different days
            var comps = calendar.dateComponents([.year, .month, .day], from: Date())
            comps.day! -= i
            comps.hour = 23
            comps.minute = 30
            let bedTime = calendar.date(from: comps)!
            let wakeTime = calendar.date(byAdding: .hour, value: 7, to: bedTime)!
            let log = SleepLog(bedTime: bedTime, wakeTime: wakeTime, quality: .good)
            ctx.insert(log)
        }
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Night Owl" })
    }

    @Test func sleepMasterUnlocksWith30SleepDays() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Sleep Master", context: ctx)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        for i in 0..<30 {
            let bedTime = calendar.date(byAdding: .day, value: -i, to: today)!
            let wakeTime = calendar.date(byAdding: .hour, value: 8, to: bedTime)!
            let log = SleepLog(bedTime: bedTime, wakeTime: wakeTime, quality: .good)
            ctx.insert(log)
        }
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Sleep Master" })
    }

    @Test func consistentSleeperUnlocksWith7ConsecutiveDays7PlusHours() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Consistent Sleeper", context: ctx)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        for i in 0..<7 {
            let bedTime = calendar.date(byAdding: .day, value: -i, to: today)!
            let wakeTime = calendar.date(byAdding: .hour, value: 8, to: bedTime)! // 8h > 7h
            let log = SleepLog(bedTime: bedTime, wakeTime: wakeTime, quality: .good)
            ctx.insert(log)
        }
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Consistent Sleeper" })
    }

    @Test func consistentSleeperFailsWithShortSleep() throws {
        let ctx = try makeContext()
        let a = seedAchievement("Consistent Sleeper", context: ctx)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        for i in 0..<7 {
            let bedTime = calendar.date(byAdding: .day, value: -i, to: today)!
            let wakeTime = calendar.date(byAdding: .hour, value: 5, to: bedTime)! // 5h < 7h
            let log = SleepLog(bedTime: bedTime, wakeTime: wakeTime, quality: .poor)
            ctx.insert(log)
        }
        try ctx.save()

        let _ = AchievementManager.checkAll(context: ctx)
        #expect(a.isUnlocked == false)
    }

    // MARK: - Special Achievements

    @Test func earlyBirdUnlocksWithCompletionBefore7AM() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Early Bird", context: ctx)
        let habit = Habit(name: "Morning Run")
        ctx.insert(habit)

        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 6
        comps.minute = 30
        let earlyDate = calendar.date(from: comps)!
        let c = HabitCompletion(date: earlyDate)
        c.habit = habit
        habit.completions = [c]
        ctx.insert(c)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Early Bird" })
    }

    @Test func wellRoundedUnlocksWith5Categories() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Well Rounded", context: ctx)
        let categories: [HabitCategory] = [.health, .fitness, .mindfulness, .productivity, .sleep]
        for cat in categories {
            let habit = Habit(name: "\(cat.rawValue) Habit", category: cat)
            ctx.insert(habit)
        }
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.contains { $0.name == "Well Rounded" })
    }

    @Test func wellRoundedProgressWith3Categories() throws {
        let ctx = try makeContext()
        let a = seedAchievement("Well Rounded", context: ctx)
        let categories: [HabitCategory] = [.health, .fitness, .mindfulness]
        for cat in categories {
            let habit = Habit(name: "\(cat.rawValue) Habit", category: cat)
            ctx.insert(habit)
        }
        try ctx.save()

        let _ = AchievementManager.checkAll(context: ctx)
        #expect(a.isUnlocked == false)
        #expect(abs(a.progress - 0.6) < 0.01)
        #expect(a.targetValue == 5)
    }

    // MARK: - Already Unlocked Skipped

    @Test func alreadyUnlockedAchievementsAreSkipped() throws {
        let ctx = try makeContext()
        let a = seedAchievement("Habit Creator", context: ctx)
        a.isUnlocked = true
        a.unlockedAt = Date()
        a.progress = 1.0

        let habit = Habit(name: "Test")
        ctx.insert(habit)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.isEmpty) // Already unlocked, not returned again
    }

    // MARK: - Multiple Achievements at Once

    @Test func multipleAchievementsCanUnlockSimultaneously() throws {
        let ctx = try makeContext()
        let _ = seedAchievement("Habit Creator", context: ctx)
        let _ = seedAchievement("First Step", context: ctx)

        let habit = Habit(name: "Test")
        ctx.insert(habit)
        addCompletions(to: habit, count: 1, context: ctx)
        try ctx.save()

        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.count == 2)
        #expect(unlocked.contains { $0.name == "Habit Creator" })
        #expect(unlocked.contains { $0.name == "First Step" })
    }

    // MARK: - Empty Context

    @Test func checkAllWithEmptyContextReturnsEmpty() throws {
        let ctx = try makeContext()
        let unlocked = AchievementManager.checkAll(context: ctx)
        #expect(unlocked.isEmpty)
    }
}
