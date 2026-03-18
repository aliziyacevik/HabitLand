import SwiftUI
import SwiftData

struct StreakCard: View {
    let currentStreak: Int
    let bestStreak: Int
    var useGradient: Bool = true

    @State private var flameScale: CGFloat = 1.0

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
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.hlFlame, .hlGold],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .scaleEffect(flameScale)
                .onAppear {
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

                Text(currentStreak == 1 ? "day" : "days")
                    .font(HLFont.subheadline(.medium))
                    .foregroundColor(useGradient ? .white.opacity(0.8) : .hlTextSecondary)
            }

            // Best streak
            HStack(spacing: HLSpacing.xxs) {
                Image(systemName: HLIcon.trophy)
                    .font(.system(size: 12))
                    .foregroundColor(useGradient ? .white.opacity(0.7) : .hlGold)

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
