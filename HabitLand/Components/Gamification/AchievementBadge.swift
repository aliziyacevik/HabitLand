import SwiftUI

struct AchievementBadge: View {
    let icon: String
    let name: String
    let isUnlocked: Bool
    var size: CGFloat = 64

    private var iconSize: CGFloat { size * 0.4 }

    var body: some View {
        VStack(spacing: HLSpacing.xs) {
            ZStack {
                // Glow layer (unlocked only)
                if isUnlocked {
                    Circle()
                        .fill(Color.hlGold.opacity(0.15))
                        .frame(width: size + 8, height: size + 8)
                        .blur(radius: 6)
                }

                // Background circle
                Circle()
                    .fill(isUnlocked ? Color.hlGold.opacity(0.15) : Color.hlDivider.opacity(0.6))
                    .frame(width: size, height: size)

                // Border
                Circle()
                    .stroke(
                        isUnlocked ? Color.hlGold : Color.hlTextTertiary.opacity(0.4),
                        lineWidth: 2
                    )
                    .frame(width: size, height: size)

                // Icon
                Image(systemName: isUnlocked ? icon : "lock.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(isUnlocked ? Color.hlGold : Color.hlTextTertiary)
            }

            Text(name)
                .font(HLFont.caption(.medium))
                .foregroundStyle(isUnlocked ? Color.hlTextPrimary : Color.hlTextTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: size + HLSpacing.md)
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
