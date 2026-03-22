import SwiftUI
import SwiftData

// MARK: - Display Model

private struct WeekDay: Identifiable, Equatable {
    let id: String // fullLabel used as stable identity
    let shortLabel: String
    let fullLabel: String
    let completedCount: Int
    let totalCount: Int
    let isToday: Bool
    let habitDetails: [HabitDetail]

    var completionPercent: Double {
        guard totalCount > 0 else { return 0 }
        return (Double(completedCount) / Double(totalCount)) * 100
    }

    static func == (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.id == rhs.id
    }

    struct HabitDetail: Identifiable {
        let id: UUID
        let name: String
        let icon: String
        let color: Color
        let completed: Bool
    }
}

// MARK: - Weekly Progress View

struct WeeklyProgressView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.name)
    private var habits: [Habit]

    @State private var expandedDay: String?
    @Environment(\.dismiss) private var dismiss

    // MARK: - Week Computation Helpers

    private var calendar: Calendar { Calendar.current }

    /// Returns the Monday at the start of the current week (ISO 8601: Monday-based).
    private var currentWeekMonday: Date {
        mondayOfWeek(containing: Date())
    }

    /// Returns the Monday at the start of the previous week.
    private var previousWeekMonday: Date {
        calendar.date(byAdding: .day, value: -7, to: currentWeekMonday) ?? currentWeekMonday
    }

    private func mondayOfWeek(containing date: Date) -> Date {
        let start = calendar.startOfDay(for: date)
        // weekday: 1=Sun, 2=Mon, ... 7=Sat
        let weekday = calendar.component(.weekday, from: start)
        let daysFromMonday = (weekday + 5) % 7 // Mon=0, Tue=1, ... Sun=6
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: start) ?? start
    }

    private static let dayLabels: [(short: String, full: String)] = [
        ("M", "Monday"), ("T", "Tuesday"), ("W", "Wednesday"),
        ("T", "Thursday"), ("F", "Friday"), ("S", "Saturday"), ("S", "Sunday")
    ]

    /// Maps Calendar weekday (1=Sun..7=Sat) from a Monday-offset index (0=Mon..6=Sun).
    private func calendarWeekday(forMondayOffset offset: Int) -> Int {
        // offset 0=Mon -> weekday 2, offset 6=Sun -> weekday 1
        return (offset + 1) % 7 + 1
    }

    private func buildWeekData(startingMonday monday: Date) -> [WeekDay] {
        let today = calendar.startOfDay(for: Date())
        return (0..<7).map { offset in
            let dayDate = calendar.date(byAdding: .day, value: offset, to: monday) ?? monday
            let dayStart = calendar.startOfDay(for: dayDate)
            let labels = Self.dayLabels[offset]
            let weekday = calendarWeekday(forMondayOffset: offset)
            // targetDays uses 0=Sun,1=Mon,...6=Sat  ->  convert from Calendar weekday
            let targetDayIndex = weekday - 1 // 1=Sun->0, 2=Mon->1, ... 7=Sat->6

            // Filter habits scheduled for this weekday
            let scheduledHabits = habits.filter { $0.targetDays.contains(targetDayIndex) }

            var details: [WeekDay.HabitDetail] = []
            var completedCount = 0

            for habit in scheduledHabits {
                let completed = habit.safeCompletions.contains { completion in
                    calendar.startOfDay(for: completion.date) == dayStart && completion.isCompleted
                }
                if completed { completedCount += 1 }
                details.append(
                    WeekDay.HabitDetail(
                        id: habit.id,
                        name: habit.name,
                        icon: habit.icon,
                        color: habit.color,
                        completed: completed
                    )
                )
            }

            return WeekDay(
                id: "\(labels.full)-\(dayStart.timeIntervalSince1970)",
                shortLabel: labels.short,
                fullLabel: labels.full,
                completedCount: completedCount,
                totalCount: scheduledHabits.count,
                isToday: dayStart == today,
                habitDetails: details
            )
        }
    }

    private var weeklyData: [WeekDay] {
        buildWeekData(startingMonday: currentWeekMonday)
    }

    private var previousWeekData: [WeekDay] {
        buildWeekData(startingMonday: previousWeekMonday)
    }

    private var currentWeekAverage: Double {
        let total = weeklyData.reduce(0) { $0 + $1.completionPercent }
        return weeklyData.isEmpty ? 0 : total / Double(weeklyData.count)
    }

    private var previousWeekAverage: Double {
        let total = previousWeekData.reduce(0) { $0 + $1.completionPercent }
        return previousWeekData.isEmpty ? 0 : total / Double(previousWeekData.count)
    }

    private var weekOverWeekChange: Double {
        guard previousWeekAverage > 0 else { return 0 }
        return ((currentWeekAverage - previousWeekAverage) / previousWeekAverage) * 100
    }

    private var bestDay: WeekDay? {
        weeklyData.max(by: { $0.completionPercent < $1.completionPercent })
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    weekSummaryCard
                    barChartCard
                    comparisonCard
                    dayByDaySection
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.bottom, HLSpacing.xxxl)
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .navigationTitle("Weekly Progress")
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

    // MARK: - Week Summary Card

    private var weekSummaryCard: some View {
        HStack(spacing: HLSpacing.lg) {
            statBlock(
                value: "\(Int(currentWeekAverage))%",
                label: "Average",
                color: Color.hlPrimary
            )
            Divider()
                .frame(height: 40)
            statBlock(
                value: "\(weeklyData.filter { $0.completionPercent >= 100 }.count)",
                label: "Perfect Days",
                color: Color.hlGold
            )
            Divider()
                .frame(height: 40)
            statBlock(
                value: "\(weeklyData.reduce(0) { $0 + $1.completedCount })",
                label: "Total Done",
                color: Color.hlInfo
            )
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Weekly summary: \(Int(currentWeekAverage)) percent average, \(weeklyData.filter { $0.completionPercent >= 100 }.count) perfect days, \(weeklyData.reduce(0) { $0 + $1.completedCount }) total done")
        .hlCard()
    }

    private func statBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            Text(value)
                .font(HLFont.title2())
                .foregroundStyle(color)
            Text(label)
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextTertiary)
        }
    }

    // MARK: - Bar Chart Card

    private var barChartCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Completion Rate")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            HStack(alignment: .bottom, spacing: HLSpacing.sm) {
                ForEach(weeklyData) { day in
                    VStack(spacing: HLSpacing.xxs) {
                        Text("\(Int(day.completionPercent))%")
                            .font(HLFont.caption2(.medium))
                            .foregroundStyle(day == bestDay ? Color.hlPrimary : Color.hlTextTertiary)

                        RoundedRectangle(cornerRadius: HLRadius.xs)
                            .fill(barColor(for: day))
                            .frame(height: max(8, CGFloat(day.completionPercent) / 100.0 * 120))
                            .frame(maxWidth: .infinity)

                        Text(day.shortLabel)
                            .font(HLFont.caption2(day.isToday ? .bold : .regular))
                            .foregroundStyle(day.isToday ? Color.hlPrimary : Color.hlTextTertiary)
                    }
                }
            }
            .frame(height: 160)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(completionRateChartAccessibilityLabel)

            if let best = bestDay {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: HLIcon.trophy)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.hlGold)
                    Text("Best day: \(best.fullLabel) with \(Int(best.completionPercent))% completion")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                }
                .padding(.top, HLSpacing.xxs)
            }
        }
        .hlCard()
    }

    private func barColor(for day: WeekDay) -> Color {
        if day == bestDay {
            return Color.hlGold
        } else if day.isToday {
            return Color.hlPrimary
        } else {
            return Color.hlPrimary.opacity(0.35)
        }
    }

    // MARK: - Comparison Card

    private var comparisonCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("vs. Last Week")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            HStack(spacing: HLSpacing.lg) {
                comparisonStat(
                    label: "This Week",
                    value: "\(Int(currentWeekAverage))%",
                    isCurrent: true
                )
                comparisonStat(
                    label: "Last Week",
                    value: "\(Int(previousWeekAverage))%",
                    isCurrent: false
                )

                Spacer()

                VStack(spacing: HLSpacing.xxxs) {
                    HStack(spacing: HLSpacing.xxxs) {
                        Image(systemName: weekOverWeekChange >= 0 ? HLIcon.trendUp : HLIcon.trendDown)
                            .font(.system(size: 14, weight: .bold))
                        Text("\(abs(Int(weekOverWeekChange)))%")
                            .font(HLFont.title3())
                    }
                    .foregroundStyle(weekOverWeekChange >= 0 ? Color.hlSuccess : Color.hlError)

                    Text(weekOverWeekChange >= 0 ? "improvement" : "decrease")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Week comparison: this week \(Int(currentWeekAverage)) percent, last week \(Int(previousWeekAverage)) percent, \(abs(Int(weekOverWeekChange))) percent \(weekOverWeekChange >= 0 ? "improvement" : "decrease")")
        .hlCard()
    }

    private func comparisonStat(label: String, value: String, isCurrent: Bool) -> some View {
        VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
            Text(label)
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextTertiary)
            Text(value)
                .font(HLFont.title3())
                .foregroundStyle(isCurrent ? Color.hlPrimary : Color.hlTextSecondary)
        }
    }

    // MARK: - Day by Day Section

    private var dayByDaySection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Day by Day")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            VStack(spacing: HLSpacing.xs) {
                ForEach(weeklyData) { day in
                    dayRow(day)
                }
            }
        }
    }

    private func dayRow(_ day: WeekDay) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(HLAnimation.standard) {
                    expandedDay = expandedDay == day.fullLabel ? nil : day.fullLabel
                }
            } label: {
                HStack(spacing: HLSpacing.sm) {
                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        HStack(spacing: HLSpacing.xs) {
                            Text(day.fullLabel)
                                .font(HLFont.callout(.medium))
                                .foregroundStyle(Color.hlTextPrimary)
                            if day == bestDay {
                                Text("BEST")
                                    .font(HLFont.caption2(.bold))
                                    .foregroundStyle(Color.hlGold)
                                    .padding(.horizontal, HLSpacing.xxs)
                                    .padding(.vertical, HLSpacing.xxxs)
                                    .background(
                                        Capsule().fill(Color.hlGold.opacity(0.15))
                                    )
                            }
                        }
                        Text("\(day.completedCount)/\(day.totalCount) habits")
                            .font(HLFont.caption())
                            .foregroundStyle(Color.hlTextTertiary)
                    }

                    Spacer()

                    // Comparison indicator
                    let prevDay = previousWeekData.first(where: { $0.shortLabel == day.shortLabel })
                    if let prev = prevDay {
                        let diff = day.completionPercent - prev.completionPercent
                        HStack(spacing: HLSpacing.xxxs) {
                            Image(systemName: diff >= 0 ? HLIcon.trendUp : HLIcon.trendDown)
                                .font(.system(size: 10, weight: .bold))
                            Text("\(abs(Int(diff)))%")
                                .font(HLFont.caption2(.medium))
                        }
                        .foregroundStyle(diff >= 0 ? Color.hlSuccess : Color.hlError)
                    }

                    Text("\(Int(day.completionPercent))%")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlPrimary)
                        .frame(width: 50, alignment: .trailing)

                    Image(systemName: expandedDay == day.fullLabel ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }

            if expandedDay == day.fullLabel {
                VStack(spacing: HLSpacing.xs) {
                    Divider()
                        .padding(.vertical, HLSpacing.xs)

                    ForEach(day.habitDetails) { detail in
                        HStack(spacing: HLSpacing.xs) {
                            Image(systemName: detail.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(detail.color)
                                .frame(width: 24)
                            Text(detail.name)
                                .font(HLFont.footnote())
                                .foregroundStyle(Color.hlTextPrimary)
                            Spacer()
                            Image(systemName: detail.completed ? "checkmark.circle.fill" : "xmark.circle")
                                .font(.system(size: 16))
                                .foregroundStyle(detail.completed ? Color.hlSuccess : Color.hlTextTertiary)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .hlCard()
    }

    // MARK: - Accessibility Helpers

    private var completionRateChartAccessibilityLabel: String {
        let descriptions = weeklyData.map { "\($0.fullLabel) \(Int($0.completionPercent))%" }
        let bestText = bestDay.map { "Best day: \($0.fullLabel) at \(Int($0.completionPercent))%" } ?? ""
        return "Completion rate chart. \(descriptions.joined(separator: ", ")). \(bestText)"
    }
}

// MARK: - Preview

#Preview {
    WeeklyProgressView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
