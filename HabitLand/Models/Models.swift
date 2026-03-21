import Foundation
import SwiftData
import SwiftUI

// MARK: - Habit

@Model
final class Habit {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "checkmark.circle"
    var colorHex: String = "#34C759"
    var category: HabitCategory = HabitCategory.health
    var frequency: HabitFrequency = HabitFrequency.daily
    var targetDays: [Int] = [0, 1, 2, 3, 4, 5, 6]
    var reminderTime: Date?
    var reminderEnabled: Bool = false
    var goalCount: Int = 1
    var unit: String = "times"
    var notes: String = ""
    var isArchived: Bool = false
    var sortOrder: Int = 0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var healthKitMetric: String?

    @Relationship(deleteRule: .cascade) var completions: [HabitCompletion]? = []

    /// Safe accessor for completions (CloudKit requires optional relationship)
    var safeCompletions: [HabitCompletion] {
        completions ?? []
    }

    init(
        name: String,
        icon: String = "checkmark.circle",
        colorHex: String = "#34C759",
        category: HabitCategory = .health,
        frequency: HabitFrequency = .daily,
        targetDays: [Int] = [0, 1, 2, 3, 4, 5, 6],
        reminderTime: Date? = nil,
        reminderEnabled: Bool = false,
        goalCount: Int = 1,
        unit: String = "times",
        notes: String = "",
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.category = category
        self.frequency = frequency
        self.targetDays = targetDays
        self.reminderTime = reminderTime
        self.reminderEnabled = reminderEnabled
        self.goalCount = goalCount
        self.unit = unit
        self.notes = notes
        self.isArchived = false
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.updatedAt = Date()
        self.completions = []
        self.healthKitMetric = nil
    }

    var color: Color {
        #if WIDGET_EXTENSION
        Color(hex: colorHex) ?? .green
        #else
        Color(hex: colorHex) ?? .hlPrimary
        #endif
    }

    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var date = calendar.startOfDay(for: Date())
        let sortedCompletions = safeCompletions.sorted { $0.date > $1.date }

        let hasCompletionToday = sortedCompletions.contains {
            calendar.startOfDay(for: $0.date) == date && $0.isCompleted
        }
        if !hasCompletionToday {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: date) else { return 0 }
            date = yesterday
        }

        for completion in sortedCompletions {
            let completionDay = calendar.startOfDay(for: completion.date)
            if completionDay == date && completion.isCompleted {
                streak += 1
                guard let prevDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = prevDay
            } else if completionDay < date {
                break
            }
        }
        return streak
    }

    var todayCompleted: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return safeCompletions.contains { completion in
            Calendar.current.startOfDay(for: completion.date) == today && completion.isCompleted
        }
    }

    var todayProgress: Double {
        guard goalCount > 0 else { return 0 }
        let today = Calendar.current.startOfDay(for: Date())
        let todayCount = safeCompletions.filter { completion in
            Calendar.current.startOfDay(for: completion.date) == today && completion.isCompleted
        }.count
        return min(Double(todayCount) / Double(goalCount), 1.0)
    }

    var weekCompletionRate: Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return 0 }

        let weekCompletions = safeCompletions.filter { completion in
            let day = calendar.startOfDay(for: completion.date)
            return day >= weekAgo && day <= today && completion.isCompleted
        }
        let expectedDays = max(targetDays.count, 1)
        return Double(weekCompletions.count) / Double(expectedDays)
    }

    var bestStreak: Int {
        guard !safeCompletions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sorted = safeCompletions.filter(\.isCompleted).map { calendar.startOfDay(for: $0.date) }.sorted()
        guard !sorted.isEmpty else { return 0 }

        var best = 1
        var current = 1

        for i in 1..<sorted.count {
            if let expected = calendar.date(byAdding: .day, value: 1, to: sorted[i-1]),
               calendar.isDate(sorted[i], inSameDayAs: expected) {
                current += 1
                best = max(best, current)
            } else if !calendar.isDate(sorted[i], inSameDayAs: sorted[i-1]) {
                current = 1
            }
        }
        return best
    }

    var totalCompletions: Int {
        safeCompletions.filter(\.isCompleted).count
    }
}

// MARK: - Habit Completion

@Model
final class HabitCompletion {
    var id: UUID = UUID()
    var date: Date = Date()
    var isCompleted: Bool = true
    var count: Int = 1
    var note: String?
    var habit: Habit?

    init(date: Date = Date(), isCompleted: Bool = true, count: Int = 1, note: String? = nil) {
        self.id = UUID()
        self.date = date
        self.isCompleted = isCompleted
        self.count = count
        self.note = note
    }
}

// MARK: - Sleep Log

@Model
final class SleepLog {
    var id: UUID = UUID()
    var bedTime: Date = Date()
    var wakeTime: Date = Date()
    var quality: SleepQuality = SleepQuality.good
    var notes: String = ""
    var mood: Int = 3
    var createdAt: Date = Date()

