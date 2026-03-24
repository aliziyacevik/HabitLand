import SwiftData
import SwiftUI

// MARK: - Insights Overview View

struct InsightsOverviewView: View {
    @ScaledMetric(relativeTo: .largeTitle) private var emptyIconSize: CGFloat = 48
    @ScaledMetric(relativeTo: .caption) private var trendArrowSize: CGFloat = 10
    @ScaledMetric(relativeTo: .caption) private var flameIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var trendIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .footnote) private var sectionIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var cardIconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var habitIconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .title3) private var strongHabitIconSize: CGFloat = 26
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.name)
    private var habits: [Habit]

    @Environment(\.dismiss) private var dismiss

    // MARK: - Computed Data

    private var calendar: Calendar { Calendar.current }
    private var today: Date { calendar.startOfDay(for: Date()) }

    private var completedTodayCount: Int {
        habits.filter(\.todayCompleted).count
    }

    private var averageConsistency: Double {
        guard !habits.isEmpty else { return 0 }
        return habits.map(\.weekCompletionRate).reduce(0, +) / Double(habits.count)
    }

    private var maxCurrentStreak: Int {
        habits.map(\.currentStreak).max() ?? 0
    }

    private var previousWeekConsistency: Double {
        guard !habits.isEmpty else { return 0 }
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today) ?? today
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today

        let rates = habits.map { habit -> Double in
            let completions = habit.safeCompletions.filter { c in
                let day = calendar.startOfDay(for: c.date)
                return day >= twoWeeksAgo && day < oneWeekAgo && c.isCompleted
            }
            return Double(completions.count) / 7.0
        }
        return rates.reduce(0, +) / Double(habits.count)
    }

    private var consistencyTrend: TrendDirection {
        let diff = averageConsistency - previousWeekConsistency
        if diff > 0.05 { return .up }
        if diff < -0.05 { return .down }
        return .neutral
    }

    private var computedInsights: [Insight] {
        guard !habits.isEmpty else { return [] }
        var results: [Insight] = []

        // Week-over-week comparison
        let currentPct = Int(averageConsistency * 100)
        let prevPct = Int(previousWeekConsistency * 100)
        let diff = currentPct - prevPct
        if diff > 0 {
            results.append(Insight(
                title: "You're \(diff)% more consistent this week!",
                description: "Your completion rate jumped from \(prevPct)% to \(currentPct)%. Keep up the momentum.",
                color: .hlPrimary
            ))
        } else if diff < 0 {
            results.append(Insight(
                title: "Consistency dropped \(abs(diff))% this week",
                description: "Your completion rate went from \(prevPct)% to \(currentPct)%. A small dip is normal — refocus on your key habits.",
                color: .hlWarning
            ))
        }

        // Longest streak highlight
        if let streakHabit = habits.max(by: { $0.currentStreak < $1.currentStreak }),
           streakHabit.currentStreak >= 3 {
            let isBest = streakHabit.currentStreak >= streakHabit.bestStreak
            let suffix = isBest ? " This is your best streak ever for this habit!" : ""
            results.append(Insight(
                title: "\(streakHabit.name) streak is impressive",
                description: "\(streakHabit.currentStreak) days and counting!\(suffix)",
                color: .hlMindfulness
            ))
        }

        // Category performance
        let categories = Dictionary(grouping: habits, by: \.category)
        if let bestCategory = categories.max(by: {
            avgRate($0.value) < avgRate($1.value)
        }), avgRate(bestCategory.value) > 0.5 {
            results.append(Insight(
                title: "\(bestCategory.key.rawValue) habits are thriving",
                description: "\(Int(avgRate(bestCategory.value) * 100))% average completion this week across \(bestCategory.value.count) habit\(bestCategory.value.count == 1 ? "" : "s").",
                color: bestCategory.key.color
            ))
        }

        // Weak spot
        if let worstCategory = categories.min(by: {
            avgRate($0.value) < avgRate($1.value)
        }), categories.count > 1, avgRate(worstCategory.value) < 0.5 {
            results.append(Insight(
                title: "\(worstCategory.key.rawValue) habits need a boost",
                description: "Only \(Int(avgRate(worstCategory.value) * 100))% completion rate this week. Try reducing the number of goals or adjusting timing.",
                color: .hlWarning
            ))
        }

        return results
    }

    private var computedStrongestHabit: StrongestHabit? {
        guard !habits.isEmpty else { return nil }
        // Pick the habit with the highest current streak, break ties with weekCompletionRate
        guard let best = habits.max(by: {
            ($0.currentStreak, $0.weekCompletionRate) < ($1.currentStreak, $1.weekCompletionRate)
        }) else { return nil }

        let lastSevenDays = (0..<7).reversed().map { daysAgo -> Bool in
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
            return best.safeCompletions.contains { c in
                calendar.startOfDay(for: c.date) == day && c.isCompleted
            }
        }

        return StrongestHabit(
            name: best.name,
            icon: best.icon,
            color: best.color,
            streakDays: best.currentStreak,
            completionRate: Int(best.weekCompletionRate * 100),
            lastSevenDays: lastSevenDays
        )
    }

    private var computedAttentionHabits: [AttentionHabit] {
        guard !habits.isEmpty else { return [] }
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today) ?? today
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today

        return habits.compactMap { habit -> AttentionHabit? in
            let currentRate = habit.weekCompletionRate
            guard currentRate < 0.6 else { return nil }

            let prevCompletions = habit.safeCompletions.filter { c in
                let day = calendar.startOfDay(for: c.date)
                return day >= twoWeeksAgo && day < oneWeekAgo && c.isCompleted
            }
            let prevRate = Double(prevCompletions.count) / 7.0
            let drop = max(0, Int((prevRate - currentRate) * 100))

            let missedDays = 7 - Int(currentRate * 7)
            let reason: String
            if habit.currentStreak == 0 {
                reason = "Streak broken — missed \(missedDays) of last 7 days"
            } else {
                reason = "Missed \(missedDays) of last 7 days"
            }

            return AttentionHabit(
                name: habit.name,
                icon: habit.icon,
                color: habit.color,
                reason: reason,
                completionRate: Int(currentRate * 100),
                dropPercent: drop
            )
        }
        .sorted { $0.completionRate < $1.completionRate }
        .prefix(3)
        .map { $0 }
    }

    private var computedTrends: [TrendItem] {
        guard !habits.isEmpty else { return [] }
        var results: [TrendItem] = []

        // Overall consistency trend
        let currentPct = Int(averageConsistency * 100)
        let prevPct = Int(previousWeekConsistency * 100)
        let diff = currentPct - prevPct
        results.append(TrendItem(
            title: "Overall Consistency",
            detail: "Compared to last week",
            value: "\(diff >= 0 ? "+" : "")\(diff)%",
            isPositive: diff >= 0
        ))

        // Category-level trends
        let categories = Dictionary(grouping: habits, by: \.category)
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today) ?? today
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today

        for (category, categoryHabits) in categories.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let currentRate = avgRate(categoryHabits)
            let prevRate: Double = {
                let rates = categoryHabits.map { habit -> Double in
                    let count = habit.safeCompletions.filter { c in
                        let day = calendar.startOfDay(for: c.date)
                        return day >= twoWeeksAgo && day < oneWeekAgo && c.isCompleted
                    }.count
                    return Double(count) / 7.0
                }
                return rates.reduce(0, +) / Double(rates.count)
            }()
            let catDiff = Int((currentRate - prevRate) * 100)
            results.append(TrendItem(
                title: "\(category.rawValue) Habits",
                detail: "7-day average",
                value: "\(catDiff >= 0 ? "+" : "")\(catDiff)%",
                isPositive: catDiff >= 0
            ))
        }

        // Average streak length trend
        let avgStreak = habits.isEmpty ? 0 : habits.map(\.currentStreak).reduce(0, +) / habits.count
        results.append(TrendItem(
            title: "Average Streak Length",
            detail: "Across all habits",
            value: "\(avgStreak) days",
            isPositive: avgStreak >= 3
        ))

        return results
    }

    // MARK: - Helpers

    private func avgRate(_ habits: [Habit]) -> Double {
        guard !habits.isEmpty else { return 0 }
        return habits.map(\.weekCompletionRate).reduce(0, +) / Double(habits.count)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                if habits.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: HLSpacing.lg) {
                        trendSummaryCard
                        insightCardsSection
                        if computedStrongestHabit != nil {
                            strongestHabitCard
                        }
                        if !computedAttentionHabits.isEmpty {
                            needsAttentionSection
                        }
                        trendsSection
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.bottom, HLSpacing.xxxl)
                }
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: HLIcon.back)
                            .foregroundStyle(Color.hlTextPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()
                .frame(height: 80)

            Image(systemName: HLIcon.sparkles)
                .font(.system(size: min(emptyIconSize, 56)))
                .foregroundStyle(Color.hlTextTertiary)

            Text("No Insights Yet")
                .font(HLFont.title3())
                .foregroundStyle(Color.hlTextPrimary)

            Text("Start tracking habits to see personalized insights about your progress and patterns.")
                .font(HLFont.callout())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HLSpacing.xl)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Trend Summary Card

    private var trendSummaryCard: some View {
        VStack(spacing: HLSpacing.md) {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: HLIcon.sparkles)
                    .font(.system(size: min(cardIconSize, 22)))
                    .foregroundStyle(Color.hlMindfulness)
                    .accessibilityHidden(true)
                Text("Your Week at a Glance")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Spacer()
            }

            HStack(spacing: HLSpacing.lg) {
                trendStat(
                    value: "\(Int(averageConsistency * 100))%",
                    label: "Consistency",
                    color: .hlPrimary,
                    trend: consistencyTrend
                )
                Divider().frame(height: 36)
                trendStat(
                    value: "\(maxCurrentStreak)",
                    label: "Day Streak",
                    color: .hlFlame,
                    trend: maxCurrentStreak > 0 ? .up : .neutral
                )
                Divider().frame(height: 36)
                trendStat(
                    value: "\(completedTodayCount)/\(habits.count)",
                    label: "Habits Today",
                    color: .hlInfo,
                    trend: .neutral
                )
            }
            .frame(maxWidth: .infinity)
        }
        .hlCard()
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .stroke(Color.hlMindfulness.opacity(0.2), lineWidth: 1)
        )
    }

    private enum TrendDirection {
        case up, down, neutral
    }

    private func trendStat(value: String, label: String, color: Color, trend: TrendDirection) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            HStack(spacing: HLSpacing.xxxs) {
                Text(value)
                    .font(HLFont.title3())
                    .foregroundStyle(color)
                if trend != .neutral {
                    Image(systemName: trend == .up ? HLIcon.trendUp : HLIcon.trendDown)
                        .font(.system(size: min(trendArrowSize, 14), weight: .bold))
                        .foregroundStyle(trend == .up ? Color.hlSuccess : Color.hlError)
                        .accessibilityHidden(true)
                }
            }
            Text(label)
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextTertiary)
        }
    }

    // MARK: - Insight Cards Section

    private var insightCardsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Key Insights")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            if computedInsights.isEmpty {
                Text("Keep tracking your habits to unlock insights.")
                    .font(HLFont.footnote())
                    .foregroundStyle(Color.hlTextSecondary)
                    .hlCard(padding: HLSpacing.sm)
            } else {
                VStack(spacing: HLSpacing.xs) {
                    ForEach(computedInsights) { insight in
                        insightCard(insight)
                    }
                }
            }
        }
    }

    private func insightCard(_ insight: Insight) -> some View {
        HStack(alignment: .top, spacing: HLSpacing.sm) {
            ZStack {
                Circle()
                    .fill(insight.color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: HLIcon.sparkles)
                    .font(.system(size: min(cardIconSize, 22)))
                    .foregroundStyle(insight.color)
            }

            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text(insight.title)
                    .font(HLFont.callout(.semibold))
                    .foregroundStyle(Color.hlTextPrimary)
                Text(insight.description)
                    .font(HLFont.footnote())
                    .foregroundStyle(Color.hlTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .hlCard(padding: HLSpacing.sm)
    }

    // MARK: - Strongest Habit Card

    @ViewBuilder
    private var strongestHabitCard: some View {
        if let strongest = computedStrongestHabit {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: HLIcon.trophy)
                    .font(.system(size: min(sectionIconSize, 20)))
                    .foregroundStyle(Color.hlGold)
                    .accessibilityHidden(true)
                Text("Your Strongest Habit")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            HStack(spacing: HLSpacing.md) {
                ZStack {
                    Circle()
                        .fill(strongest.color.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: strongest.icon)
                        .font(.system(size: min(strongHabitIconSize, 30)))
                        .foregroundStyle(strongest.color)
                }

                VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                    Text(strongest.name)
                        .font(HLFont.title3())
                        .foregroundStyle(Color.hlTextPrimary)

                    HStack(spacing: HLSpacing.md) {
                        HStack(spacing: HLSpacing.xxxs) {
                            Image(systemName: HLIcon.flame)
                                .font(.system(size: min(flameIconSize, 16)))
                                .foregroundStyle(Color.hlFlame)
                                .accessibilityHidden(true)
                            Text("\(strongest.streakDays)d streak")
                                .font(HLFont.caption(.medium))
                                .foregroundStyle(Color.hlTextSecondary)
                        }
                        HStack(spacing: HLSpacing.xxxs) {
                            Image(systemName: HLIcon.chart)
                                .font(.system(size: min(flameIconSize, 16)))
                                .foregroundStyle(Color.hlInfo)
                                .accessibilityHidden(true)
                            Text("\(strongest.completionRate)% rate")
                                .font(HLFont.caption(.medium))
                                .foregroundStyle(Color.hlTextSecondary)
                        }
                    }
                }

                Spacer()
            }

            // Mini completion bars
            HStack(spacing: HLSpacing.xxxs) {
                ForEach(0..<7, id: \.self) { index in
                    RoundedRectangle(cornerRadius: HLRadius.xs)
                        .fill(strongest.lastSevenDays[index] ? strongest.color : Color.hlDivider)
                        .frame(height: 6)
                }
            }

            HStack {
                Text("Last 7 days")
                    .font(HLFont.caption2())
                    .foregroundStyle(Color.hlTextTertiary)
                Spacer()
                Text("\(strongest.lastSevenDays.filter { $0 }.count)/7 completed")
                    .font(HLFont.caption2(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
            }
        }
        .hlCard()
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .stroke(Color.hlGold.opacity(0.2), lineWidth: 1)
        )
        }
    }

    // MARK: - Needs Attention Section

    private var needsAttentionSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: min(sectionIconSize, 20)))
                    .foregroundStyle(Color.hlWarning)
                    .accessibilityHidden(true)
                Text("Needs Attention")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            VStack(spacing: HLSpacing.xs) {
                ForEach(computedAttentionHabits) { habit in
                    HStack(spacing: HLSpacing.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: HLRadius.sm)
                                .fill(habit.color.opacity(0.12))
                                .frame(width: 40, height: 40)
                            Image(systemName: habit.icon)
                                .font(.system(size: min(cardIconSize, 22)))
                                .foregroundStyle(habit.color)
                        }

                        VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                            Text(habit.name)
                                .font(HLFont.callout(.medium))
                                .foregroundStyle(Color.hlTextPrimary)
                            Text(habit.reason)
                                .font(HLFont.caption())
                                .foregroundStyle(Color.hlTextSecondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: HLSpacing.xxxs) {
                            Text("\(habit.completionRate)%")
                                .font(HLFont.callout(.semibold))
                                .foregroundStyle(Color.hlWarning)
                            HStack(spacing: HLSpacing.xxxs) {
                                Image(systemName: HLIcon.trendDown)
                                    .font(.system(size: min(trendArrowSize, 14), weight: .bold))
                                    .accessibilityHidden(true)
                                Text("\(habit.dropPercent)%")
                                    .font(HLFont.caption2(.medium))
                            }
                            .foregroundStyle(Color.hlError)
                        }
                    }
                    .hlCard(padding: HLSpacing.sm)
                }
            }
        }
    }

    // MARK: - Trends Section

    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Trends")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            VStack(spacing: HLSpacing.xs) {
                ForEach(computedTrends) { trend in
                    HStack(spacing: HLSpacing.sm) {
                        Image(systemName: trend.isPositive ? HLIcon.trendUp : HLIcon.trendDown)
                            .font(.system(size: min(trendIconSize, 18), weight: .bold))
                            .foregroundStyle(trend.isPositive ? Color.hlSuccess : Color.hlError)
                            .frame(width: 28)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                            Text(trend.title)
                                .font(HLFont.callout(.medium))
                                .foregroundStyle(Color.hlTextPrimary)
                            Text(trend.detail)
                                .font(HLFont.caption())
                                .foregroundStyle(Color.hlTextSecondary)
                        }

                        Spacer()

                        Text(trend.value)
                            .font(HLFont.subheadline(.semibold))
                            .foregroundStyle(trend.isPositive ? Color.hlSuccess : Color.hlError)
                    }
                    .hlCard(padding: HLSpacing.sm)
                }
            }
        }
    }
}

// MARK: - Supporting Display Models

private struct Insight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let color: Color
}

private struct StrongestHabit {
    let name: String
    let icon: String
    let color: Color
    let streakDays: Int
    let completionRate: Int
    let lastSevenDays: [Bool]
}

private struct AttentionHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let reason: String
    let completionRate: Int
    let dropPercent: Int
}

private struct TrendItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let value: String
    let isPositive: Bool
}

// MARK: - Preview

#Preview {
    InsightsOverviewView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
