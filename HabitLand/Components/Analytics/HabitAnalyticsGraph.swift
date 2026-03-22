import SwiftUI

// MARK: - Habit Analytics Graph

struct HabitAnalyticsGraph: View {
    /// Completion values for the last 30 days (0.0-1.0 each). Index 0 = oldest day.
    let data: [Double]

    var lineColor: Color = .hlPrimary
    var height: CGFloat = 200

    @State private var animationProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let points = dataPoints(in: size)

            ZStack {
                // Area fill
                areaPath(points: points, size: size)
                    .fill(
                        LinearGradient(
                            colors: [lineColor.opacity(0.25), lineColor.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(
                        AnimatedReveal(progress: animationProgress)
                    )

                // Line
                linePath(points: points)
                    .trim(from: 0, to: animationProgress)
                    .stroke(
                        lineColor,
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    )

                // Dots
                ForEach(points.indices, id: \.self) { index in
                    Circle()
                        .fill(lineColor)
                        .frame(width: 6, height: 6)
                        .position(points[index])
                        .opacity(animationProgress > CGFloat(index) / CGFloat(max(points.count - 1, 1)) ? 1 : 0)
                }
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(analyticsGraphAccessibilityLabel)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }

    // MARK: - Accessibility

    private var analyticsGraphAccessibilityLabel: String {
        guard !data.isEmpty else { return "Habit analytics graph. No data available." }
        let values = data.map { min(max($0, 0), 1.0) }
        let avg = Int(values.reduce(0, +) / Double(values.count) * 100)
        let latest = Int((values.last ?? 0) * 100)
        let earliest = Int((values.first ?? 0) * 100)
        let trend: String
        if latest > earliest + 5 { trend = "improving" }
        else if latest < earliest - 5 { trend = "declining" }
        else { trend = "steady" }
        return "Habit completion trend over \(data.count) days. Average \(avg)%, most recent \(latest)%. Trend: \(trend)."
    }

    // MARK: - Geometry Helpers

    private func dataPoints(in size: CGSize) -> [CGPoint] {
        guard data.count > 1 else {
            if data.count == 1 {
                return [CGPoint(x: size.width / 2, y: size.height * (1 - CGFloat(data[0])))]
            }
            return []
        }

        let padding: CGFloat = HLSpacing.xs
        let drawWidth = size.width - padding * 2
        let drawHeight = size.height - padding * 2

        return data.enumerated().map { index, value in
            let x = padding + drawWidth * CGFloat(index) / CGFloat(data.count - 1)
            let y = padding + drawHeight * (1 - CGFloat(min(max(value, 0), 1.0)))
            return CGPoint(x: x, y: y)
        }
    }

    private func linePath(points: [CGPoint]) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
    }

    private func areaPath(points: [CGPoint], size: CGSize) -> Path {
        Path { path in
            guard let first = points.first, let last = points.last else { return }
            path.move(to: CGPoint(x: first.x, y: size.height))
            path.addLine(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.addLine(to: CGPoint(x: last.x, y: size.height))
            path.closeSubpath()
        }
    }
}

// MARK: - Animated Reveal Shape

private struct AnimatedReveal: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path(CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width * progress,
            height: rect.height
        ))
    }
}

// MARK: - Preview

#Preview {
    let sampleData: [Double] = (0..<30).map { _ in Double.random(in: 0.3...1.0) }

    HabitAnalyticsGraph(data: sampleData)
        .padding()
        .hlCard()
}
