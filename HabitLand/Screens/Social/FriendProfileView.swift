import SwiftUI
import SwiftData

// MARK: - FriendProfileView

struct FriendProfileView: View {
    let name: String
    let username: String
    let avatarEmoji: String
    let level: Int
    let streak: Int

    @Query(sort: \Challenge.name) private var challenges: [Challenge]
    @Query(sort: \Achievement.name) private var achievements: [Achievement]

    private var sharedChallenges: [Challenge] {
        challenges.filter(\.isActive)
    }

    private var unlockedAchievements: [Achievement] {
        achievements.filter(\.isUnlocked)
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    profileHeader
                    statsRow
                    actionButtons

                    if !sharedChallenges.isEmpty {
                        sharedChallengesSection
                    }

                    if !unlockedAchievements.isEmpty {
                        achievementsSection
                    }
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.top, HLSpacing.sm)
                .padding(.bottom, HLSpacing.xxxl)
            }
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: HLSpacing.sm) {
            Text(avatarEmoji)
                .font(.system(size: 72))
                .frame(width: 100, height: 100)
                .background(Color.hlPrimaryLight)
                .cornerRadius(HLRadius.full)

            Text(name)
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text(username)
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)

            levelBadge
        }
        .frame(maxWidth: .infinity)
        .hlCard()
    }

    private var levelBadge: some View {
        HStack(spacing: HLSpacing.xxs) {
            Image(systemName: HLIcon.star)
                .font(.system(size: 12))
            Text("Level \(level) \(levelTitle)")
                .font(HLFont.caption(.bold))
        }
        .foregroundColor(.hlPrimary)
        .padding(.horizontal, HLSpacing.sm)
        .padding(.vertical, HLSpacing.xxs)
        .background(Color.hlPrimaryLight)
        .cornerRadius(HLRadius.full)
    }

    private var levelTitle: String {
        switch level {
        case 1...5: return "Seedling"
        case 6...10: return "Sprout"
        case 11...20: return "Sapling"
        case 21...35: return "Tree"
        case 36...50: return "Forest"
        default: return "Legend"
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(streak)", label: "Day Streak", icon: HLIcon.flame, color: .hlFlame)
            divider
            statItem(value: "\(unlockedAchievements.count)", label: "Achievements", icon: HLIcon.trophy, color: .hlGold)
            divider
            statItem(value: "Lvl \(level)", label: "Level", icon: HLIcon.star, color: .hlPrimary)
        }
        .hlCard()
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            Text(label)
                .font(HLFont.caption2())
                .foregroundColor(.hlTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.hlDivider)
            .frame(width: 1, height: 44)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: HLSpacing.sm) {
            Button {
                // Challenge action
            } label: {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: HLIcon.challenge)
                        .font(.system(size: 14, weight: .semibold))
                    Text("Challenge")
                        .font(HLFont.headline())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.sm)
                .background(Color.hlPrimary)
                .cornerRadius(HLRadius.md)
            }

        }
    }

    // MARK: - Shared Challenges

    private var sharedChallengesSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Shared Challenges")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(sharedChallenges) { challenge in
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: challenge.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.hlPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.hlPrimaryLight)
                        .cornerRadius(HLRadius.sm)

                    VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                        Text(challenge.name)
                            .font(HLFont.subheadline(.medium))
                            .foregroundColor(.hlTextPrimary)

                        ProgressView(value: challenge.progress)
                            .tint(.hlPrimary)
                    }

                    Text("\(challenge.daysRemaining)d left")
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlTextSecondary)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("Achievements")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                Spacer()
                Text("\(unlockedAchievements.count) earned")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextTertiary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: HLSpacing.sm) {
                ForEach(unlockedAchievements) { achievement in
                    VStack(spacing: HLSpacing.xxs) {
                        Image(systemName: achievement.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.hlGold)
                            .frame(width: 48, height: 48)
                            .background(Color.hlGold.opacity(0.12))
                            .cornerRadius(HLRadius.md)

                        Text(achievement.name)
                            .font(HLFont.caption2(.medium))
                            .foregroundColor(.hlTextPrimary)
                            .lineLimit(1)

                        if let date = achievement.unlockedAt {
                            Text(date.formatted(.dateTime.month(.abbreviated).day()))
                                .font(HLFont.caption2())
                                .foregroundColor(.hlTextTertiary)
                        }
                    }
                }
            }
        }
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FriendProfileView(
            name: "Alex Rivera",
            username: "@alexr",
            avatarEmoji: "🦊",
            level: 12,
            streak: 23
        )
    }
    .modelContainer(for: [Challenge.self, Achievement.self], inMemory: true)
}
