import SwiftUI

// MARK: - Ring Size

enum RingSize {
    case sm, md, lg

    var diameter: CGFloat {
        switch self {
        case .sm: return 40
        case .md: return 60
        case .lg: return 100
        }
    }

    var lineWidth: CGFloat {
        switch self {
        case .sm: return 4
        case .md: return 6
        case .lg: return 10
        }
    }

    var font: Font {
        switch self {
        case .sm: return HLFont.caption2(.bold)
        case .md: return HLFont.footnote(.bold)
        case .lg: return HLFont.title3(.bold)
        }
    }
}

// MARK: - Circular Progress Ring

struct CircularProgressRing: View {
    let progress: Double
    var size: RingSize = .md
    var lineWidth: CGFloat? = nil
    var color: Color = .hlPrimary
    var showPercentage: Bool = true

    @State private var animatedProgress: Double = 0

    private var effectiveLineWidth: CGFloat {
        lineWidth ?? size.lineWidth
    }

    private var percentageText: String {
        "\(Int(min(animatedProgress, 1.0) * 100))%"
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    color.opacity(0.15),
                    style: StrokeStyle(lineWidth: effectiveLineWidth, lineCap: .round)
                )

            // Filled arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: effectiveLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Percentage label
            if showPercentage {
                Text(percentageText)
                    .font(size.font)
                    .foregroundColor(.hlTextPrimary)
            }
        }
        .frame(width: size.diameter, height: size.diameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(min(progress, 1.0) * 100)) percent complete")
        .hlRingGlow(progress: animatedProgress, color: color)
        .onAppear {
            withAnimation(HLAnimation.progressFill) {
                animatedProgress = min(max(progress, 0), 1.0)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(HLAnimation.progressFill) {
                animatedProgress = min(max(newValue, 0), 1.0)
            }
        }
    }
}

// MARK: - Preview

#Preview("All Sizes") {
    HStack(spacing: HLSpacing.lg) {
        CircularProgressRing(progress: 0.45, size: .sm)
        CircularProgressRing(progress: 0.72, size: .md)
        CircularProgressRing(progress: 0.88, size: .lg)
    }
    .padding()
}

#Preview("Custom Color") {
    CircularProgressRing(progress: 0.65, size: .lg, color: .hlFitness)
        .padding()
}
