import SwiftUI

// MARK: - Leaderboard Entry

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let avatarEmoji: String
    let score: Int
    let streak: Int
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let entry: LeaderboardEntry

    private var isTopThree: Bool {
        entry.rank <= 3
    }

    private var rankColor: Color {
        switch entry.rank {
        case 1: return .hlGold
        case 2: return .hlSilver
        case 3: return .hlBronze
        default: return .hlTextTertiary
        }
    }

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            // Rank
            rankBadge

            // Avatar
            Text(entry.avatarEmoji)
                .font(.system(size: isTopThree ? 28 : 24))
                .frame(width: isTopThree ? 44 : 36, height: isTopThree ? 44 : 36)
                .background(isTopThree ? rankColor.opacity(0.15) : Color.hlBackground)
                .clipShape(Circle())

            // Name
            Text(entry.name)
                .font(isTopThree ? HLFont.headline() : HLFont.body())
                .foregroundColor(.hlTextPrimary)

            Spacer()

            // Streak
            HStack(spacing: HLSpacing.xxxs) {
                Image(systemName: HLIcon.flame)
                    .font(.system(size: 11))
                    .foregroundColor(.hlFlame)

                Text("\(entry.streak)")
                    .font(HLFont.caption(.medium))
                    .foregroundColor(.hlTextSecondary)
            }

            // Score
            Text("\(entry.score)")
                .font(HLFont.headline())
                .foregroundColor(isTopThree ? rankColor : .hlTextPrimary)
                .frame(minWidth: 44, alignment: .trailing)
        }
        .padding(.vertical, isTopThree ? HLSpacing.sm : HLSpacing.xs)
        .padding(.horizontal, HLSpacing.md)
        .background(isTopThree ? rankColor.opacity(0.05) : Color.clear)
        .cornerRadius(HLRadius.md)
    }

    // MARK: - Rank Badge

    @ViewBuilder
    private var rankBadge: some View {
        if isTopThree {
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 28, height: 28)

                Text("\(entry.rank)")
                    .font(HLFont.footnote(.bold))
                    .foregroundColor(.white)
            }
        } else {
            Text("\(entry.rank)")
                .font(HLFont.footnote(.semibold))
                .foregroundColor(.hlTextTertiary)
                .frame(width: 28, alignment: .center)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HLSpacing.xxs) {
        LeaderboardRow(entry: LeaderboardEntry(rank: 1, name: "Alex Rivera", avatarEmoji: "🦊", score: 2450, streak: 45))
        LeaderboardRow(entry: LeaderboardEntry(rank: 2, name: "Jordan Lee", avatarEmoji: "🐻", score: 2120, streak: 32))
        LeaderboardRow(entry: LeaderboardEntry(rank: 3, name: "Sam Chen", avatarEmoji: "🐼", score: 1980, streak: 28))
        Divider()
        LeaderboardRow(entry: LeaderboardEntry(rank: 4, name: "Casey Park", avatarEmoji: "🐸", score: 1750, streak: 21))
        LeaderboardRow(entry: LeaderboardEntry(rank: 5, name: "Morgan Wu", avatarEmoji: "🐱", score: 1600, streak: 15))
    }
    .padding()
}
