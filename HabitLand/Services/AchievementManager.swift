import Foundation
import SwiftData

/// Checks user progress and unlocks achievements accordingly.
/// Returns an array of newly unlocked achievements for celebration UI.
struct AchievementManager {

    @discardableResult
    static func checkAll(context: ModelContext) -> [Achievement] {
        let achievements = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
        let habits = (try? context.fetch(FetchDescriptor<Habit>())) ?? []
        let sleepLogs = (try? context.fetch(FetchDescriptor<SleepLog>())) ?? []
        let friends = (try? context.fetch(FetchDescriptor<Friend>())) ?? []
        let challenges = (try? context.fetch(FetchDescriptor<Challenge>())) ?? []

        let calendar = Calendar.current
        let totalCompletions = habits.reduce(0) { $0 + $1.totalCompletions }
        let bestStreak = habits.map(\.bestStreak).max() ?? 0

        var newlyUnlocked: [Achievement] = []

        for achievement in achievements where !achievement.isUnlocked {
            var shouldUnlock = false

            switch achievement.name {

            // MARK: - Completion Achievements

            case "Habit Creator":
                // Create your first habit
                if !habits.isEmpty {
                    shouldUnlock = true
                } else {
                    achievement.progress = 0
                    achievement.targetValue = 1
                }

            case "First Step":
                // Complete your first habit
                if totalCompletions >= 1 {
                    shouldUnlock = true
                } else {
                    achievement.progress = min(Double(totalCompletions), 1.0)
                    achievement.targetValue = 1
                }

            case "Century":
                // Complete 100 habits
                if totalCompletions >= 100 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(totalCompletions) / 100.0
                    achievement.targetValue = 100
                }

            // MARK: - Streak Achievements

            case "On Fire":
                if bestStreak >= 7 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(bestStreak) / 7.0
                    achievement.targetValue = 7
                }

            case "Unstoppable":
                if bestStreak >= 30 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(bestStreak) / 30.0
                    achievement.targetValue = 30
                }

            // MARK: - Social Achievements

            case "Social Butterfly":
                let friendCount = friends.count
                if friendCount >= 5 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(friendCount) / 5.0
                    achievement.targetValue = 5
                }

            case "Team Player":
                let completedChallenges = challenges.filter { !$0.isActive && $0.progress >= 1.0 }
                if !completedChallenges.isEmpty {
                    shouldUnlock = true
                } else {
                    let bestProgress = challenges.map(\.progress).max() ?? 0
                    achievement.progress = bestProgress
                    achievement.targetValue = 1
                }

            // MARK: - Sleep Achievements

            case "Dream Catcher":
                let uniqueSleepDays = Set(sleepLogs.map { calendar.startOfDay(for: $0.bedTime) }).count
                if uniqueSleepDays >= 7 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(uniqueSleepDays) / 7.0
                    achievement.targetValue = 7
                }

            case "Night Owl":
                let midnightLogs = sleepLogs.filter {
                    let hour = calendar.component(.hour, from: $0.bedTime)
                    return hour >= 23 || hour < 4
                }.count
                if midnightLogs >= 5 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(midnightLogs) / 5.0
                    achievement.targetValue = 5
                }

            // MARK: - Special Achievements

            case "Perfect Week":
                if hasPerfectWeek(habits: habits, calendar: calendar) {
                    shouldUnlock = true
                } else {
                    let today = calendar.startOfDay(for: Date())
                    var perfectDays = 0
                    for offset in 0..<7 {
                        let day = calendar.date(byAdding: .day, value: -offset, to: today)!
                        let dayStart = calendar.startOfDay(for: day)
                        let activeHabits = habits.filter { !$0.isArchived && $0.targetDays.contains(calendar.component(.weekday, from: day) - 1) && $0.createdAt <= day }
                        guard !activeHabits.isEmpty else { continue }
                        let allDone = activeHabits.allSatisfy { h in h.safeCompletions.contains { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted } }
                        if allDone { perfectDays += 1 }
                    }
                    achievement.progress = Double(perfectDays) / 7.0
                    achievement.targetValue = 7
                }

            case "Early Bird":
                let earlyCompletions = habits.flatMap(\.safeCompletions).filter { c in
                    c.isCompleted && calendar.component(.hour, from: c.date) < 7
                }
                if !earlyCompletions.isEmpty {
                    shouldUnlock = true
                } else {
                    achievement.progress = 0
                    achievement.targetValue = 1
                }

            default:
                break
            }

            if shouldUnlock {
                unlock(achievement)
                newlyUnlocked.append(achievement)
            }
        }

        try? context.save()
        return newlyUnlocked
    }

    private static func unlock(_ achievement: Achievement) {
        achievement.isUnlocked = true
        achievement.unlockedAt = Date()
        achievement.progress = 1.0
    }

    private static func hasPerfectWeek(habits: [Habit], calendar: Calendar) -> Bool {
        let today = calendar.startOfDay(for: Date())
        for startOffset in 0..<84 {
            let weekStart = calendar.date(byAdding: .day, value: -(startOffset + 6), to: today)!
            var allPerfect = true
            var hasData = false
            for dayOffset in 0..<7 {
                let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
                let dayStart = calendar.startOfDay(for: day)
                let activeHabits = habits.filter { !$0.isArchived && $0.targetDays.contains(calendar.component(.weekday, from: day) - 1) && $0.createdAt <= day }
                guard !activeHabits.isEmpty else { continue }
                hasData = true
                let allDone = activeHabits.allSatisfy { h in
                    h.safeCompletions.contains { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted }
                }
                if !allDone {
                    allPerfect = false
                    break
                }
            }
            if allPerfect && hasData { return true }
        }
        return false
    }
}
