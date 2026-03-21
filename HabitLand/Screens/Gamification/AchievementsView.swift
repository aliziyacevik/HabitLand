import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query(sort: \Achievement.name) private var achievements: [Achievement]
    @ObservedObject private var proManager = ProManager.shared
    @State private var selectedCategory: AchievementCategory?
    @State private var showPaywall = false

    private var filteredAchievements: [Achievement] {
        guard let category = selectedCategory else { return achievements }
        return achievements.filter { $0.category == category }
    }

    private var unlockedAchievements: [Achievement] {
        filteredAchievements.filter(\.isUnlocked)
    }

    private var lockedAchievements: [Achievement] {
        filteredAchievements.filter { !$0.isUnlocked }
    }

    private let columns = [
        GridItem(.flexible(), spacing: HLSpacing.sm),
        GridItem(.flexible(), spacing: HLSpacing.sm),
        GridItem(.flexible(), spacing: HLSpacing.sm)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                statsHeader
                categoryFilter
                if !unlockedAchievements.isEmpty {
                    achievementSection(title: "Unlocked", achievements: unlockedAchievements, isLocked: false)
                }
                if !lockedAchievements.isEmpty {
                    achievementSection(title: "Locked", achievements: lockedAchievements, isLocked: true)
                }
                if filteredAchievements.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .background(Color.hlBackground)
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            PaywallView(context: .achievements)
                .hlSheetContent()
        }
    }

    // MARK: - Stats Header

    @ViewBuilder
    private var statsHeader: some View {
        HStack(spacing: HLSpacing.lg) {
            VStack(spacing: HLSpacing.xxs) {
                Text("\(unlockedAchievements.count)")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlGold)
                Text("Unlocked")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: HLSpacing.xxs) {
                Text("\(achievements.count)")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlTextSecondary)
                Text("Total")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: HLSpacing.xxs) {
                let pct = achievements.isEmpty ? 0 : Int((Double(achievements.filter(\.isUnlocked).count) / Double(achievements.count)) * 100)
                Text("\(pct)%")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlPrimary)
                Text("Complete")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .hlCard()
    }

    // MARK: - Category Filter

    @ViewBuilder
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HLSpacing.xs) {
                filterChip(label: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    filterChip(label: category.rawValue, isSelected: selectedCategory == category) {
                        withAnimation(HLAnimation.quick) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(HLFont.footnote(.semibold))
                .foregroundStyle(isSelected ? .white : Color.hlTextSecondary)
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xs)
                .background(
                    Capsule().fill(isSelected ? Color.hlSleep : Color.hlSurface)
                )
                .overlay(Capsule().stroke(isSelected ? Color.clear : Color.hlDivider, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Achievement Section

    @ViewBuilder
    private func achievementSection(title: String, achievements: [Achievement], isLocked: Bool) -> some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text(title)
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            LazyVGrid(columns: columns, spacing: HLSpacing.sm) {
                ForEach(Array(achievements.enumerated()), id: \.element.id) { index, achievement in
                    achievementBadge(achievement, isLocked: isLocked)
                        .hlStaggeredAppear(index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func achievementBadge(_ achievement: Achievement, isLocked: Bool) -> some View {
        let rarity = AchievementRarity.forAchievement(achievement.name)
        let badgeColor = isLocked ? Color.hlDivider : rarity.color

        VStack(spacing: HLSpacing.xs) {
            ZStack {
                Circle()
                    .fill(isLocked ? Color.hlDivider : rarity.color.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: achievement.icon)
                    .font(.system(size: 26))
                    .foregroundStyle(isLocked ? Color.hlTextTertiary : rarity.color)
            }
            .overlay {
                Circle()
                    .stroke(badgeColor.opacity(isLocked ? 1.0 : 0.6), lineWidth: isLocked ? 2 : 2.5)
                    .frame(width: 64, height: 64)
            }
            .hlGlow(rarity.color, radius: isLocked ? 0 : (rarity == .legendary ? 12 : rarity == .epic ? 8 : 4), isActive: !isLocked)

            Text(achievement.name)
                .font(HLFont.caption(.semibold))
                .foregroundStyle(isLocked ? Color.hlTextTertiary : Color.hlTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if isLocked {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.hlDivider)
                            .frame(height: 4)
                        Capsule()
                            .fill(rarity.color)
                            .frame(width: geo.size.width * achievement.progress, height: 4)
                    }
                }
                .frame(height: 4)
            } else {
                // Rarity label
                HStack(spacing: 2) {
                    Image(systemName: rarity.icon)
                        .font(.system(size: 8))
                    Text(rarity.rawValue)
                        .font(HLFont.caption2(.medium))
                }
                .foregroundStyle(rarity.color)
            }
        }
        .padding(HLSpacing.sm)
        .background(Color.hlSurface, in: RoundedRectangle(cornerRadius: HLRadius.md))
        .onTapGesture {
            if isLocked && !proManager.isPro {
                showPaywall = true
                HLHaptics.medium()
            }
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: HLIcon.trophy)
                .font(.system(size: 44))
                .foregroundStyle(Color.hlTextTertiary)
            Text("No achievements yet")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextSecondary)
            Text("Complete habits and build streaks to unlock achievements!")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.xxxl)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AchievementsView()
    }
    .modelContainer(for: Achievement.self, inMemory: true)
}
