import Testing
import Foundation
import SwiftData
@testable import HabitLand

// MARK: - SwiftData Persistence Tests

struct SwiftDataPersistenceTests {

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

    // MARK: - Habit CRUD

    @Test func insertAndFetchHabit() throws {
        let ctx = try makeContext()
        let habit = Habit(name: "Exercise", category: .fitness)
        ctx.insert(habit)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Habit>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Exercise")
        #expect(fetched.first?.category == .fitness)
    }

    @Test func updateHabit() throws {
        let ctx = try makeContext()
        let habit = Habit(name: "Original")
        ctx.insert(habit)
        try ctx.save()

        habit.name = "Updated"
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Habit>())
        #expect(fetched.first?.name == "Updated")
    }

    @Test func deleteHabit() throws {
        let ctx = try makeContext()
        let habit = Habit(name: "ToDelete")
        ctx.insert(habit)
        try ctx.save()

        ctx.delete(habit)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Habit>())
        #expect(fetched.isEmpty)
    }

    // MARK: - Cascade Delete

    @Test func deletingHabitCascadesToCompletions() throws {
        let ctx = try makeContext()
        let habit = Habit(name: "Test")
        ctx.insert(habit)

        let c1 = HabitCompletion(date: Date())
        c1.habit = habit
        habit.completions = [c1]
        ctx.insert(c1)
        try ctx.save()

        let completionsBefore = try ctx.fetch(FetchDescriptor<HabitCompletion>())
        #expect(completionsBefore.count == 1)

        ctx.delete(habit)
        try ctx.save()

        let completionsAfter = try ctx.fetch(FetchDescriptor<HabitCompletion>())
        #expect(completionsAfter.isEmpty)
    }

    // MARK: - Habit Completion Relationship

    @Test func completionLinksToHabit() throws {
        let ctx = try makeContext()
        let habit = Habit(name: "Test")
        ctx.insert(habit)

        let completion = HabitCompletion(date: Date())
        completion.habit = habit
        habit.completions = [completion]
        ctx.insert(completion)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<HabitCompletion>())
        #expect(fetched.first?.habit?.name == "Test")
    }

    @Test func multipleCompletionsForOneHabit() throws {
        let ctx = try makeContext()
        let habit = Habit(name: "Test")
        ctx.insert(habit)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        for i in 0..<5 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let c = HabitCompletion(date: date)
            c.habit = habit
            habit.completions = (habit.completions ?? []) + [c]
            ctx.insert(c)
        }
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Habit>())
        #expect(fetched.first?.safeCompletions.count == 5)
    }

    // MARK: - UserProfile CRUD

    @Test func insertAndFetchProfile() throws {
        let ctx = try makeContext()
        let profile = UserProfile(name: "Test User", username: "@testuser")
        ctx.insert(profile)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<UserProfile>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Test User")
        #expect(fetched.first?.level == 1)
        #expect(fetched.first?.xp == 0)
    }

    @Test func updateProfileXPAndLevel() throws {
        let ctx = try makeContext()
        let profile = UserProfile(name: "Test")
        ctx.insert(profile)
        try ctx.save()

        profile.xp = 150
        profile.level = 3
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<UserProfile>())
        #expect(fetched.first?.xp == 150)
        #expect(fetched.first?.level == 3)
    }

    // MARK: - SleepLog CRUD

    @Test func insertAndFetchSleepLog() throws {
        let ctx = try makeContext()
        let bedTime = Date()
        let wakeTime = bedTime.addingTimeInterval(8 * 3600)
        let log = SleepLog(bedTime: bedTime, wakeTime: wakeTime, quality: .excellent)
        ctx.insert(log)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<SleepLog>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.quality == .excellent)
    }

    // MARK: - Achievement CRUD

    @Test func insertAndFetchAchievement() throws {
        let ctx = try makeContext()
        let achievement = Achievement(
            name: "First Step",
            descriptionText: "Complete first habit",
            icon: "star.fill",
            category: .completion
        )
        ctx.insert(achievement)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Achievement>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "First Step")
        #expect(fetched.first?.isUnlocked == false)
    }

    @Test func unlockAchievementPersists() throws {
        let ctx = try makeContext()
        let achievement = Achievement(
            name: "On Fire",
            descriptionText: "7-day streak",
            icon: "flame.fill",
            category: .streak
        )
        ctx.insert(achievement)
        try ctx.save()

        achievement.isUnlocked = true
        achievement.unlockedAt = Date()
        achievement.progress = 1.0
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Achievement>())
        #expect(fetched.first?.isUnlocked == true)
        #expect(fetched.first?.progress == 1.0)
    }

    // MARK: - Friend CRUD

    @Test func insertAndFetchFriend() throws {
        let ctx = try makeContext()
        let friend = Friend(name: "Alice", username: "@alice", level: 5, currentStreak: 10)
        ctx.insert(friend)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Friend>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Alice")
        #expect(fetched.first?.level == 5)
    }

    // MARK: - Challenge CRUD

    @Test func insertAndFetchChallenge() throws {
        let ctx = try makeContext()
        let challenge = Challenge(name: "7-Day Meditation", descriptionText: "Meditate every day")
        ctx.insert(challenge)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Challenge>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "7-Day Meditation")
        #expect(fetched.first?.isActive == true)
    }

    // MARK: - AppNotification CRUD

    @Test func insertAndFetchNotification() throws {
        let ctx = try makeContext()
        let notification = AppNotification(title: "New Achievement!", body: "You unlocked First Step", type: .achievement)
        ctx.insert(notification)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<AppNotification>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.type == .achievement)
        #expect(fetched.first?.isRead == false)
    }

    // MARK: - Multiple Models Together

    @Test func multipleModelsCoexist() throws {
        let ctx = try makeContext()

        let habit = Habit(name: "Test")
        ctx.insert(habit)

        let profile = UserProfile(name: "User")
        ctx.insert(profile)

        let friend = Friend(name: "Friend", username: "@friend")
        ctx.insert(friend)

        let log = SleepLog(bedTime: Date(), wakeTime: Date().addingTimeInterval(3600))
        ctx.insert(log)

        try ctx.save()

        #expect(try ctx.fetch(FetchDescriptor<Habit>()).count == 1)
        #expect(try ctx.fetch(FetchDescriptor<UserProfile>()).count == 1)
        #expect(try ctx.fetch(FetchDescriptor<Friend>()).count == 1)
        #expect(try ctx.fetch(FetchDescriptor<SleepLog>()).count == 1)
    }

    // MARK: - Streak Freeze Dates Persistence

    @Test func streakFreezeDatesPersist() throws {
        let ctx = try makeContext()
        let profile = UserProfile(name: "Test")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        profile.streakFreezeCount = 2
        profile.streakFreezeUsedDates = [Calendar.current.startOfDay(for: yesterday)]
        ctx.insert(profile)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<UserProfile>())
        #expect(fetched.first?.streakFreezeCount == 2)
        #expect(fetched.first?.streakFreezeUsedDates.count == 1)
    }

    // MARK: - Habit Archive

    @Test func archiveHabitPersists() throws {
        let ctx = try makeContext()
        let habit = Habit(name: "Old Habit")
        ctx.insert(habit)
        try ctx.save()

        habit.isArchived = true
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Habit>())
        #expect(fetched.first?.isArchived == true)
    }

    // MARK: - Filtered Fetch

    @Test func fetchOnlyActiveHabits() throws {
        let ctx = try makeContext()

        let active = Habit(name: "Active")
        ctx.insert(active)

        let archived = Habit(name: "Archived")
        archived.isArchived = true
        ctx.insert(archived)

        try ctx.save()

        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate<Habit> { !$0.isArchived })
        let fetched = try ctx.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Active")
    }

    @Test func fetchUnlockedAchievements() throws {
        let ctx = try makeContext()

        let locked = Achievement(name: "Locked", descriptionText: "Test", icon: "star.fill")
        ctx.insert(locked)

        let unlocked = Achievement(name: "Unlocked", descriptionText: "Test", icon: "star.fill")
        unlocked.isUnlocked = true
        ctx.insert(unlocked)

        try ctx.save()

        let descriptor = FetchDescriptor<Achievement>(predicate: #Predicate<Achievement> { $0.isUnlocked })
        let fetched = try ctx.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Unlocked")
    }
}
