import SwiftUI

// MARK: - Leaderboard Entry

struct LeaderboardEntry: Identifiable {
    var id: String { recordName }
    let recordName: String
    let rank: Int
    let name: String
    let avatarEmoji: String
    let xp: Int
    let level: Int
    let streak: Int
    let isCurrentUser: Bool

    /// Score used for display — defaults to xp
    var score: Int { xp }

    init(recordName: String = UUID().uuidString,
         rank: Int = 0,
         name: String,
         avatarEmoji: String,
         xp: Int = 0,
         level: Int = 1,
         streak: Int = 0,
         isCurrentUser: Bool = false,
         score: Int? = nil) {
        self.recordName = recordName
        self.rank = rank
        self.name = name
        self.avatarEmoji = avatarEmoji
        self.xp = score ?? xp
        self.level = level
        self.streak = streak
        self.isCurrentUser = isCurrentUser
    }
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
            rankBadge

            Text(entry.avatarEmoji)
                .font(.system(size: isTopThree ? 28 : 24))
                .frame(width: isTopThree ? 44 : 36, height: isTopThree ? 44 : 36)
                .background(isTopThree ? rankColor.opacity(0.15) : Color.hlBackground)
                .clipShape(Circle())

            Text(entry.isCurrentUser ? "You" : entry.name)
                .font(isTopThree ? HLFont.headline() : HLFont.body())
                .foregroundColor(.hlTextPrimary)

            Spacer()

            HStack(spacing: HLSpacing.xxxs) {
                Image(systemName: HLIcon.flame)
                    .font(.system(size: 11))
                    .foregroundColor(.hlFlame)

                Text("\(entry.streak)")
                    .font(HLFont.caption(.medium))
                    .foregroundColor(.hlTextSecondary)
            }

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
        LeaderboardRow(entry: LeaderboardEntry(rank: 1, name: "Alex Rivera", avatarEmoji: "🦊", xp: 2450, streak: 45))
        LeaderboardRow(entry: LeaderboardEntry(rank: 2, name: "Jordan Lee", avatarEmoji: "🐻", xp: 2120, streak: 32))
        LeaderboardRow(entry: LeaderboardEntry(rank: 3, name: "Sam Chen", avatarEmoji: "🐼", xp: 1980, streak: 28))
        Divider()
        LeaderboardRow(entry: LeaderboardEntry(rank: 4, name: "Casey Park", avatarEmoji: "🐸", xp: 1750, streak: 21))
        LeaderboardRow(entry: LeaderboardEntry(rank: 5, name: "Morgan Wu", avatarEmoji: "🐱", xp: 1600, streak: 15))
    }
    .padding()
}
