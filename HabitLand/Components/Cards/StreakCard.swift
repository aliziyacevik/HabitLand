import SwiftUI
import SwiftData

struct StreakCard: View {
    @ScaledMetric(relativeTo: .caption) private var flameIconSize: CGFloat = 12
    let currentStreak: Int
    let bestStreak: Int
    var useGradient: Bool = true

    @State private var flameScale: CGFloat = 1.0
    @ScaledMetric(relativeTo: .body) private var flameSize: CGFloat = 40
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Model Initializer

    init(habit: Habit, useGradient: Bool = true) {
        self.currentStreak = habit.currentStreak
        self.bestStreak = habit.bestStreak
        self.useGradient = useGradient
    }

    // MARK: - Preview Initializer

    init(
        currentStreak: Int = 14,
        bestStreak: Int = 30,
        useGradient: Bool = true
    ) {
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.useGradient = useGradient
    }

    var body: some View {
        VStack(spacing: HLSpacing.md) {
            // Animated flame
            Image(systemName: HLIcon.flame)
                .font(.system(size: min(flameSize, 52), weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.hlFlame, .hlGold],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .scaleEffect(flameScale)
                .accessibilityHidden(true)
                .onAppear {
                    guard !reduceMotion else { return }
                    withAnimation(
                        .easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                    ) {
                        flameScale = 1.12
                    }
                }

            // Current streak count
            VStack(spacing: HLSpacing.xxxs) {
                Text("\(currentStreak)")
                    .font(HLFont.largeTitle(.bold))
                    .foregroundColor(useGradient ? .white : .hlTextPrimary)
                    .minimumScaleFactor(0.75)

                Text(currentStreak == 1 ? "day" : "days")
                    .font(HLFont.subheadline(.medium))
                    .foregroundColor(useGradient ? .white.opacity(0.8) : .hlTextSecondary)
            }

            // Best streak
            HStack(spacing: HLSpacing.xxs) {
                Image(systemName: HLIcon.trophy)
                    .font(.system(size: min(flameIconSize, 16)))
                    .foregroundColor(useGradient ? .white.opacity(0.7) : .hlGold)
                    .accessibilityHidden(true)

                Text("Best: \(bestStreak) days")
                    .font(HLFont.caption(.medium))
                    .foregroundColor(useGradient ? .white.opacity(0.7) : .hlTextTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(HLSpacing.lg)
        .background(backgroundView)
        .cornerRadius(HLRadius.lg)
        .hlShadow(HLShadow.md)
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        if useGradient {
            LinearGradient(
                colors: [.hlPrimary, .hlPrimaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color.hlSurface
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HLSpacing.md) {
        StreakCard(currentStreak: 14, bestStreak: 30, useGradient: true)
        StreakCard(currentStreak: 3, bestStreak: 10, useGradient: false)
    }
    .padding()
    .background(Color.hlBackground)
}
