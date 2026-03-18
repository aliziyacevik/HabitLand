import SwiftUI
import SwiftData

struct AchievementsShowcaseView: View {
    @Query(sort: \Achievement.name) private var achievements: [Achievement]
    @State private var selectedCategory: AchievementCategory? = nil

    private var filteredAchievements: [Achievement] {
        if let cat = selectedCategory {
            return achievements.filter { $0.category == cat }
        }
        return achievements
    }

    private var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    private var progressPercent: Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedCount) / Double(achievements.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                if achievements.isEmpty {
                    emptyState
                } else {
                    summaryCard
                    categoryFilter
                    achievementsGrid
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.md)
        }
        .background(Color.hlBackground)
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Spacer().frame(height: 80)

            ZStack {
                Circle()
                    .fill(Color.hlGold.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: HLIcon.trophy)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.hlGold.opacity(0.5))
            }

            Text("No achievements yet")
                .font(HLFont.title3(.semibold))
                .foregroundStyle(Color.hlTextPrimary)

            Text("Complete habits and build streaks\nto unlock achievements.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        HStack(spacing: HLSpacing.lg) {
            VStack(spacing: HLSpacing.xxs) {
                Text("\(unlockedCount)")
                    .font(HLFont.largeTitle())
                    .foregroundColor(.hlPrimary)
                Text("Unlocked")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            ZStack {
                Circle()
                    .stroke(Color.hlDivider, lineWidth: 6)
                    .frame(width: 64, height: 64)
                Circle()
                    .trim(from: 0, to: progressPercent)
                    .stroke(Color.hlPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(-90))
                    .animation(HLAnimation.progressFill, value: progressPercent)
                Text("\(Int(progressPercent * 100))%")
                    .font(HLFont.caption(.bold))
                    .foregroundColor(.hlPrimary)
            }

            VStack(spacing: HLSpacing.xxs) {
                Text("\(achievements.count)")
                    .font(HLFont.largeTitle())
                    .foregroundColor(.hlTextPrimary)
                Text("Total")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .hlCard()
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HLSpacing.xs) {
                filterChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(AchievementCategory.allCases, id: \.self) { cat in
                    filterChip(title: cat.rawValue, isSelected: selectedCategory == cat) {
                        selectedCategory = cat
                    }
                }
            }
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(HLFont.subheadline(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .hlTextSecondary)
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.xs)
                .background(isSelected ? Color.hlPrimary : Color.hlSurface)
                .cornerRadius(HLRadius.full)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.full)
                        .stroke(isSelected ? Color.clear : Color.hlDivider, lineWidth: 1)
                )
        }
    }

    // MARK: - Grid

    private var achievementsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HLSpacing.sm) {
            ForEach(Array(filteredAchievements.enumerated()), id: \.element.id) { index, achievement in
                achievementTile(achievement)
                    .hlStaggeredAppear(index: index)
            }
        }
    }

    private func achievementTile(_ a: Achievement) -> some View {
        VStack(spacing: HLSpacing.sm) {
            ZStack {
                Circle()
                    .fill(a.isUnlocked ? Color.hlGold.opacity(0.15) : Color.hlDivider.opacity(0.5))
                    .frame(width: 56, height: 56)

                Image(systemName: a.isUnlocked ? a.icon : "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(a.isUnlocked ? .hlGold : .hlTextTertiary)
            }
            .hlGlow(.hlGold, radius: 8, isActive: a.isUnlocked)

            Text(a.name)
                .font(HLFont.subheadline(.semibold))
                .foregroundColor(a.isUnlocked ? .hlTextPrimary : .hlTextTertiary)

            Text(a.descriptionText)
                .font(HLFont.caption2())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if !a.isUnlocked {
                ProgressView(value: a.progress)
                    .tint(.hlPrimary)
                Text("\(Int(a.progress * 100))%")
                    .font(HLFont.caption2(.medium))
                    .foregroundColor(.hlTextTertiary)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.hlPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .hlCard(padding: HLSpacing.sm)
    }
}

#Preview {
    NavigationStack {
        AchievementsShowcaseView()
            .modelContainer(for: Achievement.self, inMemory: true)
    }
}
