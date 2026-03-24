import SwiftUI
import SwiftData

// MARK: - Difficulty Tier

private enum DifficultyTier: String {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var color: Color {
        switch self {
        case .easy: return .hlPrimary
        case .medium: return .hlWarning
        case .hard: return .hlError
        }
    }

    var icon: String {
        switch self {
        case .easy: return "checkmark.circle.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .hard: return "xmark.circle.fill"
        }
    }

    static func from(rate: Double) -> DifficultyTier {
        if rate >= 0.8 { return .easy }
        if rate >= 0.5 { return .medium }
        return .hard
    }
}

// MARK: - Difficulty Insights View

struct HabitDifficultyInsightsView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }) private var habits: [Habit]
    @State private var animateBars = false

    private var calendar: Calendar { Calendar.current }
    private var today: Date { calendar.startOfDay(for: Date()) }

    private var thirtyDaysAgo: Date {
        calendar.date(byAdding: .day, value: -30, to: today) ?? today
    }

    // Compute 30-day completion rate and missed count for each habit
    private var habitStats: [(habit: Habit, rate: Double, missed: Int)] {
        habits.compactMap { habit in
            var scheduled = 0
            var completed = 0
            for offset in 0..<30 {
                let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
                let dayStart = calendar.startOfDay(for: day)
                guard habit.createdAt <= day else { continue }
                let wd = calendar.component(.weekday, from: day) - 1
                guard habit.targetDays.contains(wd) else { continue }
                scheduled += 1
                if habit.safeCompletions.contains(where: { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted }) {
                    completed += 1
                }
            }
            guard scheduled > 0 else { return nil }
            let rate = Double(completed) / Double(scheduled)
            return (habit, rate, scheduled - completed)
        }
    }

    private var rankedByDifficulty: [(habit: Habit, rate: Double, missed: Int)] {
        habitStats.sorted { $0.rate > $1.rate }
    }

    private var easyCount: Int { habitStats.filter { DifficultyTier.from(rate: $0.rate) == .easy }.count }
    private var mediumCount: Int { habitStats.filter { DifficultyTier.from(rate: $0.rate) == .medium }.count }
    private var hardCount: Int { habitStats.filter { DifficultyTier.from(rate: $0.rate) == .hard }.count }

    private var frequentlyMissed: [(habit: Habit, rate: Double, missed: Int)] {
        Array(habitStats.sorted { $0.missed > $1.missed }.prefix(3))
    }

    // Suggestions based on real data
    private var suggestions: [(icon: String, title: String, body: String, color: Color)] {
        var result: [(String, String, String, Color)] = []

        // Hardest habit suggestion
        if let hardest = habitStats.min(by: { $0.rate < $1.rate }), hardest.rate < 0.5 {
            result.append(("arrow.down.circle", "Lower the Bar for \(hardest.habit.name)",
                           "Only \(Int(hardest.rate * 100))% completion. Consider making it easier or breaking it into smaller steps.",
                           hardest.habit.color))
        }

        // Habit stacking suggestion
        if let best = habitStats.max(by: { $0.rate < $1.rate }),
           let worst = habitStats.filter({ $0.rate < 0.7 }).first {
            result.append(("link", "Habit Stack",
                           "Pair \"\(worst.habit.name)\" with \"\(best.habit.name)\" — stacking hard habits with easy ones improves consistency.",
                           .hlProductivity))
        }

        // Reminder suggestion for missed habits
        if let mostMissed = frequentlyMissed.first, !mostMissed.habit.reminderEnabled {
            result.append(("bell.badge", "Add Reminders",
                           "\"\(mostMissed.habit.name)\" was missed \(mostMissed.missed) times. Setting a reminder could help.",
                           .hlWarning))
        }

        return result
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: HLSpacing.lg) {
                if habits.isEmpty {
                    emptyState
                } else {
                    headerSection
                    tierSummaryRow
                    if !rankedByDifficulty.isEmpty {
                        difficultyRankingCard
                    }
                    if !frequentlyMissed.isEmpty {
                        frequentlyMissedCard
                    }
                    if !suggestions.isEmpty {
                        suggestionsCard
                    }
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xxxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Difficulty Insights")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(HLAnimation.slow.delay(0.15)) {
                animateBars = true
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: HLIcon.barChart,
                title: "No Habits Yet",
                subtitle: "Create some habits to see difficulty insights based on your data."
            )
            Spacer()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text("Habit Difficulty")
                    .font(HLFont.title2())
                    .foregroundColor(.hlTextPrimary)
                Text("Based on last 30 days")
                    .font(HLFont.subheadline())
                    .foregroundColor(.hlTextSecondary)
            }
            Spacer()
            Image(systemName: HLIcon.barChart)
                .font(.title2)
                .foregroundColor(.hlPrimary)
        }
        .padding(.top, HLSpacing.xs)
    }

    // MARK: - Tier Summary

    private var tierSummaryRow: some View {
        HStack(spacing: HLSpacing.sm) {
            tierBadge(tier: .easy, count: easyCount)
            tierBadge(tier: .medium, count: mediumCount)
            tierBadge(tier: .hard, count: hardCount)
        }
    }

    private func tierBadge(tier: DifficultyTier, count: Int) -> some View {
        VStack(spacing: HLSpacing.xs) {
            Image(systemName: tier.icon)
                .font(.title2)
                .foregroundColor(tier.color)

            Text("\(count)")
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text(tier.rawValue)
                .font(HLFont.caption(.medium))
                .foregroundColor(.hlTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .hlCard(padding: HLSpacing.sm)
    }

    // MARK: - Difficulty Ranking

    private var difficultyRankingCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Ranked by Difficulty")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(rankedByDifficulty, id: \.habit.id) { item in
                let tier = DifficultyTier.from(rate: item.rate)
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: item.habit.icon)
                        .font(.callout)
                        .foregroundColor(item.habit.color)
                        .frame(width: 24)

                    Text(item.habit.name)
                        .font(HLFont.subheadline())
                        .foregroundColor(.hlTextPrimary)
                        .lineLimit(1)

                    Spacer()

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.hlDivider)
                                .frame(height: 8)
                            Capsule()
                                .fill(tier.color)
                                .frame(width: animateBars ? geo.size.width * item.rate : 0, height: 8)
                        }
                    }
                    .frame(width: 80, height: 8)

                    Text("\(Int(item.rate * 100))%")
                        .font(HLFont.footnote(.semibold))
                        .foregroundColor(tier.color)
                        .frame(width: 36, alignment: .trailing)

                    Text(tier.rawValue)
                        .font(HLFont.caption2(.semibold))
                        .foregroundColor(tier.color)
                        .padding(.horizontal, HLSpacing.xs)
                        .padding(.vertical, HLSpacing.xxxs)
                        .background(tier.color.opacity(0.12))
                        .cornerRadius(HLRadius.xs)
                        .frame(width: 56)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Frequently Missed

    private var frequentlyMissedCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Label("Most Frequently Missed", systemImage: HLIcon.trendDown)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(frequentlyMissed, id: \.habit.id) { item in
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: item.habit.icon)
                        .font(.callout)
                        .foregroundColor(.hlError)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text(item.habit.name)
                            .font(HLFont.subheadline(.medium))
                            .foregroundColor(.hlTextPrimary)
                        Text("Missed \(item.missed) times in 30 days")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextTertiary)
                    }

                    Spacer()

                    Text("\(item.missed)")
                        .font(HLFont.title3())
                        .foregroundColor(.hlError)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Suggestions

    private var suggestionsCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Label("Suggestions", systemImage: HLIcon.sparkles)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                HStack(alignment: .top, spacing: HLSpacing.sm) {
                    Image(systemName: suggestion.icon)
                        .font(.title3)
                        .foregroundColor(suggestion.color)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text(suggestion.title)
                            .font(HLFont.subheadline(.semibold))
                            .foregroundColor(.hlTextPrimary)
                        Text(suggestion.body)
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, HLSpacing.xxs)

                if index < suggestions.count - 1 {
                    Divider()
                        .foregroundColor(.hlDivider)
                }
            }
        }
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitDifficultyInsightsView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
