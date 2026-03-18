import SwiftUI
import SwiftData

struct SleepDashboardView: View {
    @Query(sort: \SleepLog.wakeTime, order: .reverse) private var sleepLogs: [SleepLog]
    @State private var showLogSleep = false
    @State private var showAnalytics = false
    @State private var showHistory = false
    @State private var showInsights = false

    private var lastNight: SleepLog? { sleepLogs.first }

    private var weekLogs: [SleepLog] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: Date()))!
        return sleepLogs.filter { $0.wakeTime >= weekAgo }
    }

    private var averageDuration: Double {
        guard !weekLogs.isEmpty else { return 0 }
        return weekLogs.map(\.durationHours).reduce(0, +) / Double(weekLogs.count)
    }

    private var averageQuality: Double {
        guard !weekLogs.isEmpty else { return 0 }
        return weekLogs.map(\.quality.value).reduce(0, +) / Double(weekLogs.count)
    }

    private var consistencyPercent: Int {
        Int((Double(weekLogs.count) / 7.0) * 100)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HLSpacing.md) {
                    lastNightCard
                        .hlStaggeredAppear(index: 0)
                    weeklyChartCard
                        .hlStaggeredAppear(index: 1)
                    averageStatsRow
                        .hlStaggeredAppear(index: 2)
                    insightsCard
                        .hlStaggeredAppear(index: 3)
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.bottom, HLSpacing.xl)
            }
            .background(Color.hlBackground)
            .navigationTitle("Sleep")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: HLIcon.clock)
                            .foregroundStyle(Color.hlTextSecondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAnalytics = true
                    } label: {
                        Image(systemName: HLIcon.lineChart)
                            .foregroundStyle(Color.hlTextSecondary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    showLogSleep = true
                } label: {
                    Label("Log Sleep", systemImage: HLIcon.moon)
                        .font(HLFont.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HLSpacing.sm)
                        .background(Color.hlSleep, in: RoundedRectangle(cornerRadius: HLRadius.lg))
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.bottom, HLSpacing.xs)
                .background(Color.hlBackground)
            }
            .sheet(isPresented: $showLogSleep) {
                LogSleepView()
            }
            .navigationDestination(isPresented: $showAnalytics) {
                SleepAnalyticsView()
            }
            .navigationDestination(isPresented: $showHistory) {
                SleepHistoryView()
            }
            .navigationDestination(isPresented: $showInsights) {
                SleepInsightsView()
            }
        }
    }

    // MARK: - Last Night Card

    @ViewBuilder
    private var lastNightCard: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack {
                Text("Last Night")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Spacer()
                if let log = lastNight {
                    Text(log.quality.icon)
                        .font(.title)
                }
            }

            if let log = lastNight {
                Text(log.durationFormatted)
                    .font(HLFont.largeTitle(.bold))
                    .foregroundStyle(Color.hlSleep)

                HStack(spacing: HLSpacing.lg) {
                    Label {
                        Text(log.bedTime, style: .time)
                            .font(HLFont.subheadline(.medium))
                            .foregroundStyle(Color.hlTextPrimary)
                    } icon: {
                        Image(systemName: HLIcon.bed)
                            .foregroundStyle(Color.hlSleep)
                    }

                    Label {
                        Text(log.wakeTime, style: .time)
                            .font(HLFont.subheadline(.medium))
                            .foregroundStyle(Color.hlTextPrimary)
                    } icon: {
                        Image(systemName: HLIcon.sunrise)
                            .foregroundStyle(Color.hlFlame)
                    }
                }
            } else {
                Text("No sleep logged yet")
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextTertiary)
                    .padding(.vertical, HLSpacing.lg)
            }
        }
        .hlCard()
    }

    // MARK: - Weekly Chart Card

    @ViewBuilder
    private var weeklyChartCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("This Week")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            let dayHours = weekDayHours()

            GeometryReader { geo in
                let barWidth = (geo.size.width - CGFloat(dayLabels.count - 1) * HLSpacing.xxs) / CGFloat(dayLabels.count)
                let maxHour: Double = 12
                let goalLine: Double = 8

                ZStack(alignment: .bottom) {
                    // Goal line
                    let goalY = CGFloat(goalLine / maxHour) * 120
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 120 - goalY))
                        path.addLine(to: CGPoint(x: geo.size.width, y: 120 - goalY))
                    }
                    .stroke(Color.hlWarning.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))

                    HStack(alignment: .bottom, spacing: HLSpacing.xxs) {
                        ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, label in
                            VStack(spacing: HLSpacing.xxs) {
                                let hours = dayHours[index]
                                RoundedRectangle(cornerRadius: HLRadius.xs)
                                    .fill(hours >= goalLine ? Color.hlSleep : Color.hlSleep.opacity(0.4))
                                    .frame(width: barWidth, height: max(4, CGFloat(hours / maxHour) * 120))

                                Text(label)
                                    .font(HLFont.caption2(.medium))
                                    .foregroundStyle(Color.hlTextTertiary)
                            }
                        }
                    }
                }
            }
            .frame(height: 145)
        }
        .hlCard()
    }

    // MARK: - Average Stats Row

    @ViewBuilder
    private var averageStatsRow: some View {
        HStack(spacing: HLSpacing.sm) {
            statMini(
                title: "Avg Duration",
                value: String(format: "%.1fh", averageDuration),
                icon: HLIcon.clock,
                color: .hlSleep
            )
            statMini(
                title: "Avg Quality",
                value: String(format: "%.0f%%", averageQuality * 100),
                icon: HLIcon.star,
                color: .hlGold
            )
            statMini(
                title: "Consistency",
                value: "\(consistencyPercent)%",
                icon: HLIcon.target,
                color: .hlPrimary
            )
        }
    }

    @ViewBuilder
    private func statMini(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: HLSpacing.xs) {
            Image(systemName: icon)
                .font(HLFont.title3())
                .foregroundStyle(color)
            Text(value)
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)
            Text(title)
                .font(HLFont.caption(.medium))
                .foregroundStyle(Color.hlTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .hlCard()
    }

    // MARK: - Insights Card

    @ViewBuilder
    private var insightsCard: some View {
        Button {
            showInsights = true
        } label: {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: HLIcon.sparkles)
                    .font(HLFont.title3())
                    .foregroundStyle(Color.hlSleep)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("Sleep Insights")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                    Text("Your best sleep this week was on Saturday")
                        .font(HLFont.footnote())
                        .foregroundStyle(Color.hlTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(HLFont.footnote(.semibold))
                    .foregroundStyle(Color.hlTextTertiary)
            }
            .hlCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func weekDayHours() -> [Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today) // 1=Sun
        // Calculate Monday of this week
        let daysToMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: today) else {
            return Array(repeating: 0.0, count: 7)
        }

        var result: [Double] = []
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: monday) else {
                result.append(0)
                continue
            }
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day)!
            if let log = sleepLogs.first(where: {
                let wake = calendar.startOfDay(for: $0.wakeTime)
                return wake >= day && wake < nextDay
            }) {
                result.append(log.durationHours)
            } else {
                result.append(0)
            }
        }
        return result
    }
}

// MARK: - Preview

#Preview {
    SleepDashboardView()
        .modelContainer(for: SleepLog.self, inMemory: true)
}
