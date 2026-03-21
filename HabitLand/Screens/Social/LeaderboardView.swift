import SwiftUI
import SwiftData

// MARK: - Time Period

private enum TimePeriod: String, CaseIterable {
    case week = "This Week"
    case month = "This Month"
    case allTime = "All Time"
}

// MARK: - LeaderboardView

struct LeaderboardView: View {
    @Query(sort: \Friend.level, order: .reverse) private var friends: [Friend]
    @Query private var profiles: [UserProfile]
    @StateObject private var cloudKit = CloudKitManager.shared

    @State private var selectedPeriod: TimePeriod = .week
    @State private var cloudEntries: [LeaderboardEntry] = []

    private var profile: UserProfile? { profiles.first }

    private var entries: [LeaderboardEntry] {
        // If we have CloudKit data, use it
        if !cloudEntries.isEmpty {
            return cloudEntries
        }

        // Fallback to local data
        var all: [LeaderboardEntry] = []

        if let p = profile {
            all.append(LeaderboardEntry(
                recordName: p.id.uuidString,
                name: p.name.isEmpty ? "You" : p.name,
                avatarEmoji: p.avatarEmoji,
                avatarType: p.avatarType,
                xp: p.xp,
                level: p.level,
                streak: 0,
                isCurrentUser: true
            ))
        }

        for friend in friends {
            all.append(LeaderboardEntry(
                recordName: friend.id.uuidString,
                name: friend.name,
                avatarEmoji: friend.avatarEmoji,
                avatarType: friend.avatarType,
                xp: friend.xp > 0 ? friend.xp : friend.level * 50 + friend.currentStreak * 5,
                level: friend.level,
                streak: friend.currentStreak,
                isCurrentUser: false
            ))
        }

        all.sort { $0.xp > $1.xp }
        return all
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            if entries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: HLSpacing.lg) {
                        periodPicker
                        podiumSection
                        rankingsSection
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.top, HLSpacing.sm)
                    .padding(.bottom, HLSpacing.xxxl)
                }
            }
        }
        .task {
            await refreshLeaderboard()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.lg) {
            Image(systemName: HLIcon.leaderboard)
                .font(.system(size: 48))
                .foregroundStyle(Color.hlTextTertiary)
            Text("No Rankings Yet")
                .font(HLFont.title3())
                .foregroundStyle(Color.hlTextPrimary)
            Text("Add friends to compete on the leaderboard!")
                .font(HLFont.body())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(HLSpacing.xl)
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(HLAnimation.quick) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(HLFont.caption(.semibold))
                        .foregroundColor(selectedPeriod == period ? .white : .hlTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HLSpacing.xs)
                        .background(selectedPeriod == period ? Color.hlPrimary : Color.clear)
                        .cornerRadius(HLRadius.sm)
                }
            }
        }
        .padding(HLSpacing.xxs)
        .background(Color.hlSurface)
        .cornerRadius(HLRadius.md)
        .hlShadow(HLShadow.sm)
    }

    // MARK: - Podium

    private var podiumSection: some View {
        HStack(alignment: .bottom, spacing: HLSpacing.sm) {
            if entries.count >= 3 {
                podiumPlace(entry: entries[1], rank: 2, color: .hlSilver, height: 80, crownIcon: nil)
                podiumPlace(entry: entries[0], rank: 1, color: .hlGold, height: 100, crownIcon: HLIcon.crown)
                podiumPlace(entry: entries[2], rank: 3, color: .hlBronze, height: 64, crownIcon: nil)
            } else if entries.count == 2 {
                podiumPlace(entry: entries[0], rank: 1, color: .hlGold, height: 100, crownIcon: HLIcon.crown)
                podiumPlace(entry: entries[1], rank: 2, color: .hlSilver, height: 80, crownIcon: nil)
            } else if entries.count == 1 {
                podiumPlace(entry: entries[0], rank: 1, color: .hlGold, height: 100, crownIcon: HLIcon.crown)
            }
        }
        .hlCard()
    }

    private func podiumPlace(entry: LeaderboardEntry, rank: Int, color: Color, height: CGFloat, crownIcon: String?) -> some View {
        VStack(spacing: HLSpacing.xs) {
            if let crown = crownIcon {
                Image(systemName: crown)
                    .font(.system(size: 20))
                    .foregroundColor(.hlGold)
            }

            AvatarView(name: entry.name, size: 56, avatarType: entry.avatarType)
                .overlay(
                    Circle().stroke(color, lineWidth: 3)
                )

            Text(entry.isCurrentUser ? "You" : entry.name)
                .font(HLFont.caption(.semibold))
                .foregroundColor(.hlTextPrimary)
                .lineLimit(1)

            Text("\(entry.xp) XP")
                .font(HLFont.caption2(.medium))
                .foregroundColor(.hlTextSecondary)

            RoundedRectangle(cornerRadius: HLRadius.sm)
                .fill(color.opacity(0.2))
                .frame(height: height)
                .overlay(
                    Text("#\(rank)")
                        .font(HLFont.title3(.bold))
                        .foregroundColor(color)
                )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Rankings List

    private var rankingsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Full Rankings")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)
                .padding(.bottom, HLSpacing.xxs)

            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                rankRow(entry, rank: index + 1)
                    .hlStaggeredAppear(index: index)
            }
        }
    }

    private func rankRow(_ entry: LeaderboardEntry, rank: Int) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Text("\(rank)")
                .font(HLFont.headline())
                .foregroundColor(rankColor(rank))
                .frame(width: 28, alignment: .center)

            AvatarView(name: entry.isCurrentUser ? "You" : entry.name, size: 40, avatarType: entry.avatarType)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(entry.isCurrentUser ? "You" : entry.name)
                    .font(HLFont.subheadline(entry.isCurrentUser ? .bold : .regular))
                    .foregroundColor(.hlTextPrimary)

                if entry.streak > 0 {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: HLIcon.flame)
                            .font(.system(size: 10))
                            .foregroundColor(.hlFlame)
                        Text("\(entry.streak)d streak")
                            .font(HLFont.caption2())
                            .foregroundColor(.hlTextTertiary)
                    }
                }
            }

            Spacer()

            Text("\(entry.xp) XP")
                .font(HLFont.subheadline(.semibold))
                .foregroundColor(entry.isCurrentUser ? .hlPrimary : .hlTextSecondary)
        }
        .padding(.vertical, HLSpacing.xs)
        .padding(.horizontal, HLSpacing.sm)
        .background(entry.isCurrentUser ? Color.hlPrimaryLight.opacity(0.5) : Color.hlSurface)
        .cornerRadius(HLRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .stroke(entry.isCurrentUser ? Color.hlPrimary.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
        .hlShadow(HLShadow.sm)
        .hlGlow(.hlPrimary, radius: 6, isActive: entry.isCurrentUser)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .hlGold
        case 2: return .hlSilver
        case 3: return .hlBronze
        default: return .hlTextSecondary
        }
    }

    // MARK: - Refresh

    private func refreshLeaderboard() async {
        let friendRecordNames = friends.compactMap(\.cloudKitRecordName)
        guard !friendRecordNames.isEmpty else { return }
        cloudEntries = await cloudKit.fetchLeaderboardData(friendRecordNames: friendRecordNames)
    }
}

// MARK: - Preview

#Preview {
    LeaderboardView()
        .modelContainer(for: [Friend.self, UserProfile.self], inMemory: true)
}
