import SwiftUI
import SwiftData

struct HabitStatisticsView: View {
    let habit: Habit

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                completionRateChart
                bestWorstDays
                monthlyComparison
                streakHistory
                averageCompletionTime
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Completion Rate Chart

    private var completionRateChart: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Completion Rate")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            Text("Last 12 Weeks")
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextTertiary)

            let data = weeklyCompletionData()

            // Line Chart
            GeometryReader { geometry in
                let width = geometry.size.width
                let height: CGFloat = 140
                let stepX = data.count > 1 ? width / CGFloat(data.count - 1) : width

                ZStack(alignment: .bottomLeading) {
                    // Grid lines
                    ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { level in
                        Path { path in
                            let y = height - (height * level)
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                        .stroke(Color.hlDivider, style: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    }

                    // Line
                    if data.count > 1 {
                        Path { path in
                            for (index, value) in data.enumerated() {
                                let x = CGFloat(index) * stepX
                                let y = height - (height * value)
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(habit.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        // Area fill
                        Path { path in
                            for (index, value) in data.enumerated() {
                                let x = CGFloat(index) * stepX
                                let y = height - (height * value)
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: height))
                                    path.addLine(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                            path.addLine(to: CGPoint(x: CGFloat(data.count - 1) * stepX, y: height))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [habit.color.opacity(0.3), habit.color.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        // Dots
                        ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                            Circle()
                                .fill(habit.color)
                                .frame(width: 6, height: 6)
                                .position(
                                    x: CGFloat(index) * stepX,
                                    y: height - (height * value)
                                )
                        }
                    }
                }
            }
            .frame(height: 140)
            .padding(.top, HLSpacing.xs)

            // Labels
            HStack {
                Text("12w ago")
                    .font(HLFont.caption2())
                    .foregroundStyle(Color.hlTextTertiary)
                Spacer()
                Text("This week")
                    .font(HLFont.caption2())
                    .foregroundStyle(Color.hlTextTertiary)
            }
        }
        .hlCard()
    }

    // MARK: - Best/Worst Days

    private var bestWorstDays: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Best & Worst Days")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            let dayStats = dayOfWeekStats()
            let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            let maxValue = dayStats.max() ?? 1

            HStack(alignment: .bottom, spacing: HLSpacing.xs) {
                ForEach(0..<7, id: \.self) { day in
                    let value = dayStats[day]
                    let normalized = maxValue > 0 ? CGFloat(value) / CGFloat(maxValue) : 0
                    let isBest = value == dayStats.max()
                    let isWorst = value == dayStats.min() && value != dayStats.max()

                    VStack(spacing: HLSpacing.xxs) {
                        Text("\(value)")
                            .font(HLFont.caption2(.medium))
                            .foregroundStyle(isBest ? Color.hlPrimary : (isWorst ? Color.hlError : Color.hlTextTertiary))

                        RoundedRectangle(cornerRadius: HLRadius.xs)
                            .fill(isBest ? Color.hlPrimary : (isWorst ? Color.hlError.opacity(0.5) : habit.color.opacity(0.3)))
                            .frame(height: max(8, normalized * 80))
                            .frame(maxWidth: .infinity)

                        Text(dayLabels[day])
                            .font(HLFont.caption2(.medium))
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                }
            }
            .frame(height: 120)

            HStack(spacing: HLSpacing.lg) {
                HStack(spacing: HLSpacing.xxs) {
                    Circle().fill(Color.hlPrimary).frame(width: 8, height: 8)
                    Text("Best").font(HLFont.caption2()).foregroundStyle(Color.hlTextTertiary)
                }
                HStack(spacing: HLSpacing.xxs) {
                    Circle().fill(Color.hlError.opacity(0.5)).frame(width: 8, height: 8)
                    Text("Worst").font(HLFont.caption2()).foregroundStyle(Color.hlTextTertiary)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Monthly Comparison

    private var monthlyComparison: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Monthly Comparison")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            let monthData = monthlyData()

            ForEach(monthData, id: \.month) { item in
                HStack(spacing: HLSpacing.sm) {
                    Text(item.month)
                        .font(HLFont.subheadline(.medium))
                        .foregroundStyle(Color.hlTextPrimary)
                        .frame(width: 40, alignment: .leading)

                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: HLRadius.xs)
                            .fill(habit.color.opacity(item.isCurrentMonth ? 1.0 : 0.4))
                            .frame(width: max(4, geo.size.width * item.rate))
                    }
                    .frame(height: 20)

                    Text("\(Int(item.rate * 100))%")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Streak History

    private var streakHistory: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Streak History")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            HStack(spacing: HLSpacing.xl) {
                streakStat(title: "Current", value: habit.currentStreak, icon: HLIcon.flame, color: Color.hlFlame)
                streakStat(title: "Best", value: habit.bestStreak, icon: HLIcon.trophy, color: Color.hlGold)
                streakStat(title: "Total", value: habit.totalCompletions, icon: HLIcon.star, color: Color.hlPrimary)
            }
            .frame(maxWidth: .infinity)

            Divider().overlay(Color.hlDivider)

            // Streak milestones
            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                Text("Milestones")
                    .font(HLFont.subheadline(.medium))
                    .foregroundStyle(Color.hlTextSecondary)

                ForEach(streakMilestones, id: \.days) { milestone in
                    HStack(spacing: HLSpacing.sm) {
                        Image(systemName: milestone.icon)
                            .font(HLFont.body())
                            .foregroundStyle(habit.bestStreak >= milestone.days ? Color.hlGold : Color.hlTextTertiary)
                            .frame(width: 24)

                        Text(milestone.label)
                            .font(HLFont.subheadline())
                            .foregroundStyle(habit.bestStreak >= milestone.days ? Color.hlTextPrimary : Color.hlTextTertiary)

                        Spacer()

                        if habit.bestStreak >= milestone.days {
                            Image(systemName: HLIcon.checkmark)
                                .font(HLFont.caption(.bold))
                                .foregroundStyle(Color.hlPrimary)
                        } else {
                            Text("\(milestone.days - habit.bestStreak) to go")
                                .font(HLFont.caption())
                                .foregroundStyle(Color.hlTextTertiary)
                        }
                    }
                    .padding(.vertical, HLSpacing.xxxs)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Average Completion Time

    private var averageCompletionTime: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Completion Patterns")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            let hourData = completionByHour()
            let maxHourCount = hourData.max() ?? 1

            VStack(spacing: HLSpacing.xxs) {
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0..<24, id: \.self) { hour in
                        let value = hourData[hour]
                        let normalized = maxHourCount > 0 ? CGFloat(value) / CGFloat(maxHourCount) : 0

                        RoundedRectangle(cornerRadius: 1)
                            .fill(normalized > 0 ? habit.color.opacity(0.3 + 0.7 * Double(normalized)) : Color.hlDivider)
                            .frame(height: max(4, normalized * 60))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 64)

                HStack {
                    Text("12am")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                    Spacer()
                    Text("12pm")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                    Spacer()
                    Text("11pm")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }

            if let peakHour = hourData.enumerated().max(by: { $0.element < $1.element })?.offset {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: HLIcon.clock)
                        .foregroundStyle(habit.color)
                    Text("Most active at \(formatHour(peakHour))")
                        .font(HLFont.subheadline(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                }
                .padding(.top, HLSpacing.xxs)
            }
        }
        .hlCard()
    }

    // MARK: - Helpers

    private func streakStat(title: String, value: Int, icon: String, color: Color) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            Image(systemName: icon)
                .font(HLFont.title3())
                .foregroundStyle(color)
            Text("\(value)")
                .font(HLFont.title2(.bold))
                .foregroundStyle(Color.hlTextPrimary)
            Text(title)
                .font(HLFont.caption2(.medium))
                .foregroundStyle(Color.hlTextTertiary)
        }
    }

    private var streakMilestones: [(days: Int, label: String, icon: String)] {
        [
            (7, "One Week Streak", "7.circle.fill"),
            (14, "Two Week Streak", "14.circle.fill"),
            (30, "One Month Streak", "30.circle.fill"),
            (60, "Two Month Streak", "60.circle.fill"),
            (100, "100 Day Streak", "star.circle.fill"),
            (365, "One Year Streak", "crown.fill"),
        ]
    }

    private func weeklyCompletionData() -> [Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<12).reversed().map { weekOffset in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today) else { return 0 }
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart
            let count = habit.safeCompletions.filter { c in
                let d = calendar.startOfDay(for: c.date)
                return d >= weekStart && d < weekEnd && c.isCompleted
            }.count
            return min(Double(count) / 7.0, 1.0)
        }
    }

    private func dayOfWeekStats() -> [Int] {
        let calendar = Calendar.current
        var counts = Array(repeating: 0, count: 7)
        for completion in habit.safeCompletions where completion.isCompleted {
            let weekday = calendar.component(.weekday, from: completion.date) - 1
            counts[weekday] += 1
        }
        return counts
    }

    private func monthlyData() -> [(month: String, rate: Double, isCurrentMonth: Bool)] {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        return (0..<6).reversed().map { offset in
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: today) else {
                return (month: "", rate: 0, isCurrentMonth: false)
            }
            let comps = calendar.dateComponents([.year, .month], from: monthDate)
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? 30
            let count = habit.safeCompletions.filter { c in
                let cComps = calendar.dateComponents([.year, .month], from: c.date)
                return cComps.year == comps.year && cComps.month == comps.month && c.isCompleted
            }.count
            let rate = min(Double(count) / Double(daysInMonth), 1.0)
            let isCurrent = offset == 0
            return (month: formatter.string(from: monthDate), rate: rate, isCurrentMonth: isCurrent)
        }
    }

    private func completionByHour() -> [Int] {
        let calendar = Calendar.current
        var counts = Array(repeating: 0, count: 24)
        for completion in habit.safeCompletions where completion.isCompleted {
            let hour = calendar.component(.hour, from: completion.date)
            counts[hour] += 1
        }
        return counts
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(h):00 \(period)"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitStatisticsView(habit: {
            let h = Habit(name: "Morning Meditation", icon: "brain.head.profile", colorHex: "#9966E6", category: .mindfulness)
            h.completions = (0..<60).map { i in
                HabitCompletion(
                    date: Calendar.current.date(byAdding: .day, value: -i, to: Date())!
                        .addingTimeInterval(Double.random(in: 0...43200)),
                    isCompleted: Double.random(in: 0...1) > 0.3
                )
            }
            return h
        }())
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
