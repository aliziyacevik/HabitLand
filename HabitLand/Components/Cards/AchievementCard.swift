import SwiftUI
import SwiftData

struct AchievementCard: View {
    let name: String
    let descriptionText: String
    let icon: String
    let isUnlocked: Bool
    let progress: Double
    let targetValue: Int

    // MARK: - Model Initializer

    init(achievement: Achievement) {
        self.name = achievement.name
        self.descriptionText = achievement.descriptionText
        self.icon = achievement.icon
        self.isUnlocked = achievement.isUnlocked
        self.progress = achievement.progress
        self.targetValue = achievement.targetValue
    }

    // MARK: - Preview Initializer

    init(
        name: String = "On Fire",
        descriptionText: String = "Reach a 7-day streak",
        icon: String = "flame.fill",
        isUnlocked: Bool = false,
        progress: Double = 0.5,
        targetValue: Int = 7
    ) {
        self.name = name
        self.descriptionText = descriptionText
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.progress = progress
        self.targetValue = targetValue
    }

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            // Badge circle
            badgeView

            // Name, description, progress
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text(name)
                    .font(HLFont.headline())
                    .foregroundColor(isUnlocked ? .hlTextPrimary : .hlTextTertiary)
                    .lineLimit(1)

                Text(descriptionText)
                    .font(HLFont.caption())
                    .foregroundColor(isUnlocked ? .hlTextSecondary : .hlTextTertiary)
                    .lineLimit(2)

                // Progress bar (shown when locked and partially complete)
                if !isUnlocked && progress > 0 {
                    progressBar
                }
            }

            Spacer()

            // Unlocked indicator
            if isUnlocked {
                Image(systemName: HLIcon.checkmark)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.hlPrimary)
                    .accessibilityHidden(true)
                    .padding(HLSpacing.xxs)
                    .background(Color.hlPrimaryLight)
                    .clipShape(Circle())
            }
        }
        .hlCard()
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .stroke(isUnlocked ? Color.hlPrimary.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(isUnlocked ? "unlocked" : "locked")\(isUnlocked ? ", \(descriptionText)" : "")")
    }

    // MARK: - Subviews

    private var badgeView: some View {
        ZStack {
            Circle()
                .fill(
                    isUnlocked
                        ? LinearGradient(
                            colors: [.hlGold, .hlFlame],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [.hlSilver.opacity(0.3), .hlSilver.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .frame(width: 48, height: 48)

            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(isUnlocked ? .white : .hlTextTertiary)
        }
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: HLRadius.full)
                        .fill(Color.hlDivider)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: HLRadius.full)
                        .fill(Color.hlPrimary.opacity(0.6))
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 4)
                        .animation(HLAnimation.standard, value: progress)
                }
            }
            .frame(height: 4)

            Text("\(Int(progress * Double(targetValue)))/\(targetValue)")
                .font(HLFont.caption2(.medium))
                .foregroundColor(.hlTextTertiary)
        }
        .padding(.top, HLSpacing.xxs)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HLSpacing.sm) {
        AchievementCard(
            name: "First Step",
            descriptionText: "Complete your first habit",
            icon: "footprints",
            isUnlocked: true,
            progress: 1.0,
            targetValue: 1
        )

        AchievementCard(
            name: "On Fire",
            descriptionText: "Reach a 7-day streak",
            icon: "flame.fill",
            isUnlocked: false,
            progress: 0.57,
            targetValue: 7
        )

        AchievementCard(
            name: "Unstoppable",
            descriptionText: "Reach a 30-day streak",
            icon: "bolt.fill",
            isUnlocked: false,
            progress: 0,
            targetValue: 30
        )
    }
    .padding()
    .background(Color.hlBackground)
}