    init(bedTime: Date, wakeTime: Date, quality: SleepQuality = .good, notes: String = "", mood: Int = 3) {
        self.id = UUID()
        self.bedTime = bedTime
        self.wakeTime = wakeTime
        self.quality = quality
        self.notes = notes
        self.mood = mood
        self.createdAt = Date()
    }

    var duration: TimeInterval {
        wakeTime.timeIntervalSince(bedTime)
    }

    var durationHours: Double {
        duration / 3600
    }

    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - User Profile

@Model
final class UserProfile {
    var id: UUID = UUID()
    var name: String = ""
    var username: String = ""
    var avatarEmoji: String = "🌱"
    var avatarTypeRaw: String = "initial"
    var level: Int = 1
    var xp: Int = 0
    var joinedAt: Date = Date()
    var bio: String = ""
    var sleepGoalHours: Double = 8.0
    var dailyHabitGoal: Int = 5

    // MARK: - Referral System
    var referralCode: String?
    var referredByCode: String?
    var referralCount: Int = 0

    var avatarType: AvatarType {
        get { AvatarType(rawStorage: avatarTypeRaw) ?? .initial }
        set { avatarTypeRaw = newValue.rawStorage }
    }

    init(
        name: String = "",
        username: String = "",
        avatarEmoji: String = "🌱",
        bio: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.username = username
        self.avatarEmoji = avatarEmoji
        self.avatarTypeRaw = "initial"
        self.level = 1
        self.xp = 0
        self.joinedAt = Date()
        self.bio = bio
        self.sleepGoalHours = 8.0
        self.dailyHabitGoal = 5
    }

    var xpForNextLevel: Int {
        level * 100
    }

    var levelProgress: Double {
        Double(xp) / Double(xpForNextLevel)
    }

    // MARK: - Referral Code Generation

    static func generateReferralCode(from uuid: UUID) -> String {
        let allowedChars = "ABCDEFGHJKMNPQRSTUVWXYZ23456789" // No I, L, O, 0, 1
        let hashBytes = Array(uuid.uuidString.utf8)
        var code = ""
        for i in 0..<6 {
            let index = Int(hashBytes[i]) % allowedChars.count
            code.append(allowedChars[allowedChars.index(allowedChars.startIndex, offsetBy: index)])
        }
        return code
    }

    var displayReferralCode: String {
        guard let code = referralCode else { return "" }
        return "HBT-\(code)"
    }

    var levelTitle: String {
        switch level {
        case 1...5: return "Seedling"
        case 6...10: return "Sprout"
        case 11...20: return "Sapling"
        case 21...35: return "Tree"
        case 36...50: return "Forest"
        default: return "Legend"
        }
    }
}

// MARK: - Achievement

@Model
final class Achievement {
    var id: UUID = UUID()
    var name: String = ""
    var descriptionText: String = ""
    var icon: String = "star.fill"
    var category: AchievementCategory = AchievementCategory.streak
    var isUnlocked: Bool = false
    var unlockedAt: Date?
    var progress: Double = 0
    var targetValue: Int = 1

    init(
        name: String,
        descriptionText: String,
        icon: String,
        category: AchievementCategory = .streak,
        targetValue: Int = 1
    ) {
        self.id = UUID()
        self.name = name
        self.descriptionText = descriptionText
        self.icon = icon
        self.category = category
        self.isUnlocked = false
        self.unlockedAt = nil
        self.progress = 0
        self.targetValue = targetValue
    }
}

// MARK: - Friend

@Model
final class Friend {
    var id: UUID = UUID()
    var name: String = ""
    var username: String = ""
    var avatarEmoji: String = "😊"
    var avatarTypeRaw: String = "initial"
    var level: Int = 1
    var currentStreak: Int = 0
    var sharedChallenges: Int = 0
    var addedAt: Date = Date()
    var cloudKitRecordName: String?
    var lastActive: Date?
    var totalCompletions: Int = 0
    var habitsCompletedToday: Int = 0
    var xp: Int = 0

    var avatarType: AvatarType {
        get { AvatarType(rawStorage: avatarTypeRaw) ?? .initial }
        set { avatarTypeRaw = newValue.rawStorage }
    }

    init(
        name: String,
        username: String,
        avatarEmoji: String = "😊",
        level: Int = 1,
        currentStreak: Int = 0,
        sharedChallenges: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.username = username
        self.avatarEmoji = avatarEmoji
        self.avatarTypeRaw = "initial"
        self.level = level
        self.currentStreak = currentStreak
        self.sharedChallenges = sharedChallenges
        self.addedAt = Date()
        self.cloudKitRecordName = nil
        self.lastActive = nil
        self.totalCompletions = 0
        self.habitsCompletedToday = 0
        self.xp = 0
    }
}

// MARK: - Challenge

@Model
final class Challenge {
    var id: UUID = UUID()
    var name: String = ""
    var descriptionText: String = ""
    var icon: String = "flag.fill"
    var startDate: Date = Date()
    var endDate: Date = Date().addingTimeInterval(7 * 24 * 3600)
    var participantCount: Int = 2
    var isActive: Bool = true
    var progress: Double = 0
    var cloudKitRecordName: String?
    var creatorRecordName: String?

