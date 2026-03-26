import SwiftUI
import SwiftData

struct PersonalStatisticsView: View {
    @ScaledMetric(relativeTo: .footnote) private var sectionIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var cardIconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .largeTitle) private var emptyIconSize: CGFloat = 40
    @Query(filter: #Predicate<Habit> { !$0.isArchived }) private var activeHabits: [Habit]
    @Query private var allHabits: [Habit]
    @Query private var achievements: [Achievement]
    @Query private var sleepLogs: [SleepLog]
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var calendar: Calendar { Calendar.current }
    private var today: Date { calendar.startOfDay(for: Date()) }

    private var totalCompletions: Int {
        allHabits.reduce(0) { $0 + $1.totalCompletions }
    }

    private var daysActive: Int {
        let uniqueDays = Set(allHabits.flatMap { habit in
            habit.safeCompletions.filter(\.isCompleted).map { calendar.startOfDay(for: $0.date) }
        })
        return uniqueDays.count
    }

    private var successRate: Double {
        guard !allHabits.isEmpty else { return 0 }
        let rates = allHabits.compactMap { habit -> Double? in
            let total = habit.safeCompletions.count
            guard total > 0 else { return nil }
            let completed = habit.safeCompletions.filter(\.isCompleted).count
            return Double(completed) / Double(total)
        }
        guard !rates.isEmpty else { return 0 }
        return rates.reduce(0, +) / Double(rates.count)
    }

    private var bestStreak: Int {
        allHabits.map(\.bestStreak).max() ?? 0
    }

    private var unlockedAchievementCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    // Monthly completions for last 6 months
    private var monthlyCompletions: [(label: String, count: Int)] {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        return (0..<6).reversed().map { offset in
            let monthDate = calendar.date(byAdding: .month, value: -offset, to: today) ?? today
            let comps = calendar.dateComponents([.year, .month], from: monthDate)
            let count = allHabits.reduce(0) { total, habit in
                total + habit.safeCompletions.filter { c in
                    let cComps = calendar.dateComponents([.year, .month], from: c.date)
                    return cComps.year == comps.year && cComps.month == comps.month && c.isCompleted
                }.count
            }
            return (fmt.string(from: monthDate), count)
        }
    }

    // Category breakdown
    private var categoryBreakdown: [(name: String, count: Int, color: Color)] {
        var result: [(String, Int, Color)] = []
        for category in HabitCategory.allCases {
            let count = allHabits.filter { $0.category == category }.reduce(0) { $0 + $1.totalCompletions }
            if count > 0 {
                result.append((category.rawValue, count, category.color))
            }
        }
        return result.sorted { $0.1 > $1.1 }
    }

    private var categoryTotal: Int {
        categoryBreakdown.reduce(0) { $0 + $1.count }
    }

    // Personal records
    private var longestStreakHabit: (name: String, streak: Int)? {
        allHabits.max(by: { $0.bestStreak < $1.bestStreak }).map { ($0.name, $0.bestStreak) }
    }

    private var bestMonth: (name: String, rate: Double)? {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        var best: (String, Double)? = nil
        for offset in 0..<12 {
            let monthDate = calendar.date(byAdding: .month, value: -offset, to: today) ?? today
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)) ?? today
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 0
            var totalRate = 0.0
            var count = 0
            for dayOffset in 0..<daysInMonth {
                let day = calendar.date(byAdding: .day, value: dayOffset, to: monthStart) ?? monthStart
                let dayStart = calendar.startOfDay(for: day)
                guard dayStart <= today else { continue }
                let active = activeHabits.filter { $0.createdAt <= day && $0.targetDays.contains(calendar.component(.weekday, from: day) - 1) }
                guard !active.isEmpty else { continue }
                let completed = active.filter { h in h.safeCompletions.contains { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted } }.count
                totalRate += Double(completed) / Double(active.count)
                count += 1
            }
            guard count >= 7 else { continue } // need at least a week of data
            let rate = totalRate / Double(count)
            if let currentBest = best {
                if rate > currentBest.1 {
                    best = (fmt.string(from: monthDate), rate)
                }
            } else {
                best = (fmt.string(from: monthDate), rate)
            }
        }
        return best
    }

    private var mostInADay: (count: Int, date: String)? {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM d, yyyy"
        var dayCounts: [Date: Int] = [:]
        for habit in allHabits {
            for c in habit.safeCompletions where c.isCompleted {
                let day = calendar.startOfDay(for: c.date)
                dayCounts[day, default: 0] += 1
            }
        }
        guard let best = dayCounts.max(by: { $0.value < $1.value }) else { return nil }
        return (best.value, fmt.string(from: best.key))
    }

    private var bestSleepWeek: (avg: Double, label: String)? {
        guard sleepLogs.count >= 7 else { return nil }
        let sorted = sleepLogs.sorted { $0.bedTime < $1.bedTime }
        var bestAvg = 0.0
        var bestStart: Date?
        for i in 0...(sorted.count - 7) {
            let week = sorted[i..<(i + 7)]
            let avg = week.map(\.durationHours).reduce(0, +) / 7.0
            if avg > bestAvg {
                bestAvg = avg
                bestStart = week.first?.bedTime
            }
        }
        guard let start = bestStart else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start
        return (bestAvg, "\(fmt.string(from: start))-\(fmt.string(from: end))")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                if allHabits.isEmpty {
                    emptyState
                } else {
                    allTimeMetrics
                    if monthlyCompletions.contains(where: { $0.count > 0 }) {
                        monthlyCompletionChart
                    }
                    if !categoryBreakdown.isEmpty {
                        categoryBreakdownSection
                    }
                    recordsSection
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.md)
            .hlAdaptiveWidth()
        }
        .refreshable {
            try? await Task.sleep(for: .milliseconds(300))
        }
        .background(Color.hlBackground)
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Spacer().frame(height: HLSpacing.xxxl)
            ZStack {
                Circle()
                    .fill(Color.hlPrimary.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: min(emptyIconSize, 48)))
                    .foregroundStyle(Color.hlPrimary.opacity(0.5))
            }
            Text("No statistics yet")
                .font(HLFont.title3(.semibold))
                .foregroundStyle(Color.hlTextPrimary)
            Text("Complete habits to see your\npersonal statistics here.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - All-Time Metrics

    private var allTimeMetrics: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("All-Time Stats")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: sizeClass == .regular ? 3 : 2), spacing: HLSpacing.sm) {
                metricTile(value: "\(totalCompletions)", label: "Total Completions", icon: "checkmark.circle.fill", color: .hlPrimary)
                metricTile(value: "\(daysActive)", label: "Days Active", icon: "calendar", color: .hlInfo)
                metricTile(value: "\(Int(successRate * 100))%", label: "Success Rate", icon: "chart.line.uptrend.xyaxis", color: .hlPrimary)
                metricTile(value: "\(bestStreak)", label: "Best Streak", icon: "flame.fill", color: .hlFlame)
                metricTile(value: "\(allHabits.count)", label: "Habits Created", icon: "plus.circle.fill", color: .hlMindfulness)
                metricTile(value: "\(unlockedAchievementCount)", label: "Achievements", icon: "trophy.fill", color: .hlGold)
            }
        }
    }

    private func metricTile(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: min(cardIconSize, 22)))
                .foregroundColor(color)
                .accessibilityHidden(true)

            Text(value)
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)
                .minimumScaleFactor(0.75)

            Text(label)
                .font(HLFont.caption())
                .foregroundColor(.hlTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
        .hlCard(padding: HLSpacing.sm)
    }

    // MARK: - Monthly Completion Chart

    private var monthlyCompletionChart: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Monthly Completions")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            let maxValue = Double(monthlyCompletions.map(\.count).max() ?? 1)

            HStack(alignment: .bottom, spacing: HLSpacing.xs) {
                ForEach(Array(monthlyCompletions.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: HLSpacing.xxs) {
                        Text("\(item.count)")
                            .font(HLFont.caption2(.medium))
                            .foregroundColor(.hlTextTertiary)

                        RoundedRectangle(cornerRadius: HLRadius.xs)
                            .fill(index == monthlyCompletions.count - 1 ? Color.hlPrimary : Color.hlPrimary.opacity(0.4))
                            .frame(height: maxValue > 0 ? CGFloat(Double(item.count) / maxValue) * 120 : 0)

                        Text(item.label)
                            .font(HLFont.caption2())
                            .foregroundColor(.hlTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
        }
        .hlCard()
    }

    // MARK: - Category Breakdown

    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Category Breakdown")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(categoryBreakdown, id: \.name) { cat in
                HStack(spacing: HLSpacing.sm) {
                    Circle()
                        .fill(cat.color)
                        .frame(width: 10, height: 10)

                    Text(cat.name)
                        .font(HLFont.subheadline())
                        .foregroundColor(.hlTextPrimary)

                    Spacer()

                    Text("\(cat.count)")
                        .font(HLFont.subheadline(.semibold))
                        .foregroundColor(.hlTextPrimary)

                    Text(categoryTotal > 0 ? "\(Int(Double(cat.count) / Double(categoryTotal) * 100))%" : "0%")
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)
                        .frame(width: 36, alignment: .trailing)
                }

                ProgressView(value: categoryTotal > 0 ? Double(cat.count) / Double(categoryTotal) : 0)
                    .tint(cat.color)
            }
        }
        .hlCard()
    }

    // MARK: - Records

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Personal Records")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            if let streak = longestStreakHabit, streak.streak > 0 {
                recordRow(icon: "flame.fill", color: .hlFlame, title: "Longest Streak", value: "\(streak.streak) days", subtitle: streak.name)
            }
            if let month = bestMonth {
                recordRow(icon: "star.fill", color: .hlGold, title: "Best Month", value: month.name, subtitle: "\(Int(month.rate * 100))% completion rate")
            }
            if let most = mostInADay, most.count > 0 {
                recordRow(icon: "checkmark.circle.fill", color: .hlPrimary, title: "Most in a Day", value: "\(most.count) habits", subtitle: most.date)
            }
            if let sleep = bestSleepWeek {
                recordRow(icon: "moon.fill", color: .hlSleep, title: "Best Sleep Week", value: String(format: "%.1fh avg", sleep.avg), subtitle: sleep.label)
            }
        }
        .hlCard()
    }

    private func recordRow(icon: String, color: Color, title: String, value: String, subtitle: String) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: min(sectionIconSize, 20)))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(title)
                    .font(HLFont.subheadline(.medium))
                    .foregroundColor(.hlTextPrimary)
                Text(subtitle)
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextTertiary)
            }

            Spacer()

            Text(value)
                .font(HLFont.subheadline(.semibold))
                .foregroundColor(.hlPrimary)
                .minimumScaleFactor(0.75)
        }
    }
}

#Preview {
    NavigationStack {
        PersonalStatisticsView()
    }
    .modelContainer(for: [Habit.self, Achievement.self, SleepLog.self], inMemory: true)
}
