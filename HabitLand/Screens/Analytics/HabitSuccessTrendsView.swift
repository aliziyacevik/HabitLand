import SwiftUI
import SwiftData

// MARK: - Trend Point

private struct TrendPoint: Identifiable {
    let id = UUID()
    let dayOffset: Int // 0 = 90 days ago, 89 = today
    let rate: Double
}

// MARK: - Trends View

struct HabitSuccessTrendsView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }) private var habits: [Habit]
    @State private var selectedHabitIndex: Int? = nil
    @State private var animateChart = false

    private var calendar: Calendar { Calendar.current }
    private var today: Date { calendar.startOfDay(for: Date()) }

    private var ninetyDaysAgo: Date {
        calendar.date(byAdding: .day, value: -89, to: today)!
    }

    private var dateRange: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return "\(fmt.string(from: ninetyDaysAgo)) - \(fmt.string(from: today))"
    }

    // Compute daily completion rate for last 90 days
    private func dailyRate(for day: Date, habits: [Habit]) -> Double {
        let dayStart = calendar.startOfDay(for: day)
        let active = habits.filter { habit in
            let wd = calendar.component(.weekday, from: day) - 1
            return habit.targetDays.contains(wd) && habit.createdAt <= day
        }
        guard !active.isEmpty else { return 0 }
        let completed = active.filter { habit in
            habit.safeCompletions.contains { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted }
        }.count
        return Double(completed) / Double(active.count)
    }

    private var overallTrend: [TrendPoint] {
        (0..<90).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: ninetyDaysAgo)!
            return TrendPoint(dayOffset: offset, rate: dailyRate(for: day, habits: habits))
        }
    }

    // Per-habit trends (top 3 by activity)
    private var habitTrends: [(name: String, color: Color, points: [TrendPoint])] {
        let sorted = habits.sorted { $0.totalCompletions > $1.totalCompletions }
        return Array(sorted.prefix(3)).map { habit in
            let points: [TrendPoint] = (0..<90).map { offset in
                let day = calendar.date(byAdding: .day, value: offset, to: ninetyDaysAgo)!
                let dayStart = calendar.startOfDay(for: day)
                let wd = calendar.component(.weekday, from: day) - 1
                guard habit.targetDays.contains(wd), habit.createdAt <= day else {
                    return TrendPoint(dayOffset: offset, rate: 0)
                }
                let completed = habit.safeCompletions.contains { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted }
                return TrendPoint(dayOffset: offset, rate: completed ? 1.0 : 0.0)
            }
            // Smooth with 7-day moving average
            let smoothed = computeMovingAverage(points: points, window: 7)
            return (habit.name, habit.color, smoothed)
        }
    }

    private var totalCompletions: Int {
        let start = ninetyDaysAgo
        return habits.reduce(0) { total, habit in
            total + habit.safeCompletions.filter { $0.isCompleted && $0.date >= start }.count
        }
    }

    private var avgRate: Double {
        let rates = overallTrend.map(\.rate)
        guard !rates.isEmpty else { return 0 }
        return rates.reduce(0, +) / Double(rates.count)
    }

    private var consistencyScore: Int {
        // Score based on how many days had >50% completion
        let goodDays = overallTrend.filter { $0.rate >= 0.5 }.count
        return Int(Double(goodDays) / 90.0 * 100)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: HLSpacing.lg) {
                if habits.isEmpty {
                    emptyState
                } else {
                    headerSection
                    keyMetricsRow
                    overallTrendCard
                    if !habitTrends.isEmpty {
                        perHabitTrendCard
                    }
                    movingAverageCard
                    projectionCard
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xxxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Success Trends")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(HLAnimation.slow) {
                animateChart = true
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
                Image(systemName: HLIcon.lineChart)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.hlPrimary.opacity(0.5))
            }
            Text("No trends yet")
                .font(HLFont.title3(.semibold))
                .foregroundStyle(Color.hlTextPrimary)
            Text("Complete habits over time\nto see success trends.")
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
                Text("Last 90 Days")
                    .font(HLFont.title2())
                    .foregroundColor(.hlTextPrimary)
                Text(dateRange)
                    .font(HLFont.subheadline())
                    .foregroundColor(.hlTextSecondary)
            }
            Spacer()
            Image(systemName: HLIcon.lineChart)
                .font(.title2)
                .foregroundColor(.hlPrimary)
        }
        .padding(.top, HLSpacing.xs)
    }

    // MARK: - Key Metrics

    private var keyMetricsRow: some View {
        HStack(spacing: HLSpacing.sm) {
            metricCard(title: "Total", value: "\(totalCompletions)", subtitle: "completions", icon: HLIcon.checkmark, color: .hlPrimary)
            metricCard(title: "Avg Rate", value: "\(Int(avgRate * 100))%", subtitle: "daily", icon: HLIcon.chart, color: .hlInfo)
            metricCard(title: "Consistency", value: "\(consistencyScore)", subtitle: "score", icon: HLIcon.bolt, color: .hlFlame)
        }
    }

    private func metricCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(spacing: HLSpacing.xs) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundColor(color)

            Text(value)
                .font(HLFont.title3())
                .foregroundColor(.hlTextPrimary)

            Text(subtitle)
                .font(HLFont.caption2())
                .foregroundColor(.hlTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .hlCard(padding: HLSpacing.sm)
    }

    // MARK: - Overall Trend Line Chart

    private var overallTrendCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Overall Success Rate")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            lineChart(points: overallTrend, color: .hlPrimary, showFill: true)
                .frame(height: 180)

            HStack {
                Text("90 days ago")
                    .font(HLFont.caption2())
                    .foregroundColor(.hlTextTertiary)
                Spacer()
                Text("Today")
                    .font(HLFont.caption2())
                    .foregroundColor(.hlTextTertiary)
            }
        }
        .hlCard()
    }

    // MARK: - Per-Habit Trends

    private var perHabitTrendCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Per-Habit Trends")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ZStack {
                ForEach(Array(habitTrends.enumerated()), id: \.offset) { index, trend in
                    lineChart(points: trend.points, color: trend.color, showFill: false, lineWidth: 2)
                        .opacity(selectedHabitIndex == nil || selectedHabitIndex == index ? 1.0 : 0.2)
                }
            }
            .frame(height: 160)

            HStack(spacing: HLSpacing.md) {
                ForEach(Array(habitTrends.enumerated()), id: \.offset) { index, trend in
                    Button {
                        withAnimation(HLAnimation.quick) {
                            selectedHabitIndex = selectedHabitIndex == index ? nil : index
                        }
                    } label: {
                        HStack(spacing: HLSpacing.xxxs) {
                            Circle()
                                .fill(trend.color)
                                .frame(width: 8, height: 8)
                            Text(trend.name)
                                .font(HLFont.caption(.medium))
                                .foregroundColor(
                                    selectedHabitIndex == nil || selectedHabitIndex == index
                                    ? .hlTextPrimary : .hlTextTertiary
                                )
                        }
                    }
                }
            }
        }
        .hlCard()
    }

    // MARK: - Moving Average

    private var movingAverageCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("7-Day Moving Average")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                Spacer()
                Text("Smoothed")
                    .font(HLFont.caption(.medium))
                    .foregroundColor(.hlTextTertiary)
            }

            let movingAvg = computeMovingAverage(points: overallTrend, window: 7)
            ZStack {
                lineChart(points: overallTrend, color: .hlPrimary.opacity(0.25), showFill: false, lineWidth: 1)
                lineChart(points: movingAvg, color: .hlPrimary, showFill: false, lineWidth: 3)
            }
            .frame(height: 160)

            HStack(spacing: HLSpacing.md) {
                Spacer()
                HStack(spacing: HLSpacing.xxxs) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.hlPrimary.opacity(0.25))
                        .frame(width: 16, height: 2)
                    Text("Daily")
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }
                HStack(spacing: HLSpacing.xxxs) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.hlPrimary)
                        .frame(width: 16, height: 3)
                    Text("7-Day Avg")
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Projection

    private var projectionCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("30-Day Projection")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                Spacer()
                Image(systemName: HLIcon.sparkles)
                    .foregroundColor(.hlGold)
            }

            let recent = Array(overallTrend.suffix(30))
            let projected = generateProjection(from: recent, days: 30)

            ZStack {
                lineChart(points: recent.map { TrendPoint(dayOffset: $0.dayOffset - 60, rate: $0.rate) },
                          color: .hlPrimary, showFill: false, lineWidth: 2.5,
                          totalDayRange: 60)
                projectedLineChart(points: projected, color: .hlPrimary, totalDayRange: 60)
            }
            .frame(height: 160)

            HStack(spacing: HLSpacing.md) {
                Spacer()
                HStack(spacing: HLSpacing.xxxs) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.hlPrimary)
                        .frame(width: 16, height: 2.5)
                    Text("Actual")
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }
                HStack(spacing: HLSpacing.xxxs) {
                    dashedLine()
                        .frame(width: 16, height: 2)
                    Text("Projected")
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }
            }

            Text("Projected rate in 30 days: ~\(Int(min(projected.last?.rate ?? 0, 1.0) * 100))%")
                .font(HLFont.footnote(.medium))
                .foregroundColor(.hlTextSecondary)
        }
        .hlCard()
    }

    // MARK: - Chart Helpers

    private func lineChart(
        points: [TrendPoint],
        color: Color,
        showFill: Bool,
        lineWidth: CGFloat = 2.5,
        totalDayRange: Int? = nil
    ) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let dayRange = totalDayRange ?? 90

            let path = Path { path in
                guard points.count > 1 else { return }
                for (i, pt) in points.enumerated() {
                    let x = (CGFloat(pt.dayOffset) / CGFloat(dayRange)) * w
                    let y = h - (pt.rate * h * 0.85) - h * 0.05
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }

            if showFill, let first = points.first, let last = points.last {
                let fillPath = Path { fp in
                    for (i, pt) in points.enumerated() {
                        let x = (CGFloat(pt.dayOffset) / CGFloat(dayRange)) * w
                        let y = h - (pt.rate * h * 0.85) - h * 0.05
                        if i == 0 {
                            fp.move(to: CGPoint(x: x, y: y))
                        } else {
                            fp.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    let lastX = (CGFloat(last.dayOffset) / CGFloat(dayRange)) * w
                    let firstX = (CGFloat(first.dayOffset) / CGFloat(dayRange)) * w
                    fp.addLine(to: CGPoint(x: lastX, y: h))
                    fp.addLine(to: CGPoint(x: firstX, y: h))
                    fp.closeSubpath()
                }
                fillPath
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            path
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .opacity(animateChart ? 1 : 0)
        }
    }

    private func projectedLineChart(points: [TrendPoint], color: Color, totalDayRange: Int) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            Path { path in
                guard points.count > 1 else { return }
                for (i, pt) in points.enumerated() {
                    let x = (CGFloat(pt.dayOffset) / CGFloat(totalDayRange)) * w
                    let y = h - (pt.rate * h * 0.85) - h * 0.05
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color.opacity(0.6), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [6, 4]))
            .opacity(animateChart ? 1 : 0)
        }
    }

    private func dashedLine() -> some View {
        Path { path in
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 16, y: 0))
        }
        .stroke(Color.hlPrimary.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [3, 2]))
    }

    private func computeMovingAverage(points: [TrendPoint], window: Int) -> [TrendPoint] {
        guard points.count >= window else { return points }
        var result: [TrendPoint] = []
        for i in (window - 1)..<points.count {
            let slice = points[(i - window + 1)...i]
            let avg = slice.map(\.rate).reduce(0, +) / Double(window)
            result.append(TrendPoint(dayOffset: points[i].dayOffset, rate: avg))
        }
        return result
    }

    private func generateProjection(from recent: [TrendPoint], days: Int) -> [TrendPoint] {
        guard recent.count >= 2 else { return [] }
        let n = recent.count
        let xMean = Double(n - 1) / 2.0
        let yMean = recent.map(\.rate).reduce(0, +) / Double(n)
        var num = 0.0
        var den = 0.0
        for (i, pt) in recent.enumerated() {
            let xi = Double(i)
            num += (xi - xMean) * (pt.rate - yMean)
            den += (xi - xMean) * (xi - xMean)
        }
        let slope = den > 0 ? num / den : 0
        let intercept = yMean - slope * xMean
        guard let lastRate = recent.last?.rate else { return [] }

        var result: [TrendPoint] = []
        for d in 0..<days {
            let projected = intercept + slope * Double(n + d)
            let clamped = min(1.0, max(0.0, projected))
            result.append(TrendPoint(dayOffset: 30 + d, rate: clamped))
        }
        if let first = result.first {
            result[0] = TrendPoint(dayOffset: first.dayOffset, rate: lastRate)
        }
        return result
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitSuccessTrendsView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
