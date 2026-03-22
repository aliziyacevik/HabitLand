import SwiftUI

// MARK: - Weekly Chart

struct WeeklyChart: View {
    /// Completion rates for Monday through Sunday (7 values, each 0.0-1.0).
    let data: [Double]

    var barColor: Color = .hlPrimary
    var height: CGFloat = 140

    private static let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    /// Current day index (0 = Monday ... 6 = Sunday).
    private var todayIndex: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Calendar weekday: 1=Sun, 2=Mon ... 7=Sat
        // We want: 0=Mon, 1=Tue ... 6=Sun
        return (weekday + 5) % 7
    }

    @State private var animatedData: [Double] = Array(repeating: 0, count: 7)

    var body: some View {
        HStack(alignment: .bottom, spacing: HLSpacing.xs) {
            ForEach(0..<7, id: \.self) { index in
                barColumn(index: index)
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(weeklyChartAccessibilityLabel)
        .onAppear {
            withAnimation(HLAnimation.slow) {
                animatedData = data.map { min(max($0, 0), 1.0) }
            }
        }
        .onChange(of: data) { _, newValue in
            withAnimation(HLAnimation.standard) {
                animatedData = newValue.map { min(max($0, 0), 1.0) }
            }
        }
    }

    // MARK: - Accessibility

    private var weeklyChartAccessibilityLabel: String {
        let descriptions = data.enumerated().map { index, value in
            let label = index < Self.dayLabels.count ? Self.dayLabels[index] : "Day \(index + 1)"
            return "\(label) \(Int(min(max(value, 0), 1.0) * 100))%"
        }
        let summary = descriptions.joined(separator: ", ")
        let values = data.map { min(max($0, 0), 1.0) }
        let avg = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        let trend: String
        if values.count >= 2 {
            let firstHalf = values.prefix(values.count / 2).reduce(0, +) / Double(max(values.count / 2, 1))
            let secondHalf = values.suffix(values.count / 2).reduce(0, +) / Double(max(values.count / 2, 1))
            trend = secondHalf > firstHalf + 0.05 ? "Trend: improving" : (secondHalf < firstHalf - 0.05 ? "Trend: declining" : "Trend: steady")
        } else {
            trend = ""
        }
        return "Weekly completion chart. \(summary). Average \(Int(avg * 100))%. \(trend)"
    }

    // MARK: - Bar Column

    @ViewBuilder
    private func barColumn(index: Int) -> some View {
        let value = index < animatedData.count ? animatedData[index] : 0
        let isToday = index == todayIndex
        let labelHeight: CGFloat = 20
        let barAreaHeight = height - labelHeight - HLSpacing.xxs

        VStack(spacing: HLSpacing.xxs) {
            ZStack(alignment: .bottom) {
                // Background bar
                RoundedRectangle(cornerRadius: HLRadius.xs)
                    .fill(Color.hlDivider)
                    .frame(height: barAreaHeight)

                // Filled bar
                RoundedRectangle(cornerRadius: HLRadius.xs)
                    .fill(
                        isToday
                            ? barColor
                            : barColor.opacity(0.7)
                    )
                    .frame(height: max(barAreaHeight * value, 4))
            }

            // Day label
            Text(Self.dayLabels[index])
                .font(HLFont.caption2(isToday ? .bold : .regular))
                .foregroundColor(isToday ? .hlTextPrimary : .hlTextTertiary)
                .frame(height: labelHeight)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    WeeklyChart(data: [0.8, 1.0, 0.6, 0.9, 0.4, 0.7, 0.3])
        .padding()
        .hlCard()
}