    init(
        name: String,
        descriptionText: String,
        icon: String = "flag.fill",
        startDate: Date = Date(),
        endDate: Date = Date().addingTimeInterval(7 * 24 * 3600),
        participantCount: Int = 2
    ) {
        self.id = UUID()
        self.name = name
        self.descriptionText = descriptionText
        self.icon = icon
        self.startDate = startDate
        self.endDate = endDate
        self.participantCount = participantCount
        self.isActive = true
        self.progress = 0
        self.cloudKitRecordName = nil
        self.creatorRecordName = nil
    }

    var daysRemaining: Int {
        max(0, Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0)
    }
}

// MARK: - App Notification

@Model
final class AppNotification {
    var id: UUID = UUID()
    var title: String = ""
    var body: String = ""
    var icon: String = "bell.fill"
    var type: NotificationType = NotificationType.general
    var isRead: Bool = false
    var createdAt: Date = Date()

    init(title: String, body: String, icon: String = "bell.fill", type: NotificationType = .general) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.icon = icon
        self.type = type
        self.isRead = false
        self.createdAt = Date()
    }
}

// MARK: - Enums

enum HabitCategory: String, Codable, CaseIterable {
    case health = "Health"
    case fitness = "Fitness"
    case mindfulness = "Mindfulness"
    case productivity = "Productivity"
    case sleep = "Sleep"
    case social = "Social"
    case learning = "Learning"
    case nutrition = "Nutrition"

    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .fitness: return "figure.run"
        case .mindfulness: return "brain.head.profile"
        case .productivity: return "bolt.fill"
        case .sleep: return "moon.fill"
        case .social: return "person.2.fill"
        case .learning: return "book.fill"
        case .nutrition: return "leaf.fill"
        }
    }

    var color: Color {
        #if WIDGET_EXTENSION
        Color(hex: colorHex) ?? .green
        #else
        switch self {
        case .health: return .hlHealth
        case .fitness: return .hlFitness
        case .mindfulness: return .hlMindfulness
        case .productivity: return .hlProductivity
        case .sleep: return .hlSleep
        case .social: return .hlSocial
        case .learning: return .hlInfo
        case .nutrition: return .hlPrimary
        }
        #endif
    }

    var colorHex: String {
        switch self {
        case .health: return "#F24D66"
        case .fitness: return "#338FFF"
        case .mindfulness: return "#9966E6"
        case .productivity: return "#FF9919"
        case .sleep: return "#6659CC"
        case .social: return "#F27389"
        case .learning: return "#338FFF"
        case .nutrition: return "#34C759"
        }
    }
}

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
    case custom = "Custom"
}

enum SleepQuality: String, Codable, CaseIterable {
    case terrible = "Terrible"
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"

    var icon: String {
        switch self {
        case .terrible: return "😫"
        case .poor: return "😴"
        case .fair: return "😐"
        case .good: return "😊"
        case .excellent: return "🤩"
        }
    }

    var value: Double {
        switch self {
        case .terrible: return 0.2
        case .poor: return 0.4
        case .fair: return 0.6
        case .good: return 0.8
        case .excellent: return 1.0
        }
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case streak = "Streak"
    case completion = "Completion"
    case social = "Social"
    case sleep = "Sleep"
    case special = "Special"
}

enum NotificationType: String, Codable, CaseIterable {
    case habitReminder = "Habit Reminder"
    case streakAlert = "Streak Alert"
    case achievement = "Achievement"
    case social = "Social"
    case general = "General"
}

// MARK: - Color Hex Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Sample Data

struct SampleData {
    static let achievements: [(name: String, description: String, icon: String, category: AchievementCategory)] = [
        ("Habit Creator", "Create your first habit", "sparkle", .special),
        ("First Step", "Complete your first habit", "shoe.fill", .completion),
        ("On Fire", "Reach a 7-day streak", "flame.fill", .streak),
        ("Unstoppable", "Reach a 30-day streak", "bolt.fill", .streak),
        ("Century", "Complete 100 habits", "star.fill", .completion),
        ("Social Butterfly", "Add 5 friends", "person.2.fill", .social),
        ("Dream Catcher", "Log sleep for 7 days", "moon.fill", .sleep),
        ("Perfect Week", "Complete all habits for a week", "crown.fill", .special),
        ("Early Bird", "Complete a habit before 7am", "sunrise.fill", .special),
        ("Night Owl", "Log sleep after midnight 5 times", "owl", .sleep),
        ("Team Player", "Complete a shared challenge", "flag.fill", .social),
    ]
}
