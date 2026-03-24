import SwiftUI

struct AchievementBadge: View {
    let icon: String
    let name: String
    let isUnlocked: Bool
    var size: CGFloat = 64

    @ScaledMetric(relativeTo: .body) private var scaledSize: CGFloat = 64
    private var badgeSize: CGFloat { scaledSize * (size / 64.0) }
    private var iconSize: CGFloat { badgeSize * 0.4 }

    var body: some View {
        VStack(spacing: HLSpacing.xs) {
            ZStack {
                // Glow layer (unlocked only)
                if isUnlocked {
                    Circle()
                        .fill(Color.hlGold.opacity(0.15))
                        .frame(width: badgeSize + 8, height: badgeSize + 8)
                        .blur(radius: 6)
                }

                // Background circle
                Circle()
                    .fill(isUnlocked ? Color.hlGold.opacity(0.15) : Color.hlDivider.opacity(0.6))
                    .frame(width: badgeSize, height: badgeSize)

                // Border
                Circle()
                    .stroke(
                        isUnlocked ? Color.hlGold : Color.hlTextTertiary.opacity(0.4),
                        lineWidth: 2
                    )
                    .frame(width: badgeSize, height: badgeSize)

                // Icon
                Image(systemName: isUnlocked ? icon : "lock.fill")
                    .font(.system(size: min(iconSize, 36), weight: .semibold))
                    .foregroundStyle(isUnlocked ? Color.hlGold : Color.hlTextTertiary)
                    .accessibilityHidden(true)
            }

            Text(name)
                .font(HLFont.caption(.medium))
                .foregroundStyle(isUnlocked ? Color.hlTextPrimary : Color.hlTextTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: badgeSize + HLSpacing.md)
        }
    }
}

#Preview {
    HStack(spacing: HLSpacing.lg) {
        AchievementBadge(
            icon: "flame.fill",
            name: "On Fire",
            isUnlocked: true
        )

        AchievementBadge(
            icon: "star.fill",
            name: "Century",
            isUnlocked: false
        )

        AchievementBadge(
            icon: "crown.fill",
            name: "Perfect Week",
            isUnlocked: true,
            size: 80
        )
    }
    .padding()
}
