import Foundation
import os
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
                if totalCompletions >= 100 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(totalCompletions) / 100.0
                    achievement.targetValue = 100
                }

            case "Dedicated":
                if totalCompletions >= 250 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(totalCompletions) / 250.0
                    achievement.targetValue = 250
                }

            case "Marathoner":
                if totalCompletions >= 500 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(totalCompletions) / 500.0
                    achievement.targetValue = 500
                }

            case "Legendary":
                if totalCompletions >= 1000 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(totalCompletions) / 1000.0
                    achievement.targetValue = 1000
                }

            // MARK: - Streak Achievements

            case "On Fire":
                if bestStreak >= 7 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(bestStreak) / 7.0
                    achievement.targetValue = 7
                }

            case "Committed":
                if bestStreak >= 14 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(bestStreak) / 14.0
                    achievement.targetValue = 14
                }

            case "Unstoppable":
                if bestStreak >= 30 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(bestStreak) / 30.0
                    achievement.targetValue = 30
                }

            case "Iron Will":
                if bestStreak >= 60 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(bestStreak) / 60.0
                    achievement.targetValue = 60
                }

            case "Titanium":
                if bestStreak >= 90 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(bestStreak) / 90.0
                    achievement.targetValue = 90
                }

            case "Diamond Streak":
                if bestStreak >= 180 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(bestStreak) / 180.0
                    achievement.targetValue = 180
                }

            case "Eternal":
                if bestStreak >= 365 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(bestStreak) / 365.0
                    achievement.targetValue = 365
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

            case "Challenger":
                let challengeCount = challenges.count
                if challengeCount >= 3 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(challengeCount) / 3.0
                    achievement.targetValue = 3
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

            case "Sleep Master":
                let uniqueSleepDays = Set(sleepLogs.map { calendar.startOfDay(for: $0.bedTime) }).count
                if uniqueSleepDays >= 30 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(uniqueSleepDays) / 30.0
                    achievement.targetValue = 30
                }

            case "Consistent Sleeper":
                let consistentDays = countConsecutiveSleepDays(sleepLogs: sleepLogs, minHours: 7, calendar: calendar)
                if consistentDays >= 7 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(consistentDays) / 7.0
                    achievement.targetValue = 7
                }

            // MARK: - Special Achievements

            case "Perfect Week":
                if hasPerfectWeek(habits: habits, calendar: calendar) {
                    shouldUnlock = true
                } else {
                    let today = calendar.startOfDay(for: Date())
                    var perfectDays = 0
                    for offset in 0..<7 {
                        let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
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

            case "Speed Runner":
                // Complete all daily habits within 1 hour on any day
                if hasSpeedRun(habits: habits, calendar: calendar) {
                    shouldUnlock = true
                } else {
                    achievement.progress = 0
                    achievement.targetValue = 1
                }

            case "Well Rounded":
                let categories = Set(habits.filter { !$0.isArchived }.map(\.category))
                if categories.count >= 5 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(categories.count) / 5.0
                    achievement.targetValue = 5
                }

            case "Weekend Warrior":
                let weekendWeeks = countPerfectWeekendWeeks(habits: habits, calendar: calendar)
                if weekendWeeks >= 4 {
                    shouldUnlock = true
                } else {
                    achievement.progress = Double(weekendWeeks) / 4.0
                    achievement.targetValue = 4
                }

            default:
                break
            }

            if shouldUnlock {
                unlock(achievement)
                newlyUnlocked.append(achievement)
            }
        }

        do {
            try context.save()
        } catch {
            HLLogger.data.error("Failed to save achievements: \(error.localizedDescription, privacy: .public)")
        }
        return newlyUnlocked
    }

    private static func unlock(_ achievement: Achievement) {
        achievement.isUnlocked = true
        achievement.unlockedAt = Date()
        achievement.progress = 1.0
    }

    private static func hasSpeedRun(habits: [Habit], calendar: Calendar) -> Bool {
        // Check if all active habits were completed within 1 hour on any day
        let activeHabits = habits.filter { !$0.isArchived }
        guard activeHabits.count >= 2 else { return false }

        // Group all completions by day
        var dayCompletions: [Date: [Date]] = [:]
        for habit in activeHabits {
            for c in habit.safeCompletions where c.isCompleted {
                let day = calendar.startOfDay(for: c.date)
                dayCompletions[day, default: []].append(c.date)
            }
        }

        for (day, times) in dayCompletions {
            // Check if all active habits scheduled for this day were completed
            let scheduledHabits = activeHabits.filter { $0.targetDays.contains(calendar.component(.weekday, from: day) - 1) && $0.createdAt <= day }
            guard !scheduledHabits.isEmpty else { continue }

            let completedHabits = scheduledHabits.filter { h in
                h.safeCompletions.contains { calendar.startOfDay(for: $0.date) == day && $0.isCompleted }
            }
            guard completedHabits.count == scheduledHabits.count else { continue }

            // Check if all completions happened within 1 hour
            let sorted = times.sorted()
            if let first = sorted.first, let last = sorted.last {
                let interval = last.timeIntervalSince(first)
                if interval <= 3600 { return true }
            }
        }
        return false
    }

    private static func countPerfectWeekendWeeks(habits: [Habit], calendar: Calendar) -> Int {
        let today = calendar.startOfDay(for: Date())
        var perfectWeekends = 0

        for weekOffset in 0..<8 {
            let weekEnd = calendar.date(byAdding: .day, value: -(weekOffset * 7), to: today) ?? today
            // Find Saturday and Sunday of that week
            let weekday = calendar.component(.weekday, from: weekEnd)
            let daysToSaturday = (weekday - 7 + 7) % 7
            let saturday = calendar.date(byAdding: .day, value: -daysToSaturday, to: weekEnd) ?? weekEnd
            let sunday = calendar.date(byAdding: .day, value: 1, to: saturday) ?? saturday

            var bothPerfect = true
            var hadAnyHabits = false
            for day in [saturday, sunday] {
                let dayStart = calendar.startOfDay(for: day)
                guard dayStart <= today else { bothPerfect = false; break }
                let activeHabits = habits.filter { !$0.isArchived && $0.targetDays.contains(calendar.component(.weekday, from: day) - 1) && $0.createdAt <= day }
                guard !activeHabits.isEmpty else { continue }
                hadAnyHabits = true
                let allDone = activeHabits.allSatisfy { h in
                    h.safeCompletions.contains { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted }
                }
                if !allDone { bothPerfect = false; break }
            }
            if !hadAnyHabits { bothPerfect = false }
            if bothPerfect { perfectWeekends += 1 }
        }
        return perfectWeekends
    }

    private static func countConsecutiveSleepDays(sleepLogs: [SleepLog], minHours: Double, calendar: Calendar) -> Int {
        let qualifyingDays = Set(sleepLogs.filter { $0.duration >= minHours * 3600 }.map { calendar.startOfDay(for: $0.bedTime) })
        guard !qualifyingDays.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: Date())
        var maxConsecutive = 0
        var current = 0

        for offset in 0..<60 {
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            if qualifyingDays.contains(day) {
                current += 1
                maxConsecutive = max(maxConsecutive, current)
            } else {
                current = 0
            }
        }
        return maxConsecutive
    }

    private static func hasPerfectWeek(habits: [Habit], calendar: Calendar) -> Bool {
        let today = calendar.startOfDay(for: Date())
        for startOffset in 0..<16 {
            let weekStart = calendar.date(byAdding: .day, value: -(startOffset + 6), to: today) ?? today
            var allPerfect = true
            var hasData = false
            for dayOffset in 0..<7 {
                let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
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
