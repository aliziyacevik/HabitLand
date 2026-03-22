import SwiftUI

struct ProgressCard: View {
    let title: String
    let value: String
    let subtitle: String
    let progress: Double
    var ringColor: Color = .hlPrimary
    var ringSize: CGFloat = 72

    @ScaledMetric(relativeTo: .body) private var scaledBaseSize: CGFloat = 72
    private var scaledRingSize: CGFloat { scaledBaseSize * (ringSize / 72.0) }

    var body: some View {
        VStack(spacing: HLSpacing.sm) {
            // Circular progress ring
            ZStack {
                Circle()
                    .stroke(ringColor.opacity(0.15), lineWidth: 6)
                    .frame(width: scaledRingSize, height: scaledRingSize)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: scaledRingSize, height: scaledRingSize)
                    .rotationEffect(.degrees(-90))
                    .animation(HLAnimation.slow, value: progress)

                Text(value)
                    .font(HLFont.title3(.bold))
                    .foregroundColor(.hlTextPrimary)
            }

            // Title
            Text(title)
                .font(HLFont.subheadline(.medium))
                .foregroundColor(.hlTextPrimary)
                .lineLimit(1)

            // Subtitle
            Text(subtitle)
                .font(HLFont.caption())
                .foregroundColor(.hlTextSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(value). \(subtitle)")
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: HLSpacing.sm) {
        ProgressCard(
            title: "Today",
            value: "75%",
            subtitle: "6 of 8 habits",
            progress: 0.75,
            ringColor: .hlPrimary
        )

        ProgressCard(
            title: "This Week",
            value: "62%",
            subtitle: "43 of 56",
            progress: 0.62,
            ringColor: .hlFitness,
            ringSize: 72
        )
    }
    .padding()
    .background(Color.hlBackground)
}
