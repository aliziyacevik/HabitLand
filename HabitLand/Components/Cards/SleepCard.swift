import SwiftUI
import SwiftData

struct SleepCard: View {
    let durationFormatted: String
    let bedTimeFormatted: String
    let wakeTimeFormatted: String
    let qualityEmoji: String
    let qualityLabel: String
    let weekBarData: [Double] // 7 values, hours per night

    // MARK: - Model Initializer

    init(log: SleepLog, weekLogs: [SleepLog] = []) {
        self.durationFormatted = log.durationFormatted
        self.qualityEmoji = log.quality.icon
        self.qualityLabel = log.quality.rawValue

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        self.bedTimeFormatted = formatter.string(from: log.bedTime)
        self.wakeTimeFormatted = formatter.string(from: log.wakeTime)

        if weekLogs.isEmpty {
            self.weekBarData = [log.durationHours]
        } else {
            self.weekBarData = weekLogs.suffix(7).map { $0.durationHours }
        }
    }

    // MARK: - Preview Initializer

    init(
        durationFormatted: String = "7h 30m",
        bedTimeFormatted: String = "11:00 PM",
        wakeTimeFormatted: String = "6:30 AM",
        qualityEmoji: String = "😊",
        qualityLabel: String = "Good",
        weekBarData: [Double] = [6.5, 7.0, 8.0, 6.0, 7.5, 8.5, 7.0]
    ) {
        self.durationFormatted = durationFormatted
        self.bedTimeFormatted = bedTimeFormatted
        self.wakeTimeFormatted = wakeTimeFormatted
        self.qualityEmoji = qualityEmoji
        self.qualityLabel = qualityLabel
        self.weekBarData = weekBarData
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            // Top row: duration + quality
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                    Text("Sleep")
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlTextSecondary)

                    Text(durationFormatted)
                        .font(HLFont.title1(.bold))
                        .foregroundColor(.hlTextPrimary)
                }

                Spacer()

                VStack(spacing: HLSpacing.xxs) {
                    Text(qualityEmoji)
                        .font(HLFont.title1())

                    Text(qualityLabel)
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlTextSecondary)
                }
            }

            // Bed / Wake times
            HStack(spacing: HLSpacing.lg) {
                timeLabel(icon: HLIcon.bed, label: "Bedtime", time: bedTimeFormatted)
                timeLabel(icon: HLIcon.sunrise, label: "Wake up", time: wakeTimeFormatted)
            }

            // Mini bar chart - last 7 days
            if weekBarData.count > 1 {
                VStack(alignment: .leading, spacing: HLSpacing.xs) {
                    Text("Last 7 nights")
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlTextSecondary)

                    miniBarChart
                }
            }
        }
        .hlCard()
        .accessibilityElement(children: .combine)
    }

    // MARK: - Subviews

    private func timeLabel(icon: String, label: String, time: String) -> some View {
        HStack(spacing: HLSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.hlSleep)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(label)
                    .font(HLFont.caption2())
                    .foregroundColor(.hlTextTertiary)

                Text(time)
                    .font(HLFont.subheadline(.medium))
                    .foregroundColor(.hlTextPrimary)
            }
        }
    }

    private var miniBarChart: some View {
        let maxHours = max(weekBarData.max() ?? 8, 10)
        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

        return HStack(alignment: .bottom, spacing: HLSpacing.xs) {
            ForEach(Array(weekBarData.suffix(7).enumerated()), id: \.offset) { index, hours in
                VStack(spacing: HLSpacing.xxs) {
                    RoundedRectangle(cornerRadius: HLRadius.xs)
                        .fill(barColor(for: hours))
                        .frame(height: max(4, CGFloat(hours / maxHours) * 48))

                    Text(dayLabels[index % dayLabels.count])
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 64)
    }

    private func barColor(for hours: Double) -> Color {
        if hours >= 7 { return .hlSleep }
        if hours >= 6 { return .hlSleep.opacity(0.6) }
        return .hlWarning
    }
}

// MARK: - Preview

#Preview {
    SleepCard()
        .padding()
        .background(Color.hlBackground)
}
