import Foundation
import SwiftUI

/// Manages daily login streak and first-completion bonus XP
@MainActor
final class DailyBonusManager: ObservableObject {
    static let shared = DailyBonusManager()

    private let lastOpenDateKey = "dailyBonus_lastOpenDate"
    private let loginStreakKey = "dailyBonus_loginStreak"
    private let firstCompletionClaimedKey = "dailyBonus_firstCompletionClaimed"

    @Published private(set) var loginStreak: Int = 0
    @Published private(set) var showBonusBanner: Bool = false
    @Published private(set) var todayBonusClaimed: Bool = false

    private init() {
        loadState()
    }

    // MARK: - Login Streak

    /// Call on app launch / home appear to track daily opens
    func recordDailyOpen() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = UserDefaults.standard.object(forKey: lastOpenDateKey) as? Date {
            let lastDay = calendar.startOfDay(for: lastDate)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if dayDiff == 0 {
                // Same day, do nothing
                return
            } else if dayDiff == 1 {
                // Consecutive day — increment streak
                loginStreak += 1
            } else {
                // Missed a day — reset streak
                loginStreak = 1
            }
        } else {
            // First ever open
            loginStreak = 1
        }

        UserDefaults.standard.set(today, forKey: lastOpenDateKey)
        UserDefaults.standard.set(loginStreak, forKey: loginStreakKey)

        // Reset first completion claim for new day
        UserDefaults.standard.set(false, forKey: firstCompletionClaimedKey)
        todayBonusClaimed = false

        // Show bonus banner
        showBonusBanner = true
    }

    func dismissBanner() {
        withAnimation(HLAnimation.spring) {
            showBonusBanner = false
        }
    }

    // MARK: - First Completion Bonus

    /// XP multiplier for first completion of the day
    var bonusMultiplier: Int {
        switch loginStreak {
        case 1...2: return 2
        case 3...6: return 3
        case 7...: return 5
        default: return 1
        }
    }

    /// Returns bonus XP if first completion, else 0
    func claimFirstCompletionBonus(baseXP: Int) -> Int {
        guard !todayBonusClaimed else { return 0 }
        todayBonusClaimed = true
        UserDefaults.standard.set(true, forKey: firstCompletionClaimedKey)
        return baseXP * (bonusMultiplier - 1) // Extra XP on top of base
    }

    // MARK: - Display

    var streakEmoji: String {
        switch loginStreak {
        case 1...2: return "👋"
        case 3...6: return "🔥"
        case 7...13: return "⚡"
        case 14...29: return "💎"
        case 30...: return "👑"
        default: return "👋"
        }
    }

    var bonusLabel: String {
        "\(bonusMultiplier)x XP"
    }

    var streakMessage: String {
        switch loginStreak {
        case 1: return "Welcome back! First completion gets \(bonusLabel)"
        case 2: return "Day 2! Keep it up — \(bonusLabel) bonus"
        case 3...6: return "\(loginStreak)-day login streak! \(bonusLabel) bonus active"
        case 7: return "7-day login streak! \(bonusLabel) mega bonus!"
        case 8...29: return "\(loginStreak) days straight! \(bonusLabel) bonus"
        case 30...: return "\(loginStreak)-day legend! \(bonusLabel) bonus"
        default: return "Welcome! \(bonusLabel) bonus on first completion"
        }
    }

    // MARK: - Persistence

    private func loadState() {
        loginStreak = UserDefaults.standard.integer(forKey: loginStreakKey)
        todayBonusClaimed = UserDefaults.standard.bool(forKey: firstCompletionClaimedKey)

        // Check if last open was today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let lastDate = UserDefaults.standard.object(forKey: lastOpenDateKey) as? Date {
            let lastDay = calendar.startOfDay(for: lastDate)
            if lastDay != today {
                todayBonusClaimed = false
            }
        }
    }
}
