import SwiftUI
import SwiftData

struct SleepAnalyticsView: View {
    @Query(sort: \SleepLog.wakeTime, order: .reverse) private var allLogs: [SleepLog]

    private var last30Days: [SleepLog] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return allLogs.filter { $0.wakeTime >= cutoff }
    }

    private var avgDuration: Double {
        guard !last30Days.isEmpty else { return 0 }
        return last30Days.map(\.durationHours).reduce(0, +) / Double(last30Days.count)
    }

    private var avgQuality: Double {
        guard !last30Days.isEmpty else { return 0 }
        return last30Days.map(\.quality.value).reduce(0, +) / Double(last30Days.count)
    }

    private var bestSleepDay: SleepLog? {
        last30Days.max(by: { $0.durationHours < $1.durationHours })
    }

    private var worstSleepDay: SleepLog? {
        last30Days.min(by: { $0.durationHours < $1.durationHours })
    }

    private var sleepDebt: Double {
        let goal: Double = 8.0
        let totalDeficit = last30Days.map { max(0, goal - $0.durationHours) }.reduce(0, +)
        return totalDeficit
    }

    private var avgTimeInBed: Double {
        guard !last30Days.isEmpty else { return 0 }
        return last30Days.map(\.durationHours).reduce(0, +) / Double(last30Days.count)
    }

    private var avgTimeAsleep: Double {
        // Estimate ~90% efficiency
        avgTimeInBed * 0.9
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                durationChartCard
                qualityTrendCard
                bestWorstCard
                avgByDayOfWeekCard
                sleepDebtCard
                timeBreakdownCard
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .refreshable {
            try? await Task.sleep(for: .milliseconds(300))
        }
        .background(Color.hlBackground)
        .navigationTitle("Sleep Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 30-Day Duration Chart

    @ViewBuilder
    private var durationChartCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("30-Day Sleep Duration")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            Text(String(format: "Avg %.1fh per night", avgDuration))
                .font(HLFont.footnote())
                .foregroundStyle(Color.hlTextSecondary)

            let dataPoints = durationDataPoints()
            GeometryReader { geo in
                let maxH: Double = 12
                let spacing: CGFloat = 1
                let barW = max(2, (geo.size.width - CGFloat(dataPoints.count - 1) * spacing) / CGFloat(dataPoints.count))

                ZStack(alignment: .bottom) {
                    // Goal line at 8h
                    let goalY = CGFloat(8.0 / maxH) * 100
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 100 - goalY))
                        p.addLine(to: CGPoint(x: geo.size.width, y: 100 - goalY))
                    }
                    .stroke(Color.hlWarning.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(Array(dataPoints.enumerated()), id: \.offset) { _, hours in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(hours >= 8 ? Color.hlSleep : Color.hlSleep.opacity(0.35))
                                .frame(width: barW, height: max(2, CGFloat(hours / maxH) * 100))
                        }
                    }
                }
            }
            .frame(height: 110)
        }
        .hlCard()
    }

    // MARK: - Quality Trend

    @ViewBuilder
    private var qualityTrendCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("Quality Trend")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Spacer()
                Text(String(format: "%.0f%%", avgQuality * 100))
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlSleep)
            }

            let qualityPoints = last30Days.reversed().map(\.quality.value)
            if qualityPoints.count > 1 {
                GeometryReader { geo in
                    let stepX = geo.size.width / CGFloat(qualityPoints.count - 1)
                    Path { path in
                        for (index, val) in qualityPoints.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = (1.0 - val) * Double(geo.size.height)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.hlSleep, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                .frame(height: 80)
            } else {
                Text("Need more data to show trend")
                    .font(HLFont.footnote())
                    .foregroundStyle(Color.hlTextTertiary)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
            }
        }
        .hlCard()
    }

    // MARK: - Best / Worst

    @ViewBuilder
    private var bestWorstCard: some View {
        HStack(spacing: HLSpacing.sm) {
            VStack(spacing: HLSpacing.xs) {
                Image(systemName: HLIcon.trendUp)
                    .font(HLFont.title3())
                    .foregroundStyle(Color.hlPrimary)
                Text("Best Night")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
                if let best = bestSleepDay {
                    Text(best.durationFormatted)
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                    Text(best.wakeTime, format: .dateTime.month(.abbreviated).day())
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                } else {
                    Text("--")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .hlCard()

            VStack(spacing: HLSpacing.xs) {
                Image(systemName: HLIcon.trendDown)
                    .font(HLFont.title3())
                    .foregroundStyle(Color.hlError)
                Text("Worst Night")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
                if let worst = worstSleepDay {
                    Text(worst.durationFormatted)
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                    Text(worst.wakeTime, format: .dateTime.month(.abbreviated).day())
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                } else {
                    Text("--")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .hlCard()
        }
    }

    // MARK: - Average by Day of Week

    @ViewBuilder
    private var avgByDayOfWeekCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Average by Day of Week")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            let dayAverages = averageByDayOfWeek()
            let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

            HStack(alignment: .bottom, spacing: HLSpacing.xs) {
                ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                    VStack(spacing: HLSpacing.xxs) {
                        Text(String(format: "%.1f", dayAverages[index]))
                            .font(HLFont.caption2(.semibold))
                            .foregroundStyle(Color.hlTextSecondary)

                        RoundedRectangle(cornerRadius: HLRadius.xs)
                            .fill(Color.hlSleep.opacity(dayAverages[index] > 0 ? 0.3 + (dayAverages[index] / 12.0) * 0.7 : 0.15))
                            .frame(height: max(8, CGFloat(dayAverages[index] / 12.0) * 80))

                        Text(label)
                            .font(HLFont.caption2(.medium))
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
        }
        .hlCard()
    }

    // MARK: - Sleep Debt

    @ViewBuilder
    private var sleepDebtCard: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack {
                Image(systemName: HLIcon.zzz)
                    .font(HLFont.title3())
                    .foregroundStyle(sleepDebt > 10 ? Color.hlError : Color.hlWarning)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("Sleep Debt")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                    Text("Hours below 8h goal in the last 30 days")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary)
                }

                Spacer()

                Text(String(format: "%.1fh", sleepDebt))
                    .font(HLFont.title2())
                    .foregroundStyle(sleepDebt > 10 ? Color.hlError : Color.hlWarning)
            }
        }
        .hlCard()
    }

    // MARK: - Time Breakdown

    @ViewBuilder
    private var timeBreakdownCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Time in Bed vs Asleep")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            HStack(spacing: HLSpacing.lg) {
                VStack(spacing: HLSpacing.xxs) {
                    Text(String(format: "%.1fh", avgTimeInBed))
                        .font(HLFont.title2())
                        .foregroundStyle(Color.hlSleep.opacity(0.5))
                    Text("In Bed")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: HLSpacing.xxs) {
                    Text(String(format: "%.1fh", avgTimeAsleep))
                        .font(HLFont.title2())
                        .foregroundStyle(Color.hlSleep)
                    Text("Asleep")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: HLSpacing.xxs) {
                    Text(String(format: "%.0f%%", avgTimeInBed > 0 ? (avgTimeAsleep / avgTimeInBed) * 100 : 0))
                        .font(HLFont.title2())
                        .foregroundStyle(Color.hlPrimary)
                    Text("Efficiency")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                }
                .frame(maxWidth: .infinity)
            }

            // Stacked bar
            GeometryReader { geo in
                let efficiency = avgTimeInBed > 0 ? avgTimeAsleep / avgTimeInBed : 0.9
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: HLRadius.sm)
                        .fill(Color.hlSleep.opacity(0.2))
                        .frame(width: geo.size.width)

                    RoundedRectangle(cornerRadius: HLRadius.sm)
                        .fill(Color.hlSleep)
                        .frame(width: geo.size.width * efficiency)
                }
            }
            .frame(height: 12)
        }
        .hlCard()
    }

    // MARK: - Helpers

    private func durationDataPoints() -> [Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var points: [Double] = []

        for dayOffset in (0..<30).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                points.append(0)
                continue
            }
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            if let log = allLogs.first(where: {
                let wake = calendar.startOfDay(for: $0.wakeTime)
                return wake >= day && wake < nextDay
            }) {
                points.append(log.durationHours)
            } else {
                points.append(0)
            }
        }
        return points
    }

    private func averageByDayOfWeek() -> [Double] {
        // Returns Mon-Sun averages
        let calendar = Calendar.current
        var sums = Array(repeating: 0.0, count: 7)
        var counts = Array(repeating: 0, count: 7)

        for log in last30Days {
            let weekday = calendar.component(.weekday, from: log.wakeTime) // 1=Sun
            let index = (weekday + 5) % 7 // Convert to Mon=0
            sums[index] += log.durationHours
            counts[index] += 1
        }

        return (0..<7).map { i in
            counts[i] > 0 ? sums[i] / Double(counts[i]) : 0
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SleepAnalyticsView()
    }
    .modelContainer(for: SleepLog.self, inMemory: true)
}
