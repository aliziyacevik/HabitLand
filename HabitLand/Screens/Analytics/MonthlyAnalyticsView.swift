import SwiftUI
import SwiftData

// MARK: - Monthly Analytics View

struct MonthlyAnalyticsView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }) private var habits: [Habit]
    @State private var animateBars = false

    private var calendar: Calendar { Calendar.current }

    private var today: Date { calendar.startOfDay(for: Date()) }

    // Current month range
    private var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
    }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: monthStart)!.count
    }

    private var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: monthStart)
    }

    private var firstWeekday: Int {
        // 0=Sun based offset for calendar grid
        (calendar.component(.weekday, from: monthStart) - 1) // 0=Sun, 1=Mon...6=Sat
    }

    // Previous month range
    private var previousMonthStart: Date {
        calendar.date(byAdding: .month, value: -1, to: monthStart)!
    }

    private var previousMonthName: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM"
        return fmt.string(from: previousMonthStart)
    }

    // Day data: rate for each day of current month
    private var monthDayRates: [(day: Int, rate: Double)] {
        (1...daysInMonth).map { dayNum in
            var comps = calendar.dateComponents([.year, .month], from: monthStart)
            comps.day = dayNum
            let date = calendar.date(from: comps)!
            let dayStart = calendar.startOfDay(for: date)

            guard dayStart <= today else {
                return (dayNum, -1) // future
            }

            let activeHabits = habits.filter { habit in
                let weekdayIndex = calendar.component(.weekday, from: date) - 1
                return habit.targetDays.contains(weekdayIndex) && habit.createdAt <= date
            }
            let total = activeHabits.count
            guard total > 0 else { return (dayNum, 0) }

            let completed = activeHabits.filter { habit in
                habit.completions.contains { c in
                    calendar.startOfDay(for: c.date) == dayStart && c.isCompleted
                }
            }.count
            return (dayNum, Double(completed) / Double(total))
        }
    }

    private var trackedDays: [(day: Int, rate: Double)] {
        monthDayRates.filter { $0.rate >= 0 }
    }

    private var daysTracked: Int { trackedDays.count }

    private var monthlyRate: Double {
        guard !trackedDays.isEmpty else { return 0 }
        return trackedDays.reduce(0.0) { $0 + $1.rate } / Double(trackedDays.count)
    }

    private func rateForPeriod(start: Date, days: Int) -> Double {
        var totalRate = 0.0
        var count = 0
        for offset in 0..<days {
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            let dayStart = calendar.startOfDay(for: day)
            guard dayStart <= today else { continue }

            let activeHabits = habits.filter { habit in
                let weekdayIndex = calendar.component(.weekday, from: day) - 1
                return habit.targetDays.contains(weekdayIndex) && habit.createdAt <= day
            }
            let total = activeHabits.count
            guard total > 0 else { continue }
            let completed = activeHabits.filter { habit in
                habit.completions.contains { c in
                    calendar.startOfDay(for: c.date) == dayStart && c.isCompleted
                }
            }.count
            totalRate += Double(completed) / Double(total)
            count += 1
        }
        guard count > 0 else { return 0 }
        return totalRate / Double(count)
    }

    private var lastMonthRate: Double {
        let prevDays = calendar.range(of: .day, in: .month, for: previousMonthStart)!.count
        return rateForPeriod(start: previousMonthStart, days: prevDays)
    }

    private var monthChange: Double {
        monthlyRate - lastMonthRate
    }

    // Week-by-week trend for current month
    private var weekTrends: [(label: String, rate: Double)] {
        var trends: [(String, Double)] = []
        var weekNum = 1
        var offset = 0
        while offset < daysInMonth {
            let daysInWeek = min(7, daysInMonth - offset)
            let weekStart = calendar.date(byAdding: .day, value: offset, to: monthStart)!
            let rate = rateForPeriod(start: weekStart, days: daysInWeek)
            // Only include weeks that have at least some tracked data
            let weekEnd = calendar.date(byAdding: .day, value: daysInWeek - 1, to: weekStart)!
            if calendar.startOfDay(for: weekStart) <= today {
                trends.append(("Wk \(weekNum)", rate))
            }
            weekNum += 1
            offset += 7
        }
        return trends
    }

    // Category breakdown
    private var categoryBreakdown: [(name: String, rate: Double, color: Color, icon: String)] {
        var result: [(String, Double, Color, String)] = []
        for category in HabitCategory.allCases {
            let categoryHabits = habits.filter { $0.category == category }
            guard !categoryHabits.isEmpty else { continue }

            var totalRate = 0.0
            var count = 0
            for habit in categoryHabits {
                // Compute this month's rate for this habit
                var scheduled = 0
                var completed = 0
                for dayOffset in 0..<daysInMonth {
                    let day = calendar.date(byAdding: .day, value: dayOffset, to: monthStart)!
                    let dayStart = calendar.startOfDay(for: day)
                    guard dayStart <= today, habit.createdAt <= day else { continue }
                    let weekdayIndex = calendar.component(.weekday, from: day) - 1
                    guard habit.targetDays.contains(weekdayIndex) else { continue }
                    scheduled += 1
                    if habit.completions.contains(where: { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted }) {
                        completed += 1
                    }
                }
                if scheduled > 0 {
                    totalRate += Double(completed) / Double(scheduled)
                    count += 1
                }
            }
            guard count > 0 else { continue }
            result.append((category.rawValue, totalRate / Double(count), category.color, category.icon))
        }
        return result.sorted { $0.1 > $1.1 }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: HLSpacing.lg) {
                if habits.isEmpty {
                    emptyState
                } else {
                    headerSection
                    monthlyRateCard
                    calendarHeatmapCard
                    if !weekTrends.isEmpty {
                        weekTrendCard
                    }
                    if !categoryBreakdown.isEmpty {
                        categoryBreakdownCard
                    }
                    if lastMonthRate > 0 || monthlyRate > 0 {
                        monthComparisonCard
                    }
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xxxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Monthly Analytics")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(HLAnimation.slow.delay(0.15)) {
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

            Text("Create habits to see your\nmonthly analytics here.")
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
                Text(monthTitle)
                    .font(HLFont.title2())
                    .foregroundColor(.hlTextPrimary)
                Text("\(daysTracked) days tracked so far")
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

    // MARK: - Monthly Rate

    private var monthlyRateCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text("Monthly Completion")
                    .font(HLFont.footnote(.medium))
                    .foregroundColor(.hlTextSecondary)
                Text("\(Int(monthlyRate * 100))%")
                    .font(HLFont.largeTitle())
                    .foregroundColor(.hlTextPrimary)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.hlDivider, lineWidth: 8)
                    .frame(width: 72, height: 72)
                Circle()
                    .trim(from: 0, to: monthlyRate)
                    .stroke(Color.hlPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))
                Image(systemName: HLIcon.chart)
                    .foregroundColor(.hlPrimary)
            }
        }
        .hlCard()
    }

    // MARK: - Calendar Heatmap

    private var calendarHeatmapCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Daily Heatmap")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
            HStack(spacing: HLSpacing.xxs) {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekdays[i])
                        .font(HLFont.caption2(.medium))
                        .foregroundColor(.hlTextTertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            let startOffset = firstWeekday
            let totalCells = startOffset + daysInMonth
            let rows = (totalCells + 6) / 7

            VStack(spacing: HLSpacing.xxs) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: HLSpacing.xxs) {
                        ForEach(0..<7, id: \.self) { col in
                            let cellIndex = row * 7 + col
                            let dayIndex = cellIndex - startOffset
                            if dayIndex >= 0, dayIndex < monthDayRates.count {
                                let dayData = monthDayRates[dayIndex]
                                heatmapCircle(day: dayData.day, rate: dayData.rate)
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 32, height: 32)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: HLSpacing.md) {
                Spacer()
                legendDot(color: Color.hlTextTertiary.opacity(0.3), label: "Future")
                legendDot(color: .hlError.opacity(0.6), label: "Missed")
                legendDot(color: .hlWarning, label: "Partial")
                legendDot(color: .hlPrimary, label: "Complete")
            }
            .padding(.top, HLSpacing.xxs)
        }
        .hlCard()
    }

    private func heatmapCircle(day: Int, rate: Double) -> some View {
        ZStack {
            Circle()
                .fill(heatmapColor(for: rate))
                .frame(width: 32, height: 32)

            if rate >= 0 {
                Text("\(day)")
                    .font(HLFont.caption2(.semibold))
                    .foregroundColor(rate >= 0.7 ? .white : .hlTextPrimary)
            } else {
                Text("\(day)")
                    .font(HLFont.caption2())
                    .foregroundColor(.hlTextTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func heatmapColor(for rate: Double) -> Color {
        if rate < 0 { return Color.hlTextTertiary.opacity(0.12) }
        if rate >= 0.8 { return .hlPrimary }
        if rate >= 0.5 { return .hlWarning.opacity(0.8) }
        return .hlError.opacity(0.6)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: HLSpacing.xxxs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(HLFont.caption2())
                .foregroundColor(.hlTextTertiary)
        }
    }

    // MARK: - Week Trend

    private var weekTrendCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Week-by-Week Trend")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            HStack(alignment: .bottom, spacing: HLSpacing.md) {
                ForEach(Array(weekTrends.enumerated()), id: \.offset) { _, week in
                    VStack(spacing: HLSpacing.xs) {
                        Text("\(Int(week.rate * 100))%")
                            .font(HLFont.footnote(.semibold))
                            .foregroundColor(.hlTextSecondary)

                        RoundedRectangle(cornerRadius: HLRadius.sm)
                            .fill(
                                LinearGradient(
                                    colors: [.hlPrimary, .hlPrimaryDark],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: animateBars ? max(24, week.rate * 100) : 0)

                        Text(week.label)
                            .font(HLFont.caption(.medium))
                            .foregroundColor(.hlTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
        }
        .hlCard()
    }

    // MARK: - Category Breakdown

    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Habit Breakdown")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(Array(categoryBreakdown.enumerated()), id: \.offset) { _, category in
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: category.icon)
                        .font(.callout)
                        .foregroundColor(category.color)
                        .frame(width: 24)

                    Text(category.name)
                        .font(HLFont.subheadline())
                        .foregroundColor(.hlTextPrimary)
                        .frame(width: 90, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.hlDivider)
                                .frame(height: 10)
                            Capsule()
                                .fill(category.color)
                                .frame(width: animateBars ? geo.size.width * category.rate : 0, height: 10)
                        }
                    }
                    .frame(height: 10)

                    Text("\(Int(category.rate * 100))%")
                        .font(HLFont.footnote(.semibold))
                        .foregroundColor(.hlTextSecondary)
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Month Comparison

    private var monthComparisonCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text("vs \(previousMonthName)")
                    .font(HLFont.footnote(.medium))
                    .foregroundColor(.hlTextSecondary)

                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: monthChange >= 0 ? HLIcon.trendUp : HLIcon.trendDown)
                        .foregroundColor(monthChange >= 0 ? .hlSuccess : .hlError)
                    Text("\(monthChange >= 0 ? "+" : "")\(Int(monthChange * 100))%")
                        .font(HLFont.title2())
                        .foregroundColor(monthChange >= 0 ? .hlSuccess : .hlError)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: HLSpacing.xxs) {
                Text(previousMonthName)
                    .font(HLFont.footnote(.medium))
                    .foregroundColor(.hlTextSecondary)
                Text("\(Int(lastMonthRate * 100))%")
                    .font(HLFont.title3())
                    .foregroundColor(.hlTextPrimary)
            }
        }
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MonthlyAnalyticsView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
