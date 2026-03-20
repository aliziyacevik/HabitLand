import SwiftUI
import SwiftData

struct SleepInsightsView: View {
    @Query(sort: \SleepLog.wakeTime, order: .reverse) private var sleepLogs: [SleepLog]

    private var insights: [SleepInsight] {
        generateInsights()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                headerCard

                ForEach(insights) { insight in
                    insightCard(insight)
                }

                if insights.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .background(Color.hlBackground)
        .navigationTitle("Sleep Insights")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    @ViewBuilder
    private var headerCard: some View {
        VStack(spacing: HLSpacing.sm) {
            Image(systemName: HLIcon.sparkles)
                .font(.system(size: 36))
                .foregroundStyle(Color.hlSleep)

            Text("Personalized Insights")
                .font(HLFont.title3())
                .foregroundStyle(Color.hlTextPrimary)

            Text("Based on your sleep data, here are some patterns and recommendations.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .hlCard()
    }

    // MARK: - Insight Card

    @ViewBuilder
    private func insightCard(_ insight: SleepInsight) -> some View {
        HStack(alignment: .top, spacing: HLSpacing.sm) {
            Image(systemName: insight.icon)
                .font(HLFont.title3())
                .foregroundStyle(insight.color)
                .frame(width: 40, height: 40)
                .background(insight.color.opacity(0.12), in: RoundedRectangle(cornerRadius: HLRadius.md))

            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text(insight.title)
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)

                Text(insight.description)
                    .font(HLFont.subheadline())
                    .foregroundStyle(Color.hlTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let recommendation = insight.recommendation {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: HLIcon.sparkles)
                            .font(HLFont.caption2())
                        Text(recommendation)
                            .font(HLFont.footnote(.medium))
                    }
                    .foregroundStyle(Color.hlSleep)
                    .padding(.top, HLSpacing.xxs)
                }
            }

            Spacer(minLength: 0)
        }
        .hlCard()
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: HLIcon.moon)
                .font(.system(size: 44))
                .foregroundStyle(Color.hlTextTertiary)

            Text("Not enough data yet")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextSecondary)

            Text("Log at least 7 nights of sleep to start seeing personalized insights.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, HLSpacing.xxxl)
    }

    // MARK: - Generate Insights

    private func generateInsights() -> [SleepInsight] {
        guard sleepLogs.count >= 3 else { return [] }

        var results: [SleepInsight] = []
        let calendar = Calendar.current

        // Insight: Best sleep day of week
        var dayTotals = Array(repeating: 0.0, count: 7)
        var dayCounts = Array(repeating: 0, count: 7)
        for log in sleepLogs {
            let wd = calendar.component(.weekday, from: log.wakeTime)
            let idx = (wd + 5) % 7
            dayTotals[idx] += log.durationHours
            dayCounts[idx] += 1
        }
        let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let dayAvgs = (0..<7).map { i in dayCounts[i] > 0 ? dayTotals[i] / Double(dayCounts[i]) : 0 }
        if let bestIdx = dayAvgs.enumerated().max(by: { $0.element < $1.element })?.offset, dayAvgs[bestIdx] > 0 {
            results.append(SleepInsight(
                icon: HLIcon.star,
                color: .hlGold,
                title: "Your best sleep is on \(dayNames[bestIdx])s",
                description: String(format: "You average %.1f hours on %@s, which is your longest sleep night.", dayAvgs[bestIdx], dayNames[bestIdx]),
                recommendation: "Try to replicate your \(dayNames[bestIdx]) routine on other nights."
            ))
        }

        // Insight: Bedtime and quality correlation
        let earlyBedLogs = sleepLogs.filter {
            let hour = calendar.component(.hour, from: $0.bedTime)
            return hour >= 0 && hour < 23
        }
        let lateBedLogs = sleepLogs.filter {
            let hour = calendar.component(.hour, from: $0.bedTime)
            return hour >= 23 && hour < 24
        }
        if !earlyBedLogs.isEmpty && !lateBedLogs.isEmpty {
            let earlyAvgQ = earlyBedLogs.map(\.quality.value).reduce(0, +) / Double(earlyBedLogs.count)
            let lateAvgQ = lateBedLogs.map(\.quality.value).reduce(0, +) / Double(lateBedLogs.count)
            if earlyAvgQ > lateAvgQ {
                results.append(SleepInsight(
                    icon: HLIcon.bed,
                    color: .hlSleep,
                    title: "Going to bed before 11pm improves your quality",
                    description: String(format: "Your quality score is %.0f%% on early nights vs %.0f%% on late nights.", earlyAvgQ * 100, lateAvgQ * 100),
                    recommendation: "Set a bedtime reminder for 10:30pm."
                ))
            }
        }

        // Insight: Weekend vs weekday
        let weekendLogs = sleepLogs.filter {
            let wd = calendar.component(.weekday, from: $0.wakeTime)
            return wd == 1 || wd == 7
        }
        let weekdayLogs = sleepLogs.filter {
            let wd = calendar.component(.weekday, from: $0.wakeTime)
            return wd >= 2 && wd <= 6
        }
        if !weekendLogs.isEmpty && !weekdayLogs.isEmpty {
            let weekendAvg = weekendLogs.map(\.durationHours).reduce(0, +) / Double(weekendLogs.count)
            let weekdayAvg = weekdayLogs.map(\.durationHours).reduce(0, +) / Double(weekdayLogs.count)
            let diff = weekendAvg - weekdayAvg
            if abs(diff) > 0.5 {
                results.append(SleepInsight(
                    icon: HLIcon.calendar,
                    color: .hlInfo,
                    title: diff > 0 ? "You sleep more on weekends" : "You sleep more on weekdays",
                    description: String(format: "Weekend average: %.1fh vs Weekday average: %.1fh (%.1fh difference).", weekendAvg, weekdayAvg, abs(diff)),
                    recommendation: diff > 0 ? "Try going to bed 30 minutes earlier on weeknights." : nil
                ))
            }
        }

        // Insight: Sleep consistency
        if sleepLogs.count >= 7 {
            let recentBedtimes = Array(sleepLogs.prefix(7)).map { log -> Double in
                let comps = calendar.dateComponents([.hour, .minute], from: log.bedTime)
                var hour = Double(comps.hour ?? 0) + Double(comps.minute ?? 0) / 60.0
                if hour < 12 { hour += 24 } // Normalize past-midnight
                return hour
            }
            let mean = recentBedtimes.reduce(0, +) / Double(recentBedtimes.count)
            let variance = recentBedtimes.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Double(recentBedtimes.count)
            let stdDev = sqrt(variance)

            if stdDev < 0.75 {
                results.append(SleepInsight(
                    icon: HLIcon.checkmark,
                    color: .hlPrimary,
                    title: "Great bedtime consistency!",
                    description: "Your bedtime varies by less than 45 minutes. Consistent sleep schedules lead to better rest.",
                    recommendation: nil
                ))
            } else if stdDev > 1.5 {
                results.append(SleepInsight(
                    icon: HLIcon.bell,
                    color: .hlWarning,
                    title: "Your bedtime varies a lot",
                    description: String(format: "Your bedtime varies by about %.0f minutes. Irregular sleep schedules can reduce sleep quality.", stdDev * 60),
                    recommendation: "Try to keep your bedtime within a 30-minute window each night."
                ))
            }
        }

        return results
    }
}

// MARK: - Insight Model

private struct SleepInsight: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let description: String
    let recommendation: String?
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SleepInsightsView()
    }
    .modelContainer(for: SleepLog.self, inMemory: true)
}
