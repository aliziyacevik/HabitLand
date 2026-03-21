import Foundation
import SwiftData

// MARK: - Weekly Quest Model

struct WeeklyQuest: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let target: Int
    var progress: Int
    let xpReward: Int
    let type: QuestType
    var isCompleted: Bool

    enum QuestType: String, Codable {
        case totalCompletions
        case perfectDays
        case sleepLogs
        case categoryVariety
        case streakMaintain
    }

    var progressFraction: Double {
        guard target > 0 else { return 0 }
        return min(Double(progress) / Double(target), 1.0)
    }
}

// MARK: - Weekly Quest Manager

@MainActor
final class WeeklyQuestManager: ObservableObject {
    static let shared = WeeklyQuestManager()

    @Published var quests: [WeeklyQuest] = []

    private let questsKey = "weeklyQuests"
    private let weekKey = "weeklyQuestsWeek"

    private init() {
        loadOrGenerate()
    }

    func loadOrGenerate() {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let weekID = "\(currentYear)-W\(currentWeek)"

        let savedWeek = UserDefaults.standard.string(forKey: weekKey)
        if savedWeek == weekID, let data = UserDefaults.standard.data(forKey: questsKey),
           let saved = try? JSONDecoder().decode([WeeklyQuest].self, from: data) {
            quests = saved
        } else {
            quests = generateQuests()
            UserDefaults.standard.set(weekID, forKey: weekKey)
            save()
        }
    }

    func updateProgress(context: ModelContext) {
        let habits = (try? context.fetch(FetchDescriptor<Habit>())) ?? []
        let sleepLogs = (try? context.fetch(FetchDescriptor<SleepLog>())) ?? []
        let calendar = Calendar.current

        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!

        for i in quests.indices where !quests[i].isCompleted {
            switch quests[i].type {
            case .totalCompletions:
                let weekCompletions = habits.flatMap(\.safeCompletions).filter {
                    $0.isCompleted && $0.date >= weekStart
                }.count
                quests[i].progress = weekCompletions

            case .perfectDays:
                var perfectDays = 0
                for offset in 0..<7 {
                    guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart),
                          day <= Date() else { continue }
                    let dayStart = calendar.startOfDay(for: day)
                    let active = habits.filter { !$0.isArchived && $0.targetDays.contains(calendar.component(.weekday, from: day) - 1) && $0.createdAt <= day }
                    guard !active.isEmpty else { continue }
                    let allDone = active.allSatisfy { h in
                        h.safeCompletions.contains { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted }
                    }
                    if allDone { perfectDays += 1 }
                }
                quests[i].progress = perfectDays

            case .sleepLogs:
                let weekLogs = Set(sleepLogs.filter { $0.bedTime >= weekStart }.map { calendar.startOfDay(for: $0.bedTime) }).count
                quests[i].progress = weekLogs

            case .categoryVariety:
                let categories = Set(habits.flatMap(\.safeCompletions)
                    .filter { $0.isCompleted && $0.date >= weekStart }
                    .compactMap { $0.habit?.category })
                quests[i].progress = categories.count

            case .streakMaintain:
                let maxStreak = habits.map(\.currentStreak).max() ?? 0
                quests[i].progress = maxStreak
            }

            if quests[i].progress >= quests[i].target {
                quests[i].isCompleted = true
            }
        }
        save()
    }

    func claimReward(quest: WeeklyQuest, context: ModelContext) -> Int {
        guard quest.isCompleted else { return 0 }
        let profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first
        profile?.xp += quest.xpReward
        // Level up check
        if let profile {
            while profile.xp >= profile.xpForNextLevel {
                profile.xp -= profile.xpForNextLevel
                profile.level += 1
            }
        }
        try? context.save()
        return quest.xpReward
    }

    private func save() {
        if let data = try? JSONEncoder().encode(quests) {
            UserDefaults.standard.set(data, forKey: questsKey)
        }
    }

    private func generateQuests() -> [WeeklyQuest] {
        let templates: [(String, String, String, Int, Int, WeeklyQuest.QuestType)] = [
            ("Habit Machine", "Complete 15 habits this week", "checkmark.circle.fill", 15, 50, .totalCompletions),
            ("Habit Hero", "Complete 25 habits this week", "star.circle.fill", 25, 80, .totalCompletions),
            ("Perfect Day", "Have 2 perfect days this week", "crown.fill", 2, 60, .perfectDays),
            ("Flawless", "Have 4 perfect days this week", "crown.fill", 4, 120, .perfectDays),
            ("Sleep Logger", "Log sleep 4 times this week", "moon.fill", 4, 40, .sleepLogs),
            ("Dream Keeper", "Log sleep every day this week", "moon.stars.fill", 7, 100, .sleepLogs),
            ("Explorer", "Complete habits in 3 categories", "circle.grid.3x3.fill", 3, 50, .categoryVariety),
            ("Streak Keeper", "Maintain a 5-day streak", "flame.fill", 5, 60, .streakMaintain),
            ("Streak Guardian", "Maintain a 10-day streak", "bolt.fill", 10, 100, .streakMaintain),
        ]

        // Pick 3 random non-duplicate types
        var selected: [WeeklyQuest] = []
        var usedTypes: Set<WeeklyQuest.QuestType> = []
        var shuffled = templates.shuffled()

        for template in shuffled {
            guard selected.count < 3 else { break }
            if !usedTypes.contains(template.5) {
                usedTypes.insert(template.5)
                selected.append(WeeklyQuest(
                    id: UUID().uuidString,
                    title: template.0,
                    description: template.1,
                    icon: template.2,
                    target: template.3,
                    progress: 0,
                    xpReward: template.4,
                    type: template.5,
                    isCompleted: false
                ))
            }
        }

        // If we don't have 3 yet, fill from remaining
        for template in shuffled where selected.count < 3 {
            if !selected.contains(where: { $0.title == template.0 }) {
                selected.append(WeeklyQuest(
                    id: UUID().uuidString,
                    title: template.0,
                    description: template.1,
                    icon: template.2,
                    target: template.3,
                    progress: 0,
                    xpReward: template.4,
                    type: template.5,
                    isCompleted: false
                ))
            }
        }

        return selected
    }
}
