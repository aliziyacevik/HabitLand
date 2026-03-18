import SwiftUI

struct HLSlider: View {
    let label: String
    var minLabel: String?
    var maxLabel: String?
    var valueFormatter: ((Double) -> String)?

    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double?

    private var displayValue: String {
        if let formatter = valueFormatter {
            return formatter(value)
        }
        if step != nil && step! >= 1 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            HStack {
                Text(label)
                    .font(HLFont.subheadline(.medium))
                    .foregroundStyle(Color.hlTextPrimary)

                Spacer()

                Text(displayValue)
                    .font(HLFont.subheadline(.semibold))
                    .foregroundStyle(Color.hlPrimary)
                    .contentTransition(.numericText())
                    .animation(HLAnimation.quick, value: value)
            }

            if let step {
                Slider(value: $value, in: range, step: step)
                    .tint(Color.hlPrimary)
            } else {
                Slider(value: $value, in: range)
                    .tint(Color.hlPrimary)
            }

            if minLabel != nil || maxLabel != nil {
                HStack {
                    if let minLabel {
                        Text(minLabel)
                            .font(HLFont.caption2())
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                    Spacer()
                    if let maxLabel {
                        Text(maxLabel)
                            .font(HLFont.caption2())
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: HLSpacing.xl) {
        HLSlider(
            label: "Daily Goal",
            minLabel: "1",
            maxLabel: "10",
            value: .constant(5),
            range: 1...10,
            step: 1
        )

        HLSlider(
            label: "Sleep Target",
            minLabel: "4h",
            maxLabel: "12h",
            valueFormatter: { "\(String(format: "%.1f", $0))h" },
            value: .constant(8.0),
            range: 4...12,
            step: 0.5
        )
    }
    .padding()
}
