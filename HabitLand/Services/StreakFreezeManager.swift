import Foundation
import SwiftData
import SwiftUI

/// Manages streak freeze (shield) — users spend XP to protect streaks on missed days
@MainActor
final class StreakFreezeManager: ObservableObject {
    static let shared = StreakFreezeManager()

    static let freezeCostXP = 100
    static let maxFreezeStock = 5

    private init() {}

    // MARK: - Purchase Freeze

    /// Buy a streak freeze using XP. Returns true if successful.
    func purchaseFreeze(profile: UserProfile) -> Bool {
        guard profile.xp >= Self.freezeCostXP else { return false }
        guard profile.streakFreezeCount < Self.maxFreezeStock else { return false }

        profile.xp -= Self.freezeCostXP
        profile.streakFreezeCount += 1
        HLHaptics.success()
        return true
    }

    // MARK: - Use Freeze

    /// Automatically use a freeze for a missed day. Returns true if freeze was used.
    func useFreeze(profile: UserProfile, for date: Date) -> Bool {
        guard profile.streakFreezeCount > 0 else { return false }

        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)

        // Don't double-use for same day
        if profile.streakFreezeUsedDates.contains(where: { calendar.startOfDay(for: $0) == day }) {
            return false
        }

        profile.streakFreezeCount -= 1
        profile.streakFreezeUsedDates.append(day)
        return true
    }

    // MARK: - Check if Day is Frozen

    func isDayFrozen(_ date: Date, profile: UserProfile) -> Bool {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        return profile.streakFreezeUsedDates.contains { calendar.startOfDay(for: $0) == day }
    }

    // MARK: - Auto-Freeze Yesterday

    /// Call on app launch — if yesterday was missed, auto-use a freeze
    func checkAndAutoFreeze(profile: UserProfile, habits: [Habit]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }

        // Check if any habit had a streak going but missed yesterday
        let activeHabits = habits.filter { !$0.isArchived && $0.currentStreak > 0 }
        guard !activeHabits.isEmpty else { return }

        let missedYesterday = activeHabits.contains { habit in
            !habit.safeCompletions.contains { completion in
                calendar.startOfDay(for: completion.date) == yesterday && completion.isCompleted
            }
        }

        if missedYesterday && !isDayFrozen(yesterday, profile: profile) {
            let used = useFreeze(profile: profile, for: yesterday)
            if used {
                // Post notification so UI can show "Streak saved!" toast
                NotificationCenter.default.post(name: .streakFreezeUsed, object: nil)
            }
        }
    }
}

extension Notification.Name {
    static let streakFreezeUsed = Notification.Name("streakFreezeUsed")
}
