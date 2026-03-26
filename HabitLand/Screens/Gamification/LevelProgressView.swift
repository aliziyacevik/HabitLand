import SwiftUI
import SwiftData

struct LevelProgressView: View {
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    private let levelTitles: [(range: ClosedRange<Int>, title: String, emoji: String)] = [
        (1...5, "Seedling", "🌱"),
        (6...10, "Sprout", "🌿"),
        (11...20, "Sapling", "🌳"),
        (21...35, "Tree", "🌲"),
        (36...50, "Forest", "🏔️"),
        (51...999, "Legend", "👑"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                levelBadgeCard
                    .hlStaggeredAppear(index: 0)
                xpProgressCard
                    .hlStaggeredAppear(index: 1)
                milestonesReachedCard
                    .hlStaggeredAppear(index: 2)
                levelTiersCard
                    .hlStaggeredAppear(index: 3)
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .refreshable {}
        .background(Color.hlBackground)
        .navigationTitle("Level Progress")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Level Badge

    @ViewBuilder
    private var levelBadgeCard: some View {
        let level = profile?.level ?? 1
        let title = profile?.levelTitle ?? "Seedling"
        let emoji = levelTitles.first(where: { $0.range.contains(level) })?.emoji ?? "🌱"

        VStack(spacing: HLSpacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.hlPrimary.opacity(0.2), Color.hlGold.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Circle()
                    .stroke(Color.hlGold.opacity(0.5), lineWidth: 3)
                    .frame(width: 120, height: 120)

                // Progress ring
                Circle()
                    .trim(from: 0, to: profile?.levelProgress ?? 0)
                    .stroke(Color.hlGold, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: HLSpacing.xxxs) {
                    Text(emoji)
                        .font(HLFont.largeTitle())
                    Text("Lv.\(level)")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                        .minimumScaleFactor(0.75)
                }
            }

            Text(title)
                .font(HLFont.title2())
                .foregroundStyle(Color.hlTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.lg)
        .hlCard()
    }

    // MARK: - XP Progress

    @ViewBuilder
    private var xpProgressCard: some View {
        let xp = profile?.xp ?? 0
        let needed = profile?.xpForNextLevel ?? 100
        let progress = profile?.levelProgress ?? 0

        VStack(spacing: HLSpacing.sm) {
            HStack {
                Text("Experience Points")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Spacer()
                Text("\(xp) / \(needed) XP")
                    .font(HLFont.subheadline(.semibold))
                    .foregroundStyle(Color.hlGold)
                    .minimumScaleFactor(0.75)
            }

            // XP bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: HLRadius.sm)
                        .fill(Color.hlDivider)

                    RoundedRectangle(cornerRadius: HLRadius.sm)
                        .fill(
                            LinearGradient(
                                colors: [Color.hlGold, Color.hlFlame],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                        .hlShimmer()
                }
            }
            .frame(height: 14)

            HStack {
                Text("\(needed - xp) XP to next level")
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextSecondary)
                Spacer()
                Text(String(format: "%.0f%%", progress * 100))
                    .font(HLFont.caption(.semibold))
                    .foregroundStyle(Color.hlTextSecondary)
                    .minimumScaleFactor(0.75)
            }
        }
        .hlCard()
    }

    // MARK: - Milestones Reached

    @ViewBuilder
    private var milestonesReachedCard: some View {
        let level = profile?.level ?? 1

        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Level History")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            ForEach(levelTitles, id: \.title) { tier in
                let isReached = level >= tier.range.lowerBound
                let isCurrent = tier.range.contains(level)

                HStack(spacing: HLSpacing.sm) {
                    Text(tier.emoji)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(isReached ? Color.hlGold.opacity(0.15) : Color.hlDivider)
                        )

                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text(tier.title)
                            .font(HLFont.subheadline(isCurrent ? .bold : .regular))
                            .foregroundStyle(isReached ? Color.hlTextPrimary : Color.hlTextTertiary)
                        Text("Level \(tier.range.lowerBound) - \(min(tier.range.upperBound, 50))\(tier.range.upperBound > 50 ? "+" : "")")
                            .font(HLFont.caption())
                            .foregroundStyle(Color.hlTextTertiary)
                    }

                    Spacer()

                    if isCurrent {
                        Text("Current")
                            .font(HLFont.caption(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, HLSpacing.sm)
                            .padding(.vertical, HLSpacing.xxs)
                            .background(Color.hlPrimary, in: Capsule())
                    } else if isReached {
                        Image(systemName: HLIcon.checkmark)
                            .font(HLFont.footnote(.bold))
                            .foregroundStyle(Color.hlPrimary)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(HLFont.footnote())
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                }

                if tier.title != levelTitles.last?.title {
                    Divider().background(Color.hlDivider)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Level Tiers Explanation

    @ViewBuilder
    private var levelTiersCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: HLIcon.info)
                    .foregroundStyle(Color.hlInfo)
                Text("How Leveling Works")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                xpInfoRow(action: "Complete a habit", xp: "+10 XP")
                xpInfoRow(action: "Maintain a streak day", xp: "+5 XP")
                xpInfoRow(action: "Unlock achievement", xp: "+25 XP")
                xpInfoRow(action: "Log sleep", xp: "+10 XP")
                xpInfoRow(action: "Complete a challenge", xp: "+50 XP")
            }
        }
        .hlCard()
    }

    @ViewBuilder
    private func xpInfoRow(action: String, xp: String) -> some View {
        HStack {
            Text(action)
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
            Spacer()
            Text(xp)
                .font(HLFont.subheadline(.semibold))
                .foregroundStyle(Color.hlGold)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LevelProgressView()
    }
    .modelContainer(for: UserProfile.self, inMemory: true)
}
