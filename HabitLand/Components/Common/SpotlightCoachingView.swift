import SwiftUI

/// Spotlight coaching overlay — guides new users to create their first habit
struct SpotlightCoachingView: View {
    @ScaledMetric(relativeTo: .body) private var trophySize: CGFloat = 24
    @ScaledMetric(relativeTo: .title3) private var bigTrophySize: CGFloat = 36
    let step: CoachingStep
    var onAction: () -> Void = {}
    var onDismiss: () -> Void = {}

    enum CoachingStep {
        case createFirstHabit
        case completeFirstHabit(habitName: String)
    }

    var body: some View {
        ZStack {
            // Dim overlay — tappable to dismiss
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // Coaching card
            VStack(spacing: HLSpacing.lg) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.hlGold.opacity(0.15))
                        .frame(width: 72, height: 72)

                    Image(systemName: iconName)
                        .font(.system(size: min(bigTrophySize, 40), weight: .semibold))
                        .foregroundStyle(Color.hlGold)
                        .symbolRenderingMode(.hierarchical)
                }

                // Text
                VStack(spacing: HLSpacing.xs) {
                    Text(title)
                        .font(HLFont.title2(.bold))
                        .foregroundStyle(Color.hlTextPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.75)

                    Text(subtitle)
                        .font(HLFont.body())
                        .foregroundStyle(Color.hlTextSecondary)
                        .multilineTextAlignment(.center)
                }

                // CTA button
                Button {
                    HLHaptics.selection()
                    onAction()
                } label: {
                    HStack(spacing: HLSpacing.xs) {
                        Text(buttonTitle)
                            .font(HLFont.headline())
                        Image(systemName: "arrow.right")
                            .font(.system(size: min(trophySize, 18), weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.md)
                    .background(Color.hlPrimary)
                    .cornerRadius(HLRadius.lg)
                }

                // Skip
                Button {
                    onDismiss()
                } label: {
                    Text("Maybe later")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
            .padding(HLSpacing.xl)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.xl)
            .hlShadow(HLShadow.lg)
            .padding(.horizontal, HLSpacing.xl)

            // Pointer arrow to FAB area
            if case .createFirstHabit = step {
                VStack {
                    Spacer()
                    Image(systemName: "arrow.down")
                        .font(.system(size: min(trophySize, 28), weight: .bold))
                        .foregroundStyle(Color.hlPrimary)
                        .offset(y: -8)
                }
                .padding(.bottom, 80)
            }
        }
        .transition(.opacity)
    }

    private var iconName: String {
        switch step {
        case .createFirstHabit: return "trophy.fill"
        case .completeFirstHabit: return "checkmark.seal.fill"
        }
    }

    private var title: String {
        switch step {
        case .createFirstHabit:
            return "Create your first habit"
        case .completeFirstHabit(let name):
            return "Complete \"\(name)\""
        }
    }

    private var subtitle: String {
        switch step {
        case .createFirstHabit:
            return "Earn your first Achievement and start leveling up!"
        case .completeFirstHabit:
            return "Tap the circle to mark it done and earn XP!"
        }
    }

    private var buttonTitle: String {
        switch step {
        case .createFirstHabit: return "Let's Go"
        case .completeFirstHabit: return "Got It"
        }
    }
}

#Preview {
    ZStack {
        Color.hlBackground.ignoresSafeArea()
        SpotlightCoachingView(step: .createFirstHabit)
    }
}
