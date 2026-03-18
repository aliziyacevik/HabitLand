import SwiftUI
import SwiftData

// MARK: - Leaderboard Entry (display model)

private struct RankedEntry: Identifiable {
    let id: UUID
    let rank: Int
    let name: String
    let avatarEmoji: String
    let score: Int
    let isCurrentUser: Bool
}

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

    @State private var selectedPeriod: TimePeriod = .week

    private var profile: UserProfile? { profiles.first }

    private var entries: [RankedEntry] {
        // Build entries from friends + current user
        var all: [(name: String, emoji: String, score: Int, isCurrent: Bool, id: UUID)] = []

        // Add current user
        if let p = profile {
            all.append((p.name.isEmpty ? "You" : p.name, p.avatarEmoji, p.xp, true, p.id))
        }

        // Add friends
        for friend in friends {
            // Estimate XP from level (level * 50 + streak * 5 as approximation)
            let estimatedXP = friend.level * 50 + friend.currentStreak * 5
            all.append((friend.name, friend.avatarEmoji, estimatedXP, false, friend.id))
        }

        // Sort by score descending
        all.sort { $0.score > $1.score }

        // Assign ranks
        return all.enumerated().map { index, item in
            RankedEntry(
                id: item.id,
                rank: index + 1,
                name: item.isCurrent ? "You" : item.name,
                avatarEmoji: item.emoji,
                score: item.score,
                isCurrentUser: item.isCurrent
            )
        }
    }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Leaderboard")
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
                podiumPlace(entry: entries[1], color: .hlSilver, height: 80, crownIcon: nil)
                podiumPlace(entry: entries[0], color: .hlGold, height: 100, crownIcon: HLIcon.crown)
                podiumPlace(entry: entries[2], color: .hlBronze, height: 64, crownIcon: nil)
            } else if entries.count == 2 {
                podiumPlace(entry: entries[0], color: .hlGold, height: 100, crownIcon: HLIcon.crown)
                podiumPlace(entry: entries[1], color: .hlSilver, height: 80, crownIcon: nil)
            } else if entries.count == 1 {
                podiumPlace(entry: entries[0], color: .hlGold, height: 100, crownIcon: HLIcon.crown)
            }
        }
        .hlCard()
    }

    private func podiumPlace(entry: RankedEntry, color: Color, height: CGFloat, crownIcon: String?) -> some View {
        VStack(spacing: HLSpacing.xs) {
            if let crown = crownIcon {
                Image(systemName: crown)
                    .font(.system(size: 20))
                    .foregroundColor(.hlGold)
            }

            Text(entry.avatarEmoji)
                .font(.system(size: 36))
                .frame(width: 56, height: 56)
                .background(color.opacity(0.15))
                .cornerRadius(HLRadius.full)
                .overlay(
                    Circle().stroke(color, lineWidth: 3)
                )

            Text(entry.name)
                .font(HLFont.caption(.semibold))
                .foregroundColor(.hlTextPrimary)
                .lineLimit(1)

            Text("\(entry.score) XP")
                .font(HLFont.caption2(.medium))
                .foregroundColor(.hlTextSecondary)

            RoundedRectangle(cornerRadius: HLRadius.sm)
                .fill(color.opacity(0.2))
                .frame(height: height)
                .overlay(
                    Text("#\(entry.rank)")
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
                rankRow(entry)
                    .hlStaggeredAppear(index: index)
            }
        }
    }

    private func rankRow(_ entry: RankedEntry) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Text("\(entry.rank)")
                .font(HLFont.headline())
                .foregroundColor(rankColor(entry.rank))
                .frame(width: 28, alignment: .center)

            Text(entry.avatarEmoji)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(entry.isCurrentUser ? Color.hlPrimaryLight : Color.hlBackground)
                .cornerRadius(HLRadius.full)

            Text(entry.name)
                .font(HLFont.subheadline(entry.isCurrentUser ? .bold : .regular))
                .foregroundColor(.hlTextPrimary)

            Spacer()

            Text("\(entry.score) XP")
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
}

// MARK: - Preview

#Preview {
    LeaderboardView()
        .modelContainer(for: [Friend.self, UserProfile.self], inMemory: true)
}
