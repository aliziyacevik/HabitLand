import SwiftUI

struct MilestoneBadge: View {
    let days: Int
    let isAchieved: Bool
    var size: CGFloat = 72

    private var tier: Tier {
        switch days {
        case ..<14: return .bronze
        case ..<60: return .silver
        default: return .gold
        }
    }

    private var iconSize: CGFloat { size * 0.32 }

    enum Tier {
        case bronze, silver, gold

        var primaryColor: Color {
            switch self {
            case .bronze: return .hlBronze
            case .silver: return .hlSilver
            case .gold: return .hlGold
            }
        }

        var backgroundColor: Color {
            switch self {
            case .bronze: return Color(red: 0.95, green: 0.88, blue: 0.78)
            case .silver: return Color(red: 0.93, green: 0.93, blue: 0.95)
            case .gold: return Color(red: 1.0, green: 0.96, blue: 0.82)
            }
        }

        var label: String {
            switch self {
            case .bronze: return "Bronze"
            case .silver: return "Silver"
            case .gold: return "Gold"
            }
        }
    }

    var body: some View {
        VStack(spacing: HLSpacing.xs) {
            ZStack {
                // Glow when achieved
                if isAchieved {
                    Circle()
                        .fill(tier.primaryColor.opacity(0.12))
                        .frame(width: size + 10, height: size + 10)
                        .blur(radius: 6)
                }

                // Background
                Circle()
                    .fill(isAchieved ? tier.backgroundColor : Color.hlDivider.opacity(0.5))
                    .frame(width: size, height: size)

                // Border ring
                Circle()
                    .stroke(
                        isAchieved ? tier.primaryColor : Color.hlTextTertiary.opacity(0.3),
                        lineWidth: 2.5
                    )
                    .frame(width: size, height: size)

                // Content
                VStack(spacing: 1) {
                    Image(systemName: isAchieved ? HLIcon.medal : "lock.fill")
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundStyle(isAchieved ? tier.primaryColor : Color.hlTextTertiary)

                    Text("\(days)")
                        .font(HLFont.caption2(.bold))
                        .foregroundStyle(isAchieved ? tier.primaryColor : Color.hlTextTertiary)
                }
            }

            VStack(spacing: 0) {
                Text("\(days)-Day")
                    .font(HLFont.caption(.semibold))
                    .foregroundStyle(isAchieved ? Color.hlTextPrimary : Color.hlTextTertiary)

                Text(tier.label)
                    .font(HLFont.caption2())
                    .foregroundStyle(isAchieved ? tier.primaryColor : Color.hlTextTertiary)
            }
        }
    }
}

#Preview {
    HStack(spacing: HLSpacing.lg) {
        MilestoneBadge(days: 7, isAchieved: true)
        MilestoneBadge(days: 30, isAchieved: true)
        MilestoneBadge(days: 100, isAchieved: false)
        MilestoneBadge(days: 365, isAchieved: true, size: 80)
    }
    .padding()
}
