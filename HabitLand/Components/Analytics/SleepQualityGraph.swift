import SwiftUI

// MARK: - Sleep Day Data

struct SleepDayData: Identifiable {
    let id = UUID()
    let dayLabel: String
    let hours: Double
    let quality: SleepQuality
}

// MARK: - Sleep Quality Graph

struct SleepQualityGraph: View {
    let data: [SleepDayData]

    /// Sleep goal in hours (displays as an overlay line).
    var goalHours: Double = 8.0
    var height: CGFloat = 180

    @State private var animatedFractions: [Double] = []

    /// Maximum Y-axis value (hours) used for scaling.
    private var maxHours: Double {
        max(data.map(\.hours).max() ?? 10, goalHours + 1)
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let labelHeight: CGFloat = 20
            let barAreaHeight = size.height - labelHeight - HLSpacing.xxs

            ZStack(alignment: .bottom) {
                // Goal line
                goalLine(barAreaHeight: barAreaHeight, width: size.width)

                // Bars + labels
                HStack(alignment: .bottom, spacing: HLSpacing.xs) {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, entry in
                        barColumn(
                            entry: entry,
                            index: index,
                            barAreaHeight: barAreaHeight,
                            labelHeight: labelHeight
                        )
                    }
                }
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(sleepGraphAccessibilityLabel)
        .onAppear {
            animatedFractions = Array(repeating: 0, count: data.count)
            withAnimation(HLAnimation.slow) {
                animatedFractions = data.map { $0.hours / maxHours }
            }
        }
        .onChange(of: data.map(\.hours)) { _, _ in
            withAnimation(HLAnimation.standard) {
                animatedFractions = data.map { $0.hours / maxHours }
            }
        }
    }

    // MARK: - Accessibility

    private var sleepGraphAccessibilityLabel: String {
        let descriptions = data.map { "\($0.dayLabel) \(String(format: "%.1f", $0.hours)) hours, \($0.quality)" }
        let summary = descriptions.joined(separator: ", ")
        let avg = data.isEmpty ? 0 : data.map(\.hours).reduce(0, +) / Double(data.count)
        let metGoal = data.filter { $0.hours >= goalHours }.count
        return "Sleep quality chart. \(summary). Average \(String(format: "%.1f", avg)) hours. \(metGoal) of \(data.count) nights met \(String(format: "%.0f", goalHours))-hour goal."
    }

    // MARK: - Bar Column

    @ViewBuilder
    private func barColumn(
        entry: SleepDayData,
        index: Int,
        barAreaHeight: CGFloat,
        labelHeight: CGFloat
    ) -> some View {
        let fraction = index < animatedFractions.count ? animatedFractions[index] : 0

        VStack(spacing: HLSpacing.xxs) {
            // Hours label above bar
            Text(String(format: "%.1f", entry.hours))
                .font(HLFont.caption2(.medium))
                .foregroundColor(.hlTextSecondary)

            ZStack(alignment: .bottom) {
                // Background bar
                RoundedRectangle(cornerRadius: HLRadius.xs)
                    .fill(Color.hlDivider)
                    .frame(height: barAreaHeight)

                // Filled bar with quality color
                RoundedRectangle(cornerRadius: HLRadius.xs)
                    .fill(qualityColor(entry.quality))
                    .frame(height: max(barAreaHeight * fraction, 4))
            }

            // Day label
            Text(entry.dayLabel)
                .font(HLFont.caption2())
                .foregroundColor(.hlTextTertiary)
                .frame(height: labelHeight)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Goal Line

    @ViewBuilder
    private func goalLine(barAreaHeight: CGFloat, width: CGFloat) -> some View {
        let goalFraction = goalHours / maxHours
        let yOffset = barAreaHeight * (1 - goalFraction)

        VStack(spacing: 0) {
            Spacer()
                .frame(height: yOffset)

            HStack(spacing: HLSpacing.xxs) {
                Rectangle()
                    .fill(Color.hlTextTertiary)
                    .frame(height: 1)

                Text("Goal")
                    .font(HLFont.caption2(.medium))
                    .foregroundColor(.hlTextTertiary)
                    .fixedSize()
            }

            Spacer()
        }
        .frame(height: barAreaHeight)
        .padding(.bottom, 20 + HLSpacing.xxs) // offset for label area
    }

    // MARK: - Quality Color

    private func qualityColor(_ quality: SleepQuality) -> Color {
        switch quality {
        case .terrible:
            return .hlError
        case .poor:
            return .hlError.opacity(0.7)
        case .fair:
            return .hlWarning
        case .good:
            return .hlPrimary
        case .excellent:
            return .hlPrimary.opacity(0.85)
        }
    }
}

// MARK: - Preview

#Preview {
    let sample: [SleepDayData] = [
        SleepDayData(dayLabel: "Mon", hours: 7.2, quality: .good),
        SleepDayData(dayLabel: "Tue", hours: 5.5, quality: .poor),
        SleepDayData(dayLabel: "Wed", hours: 8.1, quality: .excellent),
        SleepDayData(dayLabel: "Thu", hours: 6.0, quality: .fair),
        SleepDayData(dayLabel: "Fri", hours: 4.5, quality: .terrible),
        SleepDayData(dayLabel: "Sat", hours: 7.8, quality: .good),
        SleepDayData(dayLabel: "Sun", hours: 8.5, quality: .excellent),
    ]

    SleepQualityGraph(data: sample, goalHours: 8)
        .padding()
        .hlCard()
}
