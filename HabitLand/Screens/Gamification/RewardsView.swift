import SwiftUI
import SwiftData

struct RewardsView: View {
    @Query private var profiles: [UserProfile]

    private var userXP: Int { profiles.first?.xp ?? 0 }

    @State private var selectedTab: RewardTab = .available
    @State private var claimedRewardIDs: Set<UUID> = []

    private var availableRewards: [RewardItem] {
        Self.allRewards.filter { !claimedRewardIDs.contains($0.id) }
    }

    private var claimedRewards: [RewardItem] {
        Self.allRewards.filter { claimedRewardIDs.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                xpBalanceCard
                tabSelector
                rewardsList
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .background(Color.hlBackground)
        .navigationTitle("Rewards")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - XP Balance

    @ViewBuilder
    private var xpBalanceCard: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: HLIcon.bolt)
                .font(.system(size: 28))
                .foregroundStyle(Color.hlGold)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text("Your Balance")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
                Text("\(userXP) XP")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            Spacer()

            Image(systemName: HLIcon.gift)
                .font(.system(size: 24))
                .foregroundStyle(Color.hlPrimary.opacity(0.5))
        }
        .hlCard()
    }

    // MARK: - Tab Selector

    @ViewBuilder
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(RewardTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(HLAnimation.quick) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: HLSpacing.xxs) {
                        Text(tab.title)
                            .font(HLFont.subheadline(selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(selectedTab == tab ? Color.hlSleep : Color.hlTextTertiary)

                        Rectangle()
                            .fill(selectedTab == tab ? Color.hlSleep : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Rewards List

    @ViewBuilder
    private var rewardsList: some View {
        let rewards = selectedTab == .available ? availableRewards : claimedRewards

        if rewards.isEmpty {
            VStack(spacing: HLSpacing.md) {
                Image(systemName: selectedTab == .available ? HLIcon.gift : HLIcon.star)
                    .font(.system(size: 44))
                    .foregroundStyle(Color.hlTextTertiary)

                Text(selectedTab == .available ? "No rewards available" : "No claimed rewards yet")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextSecondary)

                Text(selectedTab == .available ? "Check back later for new rewards!" : "Claim rewards from the available tab to see them here.")
                    .font(HLFont.subheadline())
                    .foregroundStyle(Color.hlTextTertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.xxxl)
        } else {
            LazyVStack(spacing: HLSpacing.sm) {
                ForEach(rewards) { reward in
                    rewardCard(reward)
                }
            }
        }
    }

    // MARK: - Reward Card

    @ViewBuilder
    private func rewardCard(_ reward: RewardItem) -> some View {
        let isClaimed = claimedRewardIDs.contains(reward.id)
        let canAfford = userXP >= reward.xpCost

        HStack(spacing: HLSpacing.sm) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .fill(reward.color.opacity(0.12))
                    .frame(width: 56, height: 56)

                Text(reward.emoji)
                    .font(HLFont.title1())
            }

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(reward.name)
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)

                Text(reward.description)
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextSecondary)
                    .lineLimit(2)

                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: HLIcon.bolt)
                        .font(HLFont.caption2(.bold))
                    Text("\(reward.xpCost) XP")
                        .font(HLFont.footnote(.semibold))
                }
                .foregroundStyle(Color.hlGold)
            }

            Spacer()

            if isClaimed {
                Image(systemName: "checkmark.circle.fill")
                    .font(HLFont.title3())
                    .foregroundStyle(Color.hlPrimary)
            } else {
                Button {
                    withAnimation(HLAnimation.spring) {
                        _ = claimedRewardIDs.insert(reward.id)
                    }
                } label: {
                    Text("Claim")
                        .font(HLFont.footnote(.bold))
                        .foregroundStyle(canAfford ? .white : Color.hlTextTertiary)
                        .padding(.horizontal, HLSpacing.sm)
                        .padding(.vertical, HLSpacing.xs)
                        .background(
                            canAfford ? Color.hlSleep : Color.hlDivider,
                            in: Capsule()
                        )
                }
                .disabled(!canAfford)
            }
        }
        .hlCard()
    }

    // MARK: - Sample Rewards

    static let allRewards: [RewardItem] = [
        RewardItem(name: "Cool Astronaut Avatar", description: "Unlock a custom astronaut avatar for your profile.", emoji: "🧑‍🚀", xpCost: 200, color: .hlInfo, category: .avatar),
        RewardItem(name: "Nature Theme", description: "A calming nature-inspired color theme for the app.", emoji: "🌿", xpCost: 300, color: .hlPrimary, category: .theme),
        RewardItem(name: "Golden Badge Frame", description: "A shiny gold frame around your profile badge.", emoji: "🏅", xpCost: 500, color: .hlGold, category: .badge),
        RewardItem(name: "Wizard Avatar", description: "A magical wizard avatar to show off your dedication.", emoji: "🧙‍♂️", xpCost: 250, color: .hlMindfulness, category: .avatar),
        RewardItem(name: "Sunset Theme", description: "Warm sunset gradients for a cozy feel.", emoji: "🌅", xpCost: 350, color: .hlFlame, category: .theme),
        RewardItem(name: "Diamond Badge", description: "A rare diamond badge visible on your profile.", emoji: "💎", xpCost: 1000, color: .hlInfo, category: .badge),
        RewardItem(name: "Robot Avatar", description: "A fun robot character for your profile pic.", emoji: "🤖", xpCost: 150, color: .hlSleep, category: .avatar),
        RewardItem(name: "Midnight Theme", description: "Dark and sleek midnight theme with purple accents.", emoji: "🌙", xpCost: 400, color: .hlSleep, category: .theme),
        RewardItem(name: "Confetti Celebration", description: "Trigger confetti animations when you complete habits!", emoji: "🎉", xpCost: 600, color: .hlWarning, category: .badge),
        RewardItem(name: "Phoenix Badge", description: "Rise from the ashes with this legendary badge.", emoji: "🔥", xpCost: 800, color: .hlFlame, category: .badge),
    ]
}

// MARK: - Supporting Types

struct RewardItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let emoji: String
    let xpCost: Int
    let color: Color
    let category: RewardCategory
}

enum RewardCategory: String, CaseIterable {
    case avatar = "Avatar"
    case badge = "Badge"
    case theme = "Theme"
}

private enum RewardTab: String, CaseIterable {
    case available
    case claimed

    var title: String {
        switch self {
        case .available: return "Available"
        case .claimed: return "Claimed"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RewardsView()
    }
    .modelContainer(for: UserProfile.self, inMemory: true)
}
