import SwiftUI
import SwiftData

// MARK: - Weekly Analytics View

struct WeeklyAnalyticsView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }) private var habits: [Habit]
    @State private var animateRing = false
    @State private var animateBars = false

    private var calendar: Calendar { Calendar.current }

    private var weekStart: Date {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today) // 1=Sun
        let daysBack = (weekday - 2 + 7) % 7 // Monday-based
        return calendar.date(byAdding: .day, value: -daysBack, to: today)!
    }

    private var previousWeekStart: Date {
        calendar.date(byAdding: .day, value: -7, to: weekStart)!
    }

    private var weekDateRange: String {
        let end = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        let yearFmt = DateFormatter()
        yearFmt.dateFormat = ", yyyy"
        return "\(fmt.string(from: weekStart)) - \(fmt.string(from: end))\(yearFmt.string(from: end))"
    }

    // Day-by-day data for current week
    private var weekDays: [(label: String, rate: Double, completed: Int, total: Int)] {
        let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: weekStart)!
            let dayStart = calendar.startOfDay(for: day)
            let today = calendar.startOfDay(for: Date())
            guard dayStart <= today else {
                return (labels[offset], -1, 0, 0) // future day
            }
            let activeHabits = habits.filter { habit in
                let weekdayIndex = calendar.component(.weekday, from: day) - 1 // 0=Sun
                return habit.targetDays.contains(weekdayIndex) && habit.createdAt <= day
            }
            let total = activeHabits.count
            guard total > 0 else { return (labels[offset], 0, 0, 0) }
            let completed = activeHabits.filter { habit in
                habit.safeCompletions.contains { c in
                    calendar.startOfDay(for: c.date) == dayStart && c.isCompleted
                }
            }.count
            return (labels[offset], Double(completed) / Double(total), completed, total)
        }
    }

    private var trackedDays: [(label: String, rate: Double, completed: Int, total: Int)] {
        weekDays.filter { $0.rate >= 0 }
    }

    private var overallRate: Double {
        let tracked = trackedDays
        guard !tracked.isEmpty else { return 0 }
        let totalCompleted = tracked.reduce(0) { $0 + $1.completed }
        let totalHabits = tracked.reduce(0) { $0 + $1.total }
        guard totalHabits > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalHabits)
    }

    private var totalCompleted: Int {
        trackedDays.reduce(0) { $0 + $1.completed }
    }

    private var totalHabits: Int {
        trackedDays.reduce(0) { $0 + $1.total }
    }

    private var previousWeekRate: Double {
        let prevEnd = calendar.date(byAdding: .day, value: 6, to: previousWeekStart)!
        var totalCompleted = 0
        var totalHabits = 0
        for offset in 0..<7 {
            let day = calendar.date(byAdding: .day, value: offset, to: previousWeekStart)!
            let dayStart = calendar.startOfDay(for: day)
            guard dayStart <= calendar.startOfDay(for: prevEnd) else { continue }
            let activeHabits = habits.filter { habit in
                let weekdayIndex = calendar.component(.weekday, from: day) - 1
                return habit.targetDays.contains(weekdayIndex) && habit.createdAt <= day
            }
            let total = activeHabits.count
            guard total > 0 else { continue }
            totalHabits += total
            totalCompleted += activeHabits.filter { habit in
                habit.safeCompletions.contains { c in
                    calendar.startOfDay(for: c.date) == dayStart && c.isCompleted
                }
            }.count
        }
        guard totalHabits > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalHabits)
    }

    private var weekChange: Double {
        overallRate - previousWeekRate
    }

    private var bestDay: (label: String, rate: Double)? {
        trackedDays.filter { $0.total > 0 }.max(by: { $0.rate < $1.rate }).map { ($0.label, $0.rate) }
    }

    private var worstDay: (label: String, rate: Double)? {
        trackedDays.filter { $0.total > 0 }.min(by: { $0.rate < $1.rate }).map { ($0.label, $0.rate) }
    }

    // Top performing habits (sorted by weekly completion rate)
    private var rankedHabits: [(habit: Habit, rate: Double)] {
        let today = calendar.startOfDay(for: Date())
        return habits.compactMap { habit in
            var scheduled = 0
            var completed = 0
            for offset in 0..<7 {
                let day = calendar.date(byAdding: .day, value: offset, to: weekStart)!
                let dayStart = calendar.startOfDay(for: day)
                guard dayStart <= today, habit.createdAt <= day else { continue }
                let weekdayIndex = calendar.component(.weekday, from: day) - 1
                guard habit.targetDays.contains(weekdayIndex) else { continue }
                scheduled += 1
                if habit.safeCompletions.contains(where: { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted }) {
                    completed += 1
                }
            }
            guard scheduled > 0 else { return nil }
            return (habit, Double(completed) / Double(scheduled))
        }.sorted { $0.rate > $1.rate }
    }

    private var topHabits: [(habit: Habit, rate: Double)] {
        Array(rankedHabits.prefix(3))
    }

    private var missedHabits: [(habit: Habit, rate: Double)] {
        Array(rankedHabits.filter { $0.rate < 0.7 }.suffix(3).reversed())
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: HLSpacing.lg) {
                if habits.isEmpty {
                    emptyState
                } else {
                    headerSection
                    completionRingCard
                    if previousWeekRate > 0 || overallRate > 0 {
                        weekComparisonCard
                    }
                    barChartCard
                    if bestDay != nil, worstDay != nil {
                        bestWorstDayRow
                    }
                    if !topHabits.isEmpty {
                        topHabitsCard
                    }
                    if !missedHabits.isEmpty {
                        missedHabitsCard
                    }
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xxxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Weekly Analytics")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(HLAnimation.slow) {
                animateRing = true
            }
            withAnimation(HLAnimation.slow.delay(0.2)) {
                animateBars = true
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Spacer().frame(height: 80)

            ZStack {
                Circle()
                    .fill(Color.hlPrimary.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: HLIcon.chart)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.hlPrimary.opacity(0.5))
            }

            Text("No habits yet")
                .font(HLFont.title3(.semibold))
                .foregroundStyle(Color.hlTextPrimary)

            Text("Create habits to see your\nweekly analytics here.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text("This Week")
                    .font(HLFont.title2())
                    .foregroundColor(.hlTextPrimary)
                Text(weekDateRange)
                    .font(HLFont.subheadline())
                    .foregroundColor(.hlTextSecondary)
            }
            Spacer()
            Image(systemName: HLIcon.calendar)
                .font(.title2)
                .foregroundColor(.hlPrimary)
        }
        .padding(.top, HLSpacing.xs)
    }

    // MARK: - Completion Ring

    private var completionRingCard: some View {
        VStack(spacing: HLSpacing.md) {
            ZStack {
                Circle()
                    .stroke(Color.hlDivider, lineWidth: 14)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: animateRing ? overallRate : 0)
                    .stroke(
                        AngularGradient(
                            colors: [.hlPrimary, .hlPrimaryDark, .hlPrimary],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: HLSpacing.xxs) {
                    Text("\(Int(overallRate * 100))%")
                        .font(HLFont.largeTitle())
                        .foregroundColor(.hlTextPrimary)
                    Text("Completed")
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlTextSecondary)
                }
            }

            Text("\(totalCompleted) of \(totalHabits) habits completed")
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .hlCard(padding: HLSpacing.lg)
    }

    // MARK: - Week Comparison

    private var weekComparisonCard: some View {
        HStack(spacing: HLSpacing.md) {
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text("vs Last Week")
                    .font(HLFont.footnote(.medium))
                    .foregroundColor(.hlTextSecondary)

                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: weekChange >= 0 ? HLIcon.trendUp : HLIcon.trendDown)
                        .font(HLFont.headline())
                        .foregroundColor(weekChange >= 0 ? .hlSuccess : .hlError)

                    Text("\(weekChange >= 0 ? "+" : "")\(Int(weekChange * 100))%")
                        .font(HLFont.title2())
                        .foregroundColor(weekChange >= 0 ? .hlSuccess : .hlError)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: HLSpacing.xxs) {
                Text("Last Week")
                    .font(HLFont.footnote(.medium))
                    .foregroundColor(.hlTextSecondary)
                Text("\(Int(previousWeekRate * 100))%")
                    .font(HLFont.title3())
                    .foregroundColor(.hlTextPrimary)
            }
        }
        .hlCard()
    }

    // MARK: - Bar Chart

    private var barChartCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Day by Day")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            HStack(alignment: .bottom, spacing: HLSpacing.sm) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: HLSpacing.xxs) {
                        if day.rate >= 0 {
                            Text("\(Int(day.rate * 100))%")
                                .font(HLFont.caption2(.medium))
                                .foregroundColor(.hlTextTertiary)
                        } else {
                            Text("—")
                                .font(HLFont.caption2(.medium))
                                .foregroundColor(.hlTextTertiary)
                        }

                        RoundedRectangle(cornerRadius: HLRadius.xs)
                            .fill(day.rate < 0 ? Color.hlDivider.opacity(0.5) :
                                    day.rate >= 0.8 ? Color.hlPrimary :
                                    day.rate >= 0.5 ? Color.hlWarning : Color.hlError.opacity(0.7))
                            .frame(
                                height: animateBars ? max(20, (day.rate < 0 ? 0.1 : day.rate) * 120) : 0
                            )

                        Text(day.label)
                            .font(HLFont.caption2(.medium))
                            .foregroundColor(.hlTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
        }
        .hlCard()
    }

    // MARK: - Best / Worst Day

    private var bestWorstDayRow: some View {
        HStack(spacing: HLSpacing.md) {
            if let best = bestDay {
                dayCard(
                    title: "Best Day",
                    day: best.label,
                    rate: best.rate,
                    icon: HLIcon.trophy,
                    color: .hlGold
                )
            }

            if let worst = worstDay {
                dayCard(
                    title: "Worst Day",
                    day: worst.label,
                    rate: worst.rate,
                    icon: HLIcon.trendDown,
                    color: .hlError
                )
            }
        }
    }

    private func dayCard(title: String, day: String, rate: Double, icon: String, color: Color) -> some View {
        VStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(HLFont.caption(.medium))
                .foregroundColor(.hlTextSecondary)

            Text(day)
                .font(HLFont.title3())
                .foregroundColor(.hlTextPrimary)

            Text("\(Int(rate * 100))%")
                .font(HLFont.headline())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .hlCard()
    }

    // MARK: - Top Habits

    private var topHabitsCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Label("Top Performing", systemImage: HLIcon.star)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(topHabits, id: \.habit.id) { item in
                habitRow(name: item.habit.name, icon: item.habit.icon, color: item.habit.color, rate: item.rate)
            }
        }
        .hlCard()
    }

    // MARK: - Missed Habits

    private var missedHabitsCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Label("Needs Attention", systemImage: HLIcon.trendDown)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(missedHabits, id: \.habit.id) { item in
                habitRow(name: item.habit.name, icon: item.habit.icon, color: item.habit.color, rate: item.rate)
            }
        }
        .hlCard()
    }

    private func habitRow(name: String, icon: String, color: Color, rate: Double) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 28, height: 28)

            Text(name)
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextPrimary)

            Spacer()

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.hlDivider)
                    .frame(width: 60, height: 6)
                Capsule()
                    .fill(rate >= 0.7 ? Color.hlPrimary :
                            rate >= 0.5 ? Color.hlWarning : Color.hlError)
                    .frame(width: 60 * rate, height: 6)
            }

            Text("\(Int(rate * 100))%")
                .font(HLFont.footnote(.semibold))
                .foregroundColor(.hlTextSecondary)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WeeklyAnalyticsView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
