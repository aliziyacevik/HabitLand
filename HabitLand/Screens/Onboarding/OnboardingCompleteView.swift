import SwiftUI

struct OnboardingCompleteView: View {
    let habitsCreated: Int
    var onGetStarted: () -> Void = {}

    @State private var showContent = false
    @State private var confettiItems: [ConfettiItem] = []

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            // Confetti layer
            ForEach(confettiItems) { item in
                Image(systemName: "checkmark")
                    .font(.system(size: item.size, weight: .bold))
                    .foregroundColor(item.color.opacity(item.opacity))
                    .position(item.position)
                    .rotationEffect(.degrees(item.rotation))
            }

            // Main content
            VStack(spacing: 0) {
                Spacer()

                // Celebration icon
                ZStack {
                    Circle()
                        .fill(Color.hlPrimary.opacity(0.12))
                        .frame(width: 160, height: 160)
                        .scaleEffect(showContent ? 1.0 : 0.5)

                    Image(systemName: HLIcon.sparkles)
                        .font(.system(size: 64, weight: .medium))
                        .foregroundColor(.hlPrimary)
                        .scaleEffect(showContent ? 1.0 : 0.0)
                }
                .animation(HLAnimation.bouncy.delay(0.2), value: showContent)

                Spacer()
                    .frame(height: HLSpacing.xl)

                // Title
                VStack(spacing: HLSpacing.xs) {
                    Text("You're All Set!")
                        .font(HLFont.largeTitle())
                        .foregroundColor(.hlTextPrimary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(HLAnimation.standard.delay(0.4), value: showContent)

                    Text("Your journey starts now")
                        .font(HLFont.body())
                        .foregroundColor(.hlTextSecondary)
                        .opacity(showContent ? 1 : 0)
                        .animation(HLAnimation.standard.delay(0.5), value: showContent)
                }

                Spacer()
                    .frame(height: HLSpacing.xl)

                // Summary cards
                VStack(spacing: HLSpacing.sm) {
                    if habitsCreated > 0 {
                        summaryRow(
                            icon: "checkmark.circle.fill",
                            color: .hlPrimary,
                            label: "Habits created",
                            value: "\(habitsCreated)"
                        )

                        summaryRow(
                            icon: "sparkles",
                            color: .hlGold,
                            label: "XP earned",
                            value: "+\(habitsCreated * 10) XP"
                        )
                    }
                }
                .padding(.horizontal, HLSpacing.lg)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                .animation(HLAnimation.standard.delay(0.6), value: showContent)

                Spacer()

                // Get Started button
                HLButton(
                    "Let's Go!",
                    icon: "arrow.right",
                    style: .primary,
                    size: .lg,
                    isFullWidth: true
                ) {
                    onGetStarted()
                }
                .padding(.horizontal, HLSpacing.lg)
                .padding(.bottom, HLSpacing.xxl)
                .opacity(showContent ? 1 : 0)
                .animation(HLAnimation.standard.delay(0.8), value: showContent)
            }
        }
        .onAppear {
            showContent = true
            spawnConfetti()
        }
    }

    // MARK: - Summary Row

    private func summaryRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: HLSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: HLRadius.sm)
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(label)
                .font(HLFont.body())
                .foregroundColor(.hlTextPrimary)

            Spacer()

            Text(value)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)
        }
        .padding(HLSpacing.md)
        .background(Color.hlSurface)
        .cornerRadius(HLRadius.lg)
        .hlShadow(HLShadow.sm)
    }

    private func spawnConfetti() {
        let colors: [Color] = [.hlPrimary, .hlGold, .hlFitness, .hlMindfulness, .hlFlame]
        for i in 0..<20 {
            let item = ConfettiItem(
                position: CGPoint(
                    x: CGFloat.random(in: 30...360),
                    y: CGFloat.random(in: -40...700)
                ),
                size: CGFloat.random(in: 10...22),
                color: colors[i % colors.count],
                opacity: Double.random(in: 0.15...0.45),
                rotation: Double.random(in: 0...360)
            )
            confettiItems.append(item)
        }
    }
}

// MARK: - Confetti Item

private struct ConfettiItem: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let color: Color
    let opacity: Double
    let rotation: Double
}

#Preview {
    OnboardingCompleteView(habitsCreated: 3)
}
