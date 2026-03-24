import SwiftUI
import SwiftData

struct MilestonesView: View {
    @ScaledMetric(relativeTo: .title) private var emptyIconSize: CGFloat = 44
    @ScaledMetric(relativeTo: .caption) private var dotSize: CGFloat = 8
    @Query(filter: #Predicate<Habit> { !$0.isArchived }) private var habits: [Habit]

    private let milestoneDefinitions: [(days: Int, title: String, tier: MilestoneTier)] = [
        (7, "One Week", .bronze),
        (14, "Two Weeks", .bronze),
        (30, "One Month", .silver),
        (60, "Two Months", .silver),
        (100, "Century", .gold),
        (180, "Half Year", .gold),
        (365, "One Year", .gold),
    ]

    private var milestones: [MilestoneItem] {
        var items: [MilestoneItem] = []
        for habit in habits {
            let best = habit.bestStreak
            let current = habit.currentStreak
            for def in milestoneDefinitions {
                let achieved = best >= def.days
                let progress = achieved ? 1.0 : min(Double(current) / Double(def.days), 0.99)
                items.append(MilestoneItem(
                    habitName: habit.name,
                    habitIcon: habit.icon,
                    habitColor: habit.color,
                    days: def.days,
                    title: def.title,
                    tier: def.tier,
                    isAchieved: achieved,
                    progress: progress,
                    achievedDate: achieved ? Calendar.current.date(byAdding: .day, value: -(best - def.days), to: Date()) : nil
                ))
            }
        }
        // Sort: achieved first (most recent), then upcoming (most progress)
        return items.sorted { a, b in
            if a.isAchieved != b.isAchieved { return a.isAchieved }
            if a.isAchieved && b.isAchieved { return a.days > b.days }
            return a.progress > b.progress
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                tierLegend

                if milestones.isEmpty {
                    emptyState
                } else {
                    timelineView
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .background(Color.hlBackground)
        .navigationTitle("Milestones")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Tier Legend

    @ViewBuilder
    private var tierLegend: some View {
        HStack(spacing: HLSpacing.lg) {
            tierBadge(.bronze)
            tierBadge(.silver)
            tierBadge(.gold)
        }
        .hlCard()
        .padding(.bottom, HLSpacing.md)
    }

    @ViewBuilder
    private func tierBadge(_ tier: MilestoneTier) -> some View {
        HStack(spacing: HLSpacing.xxs) {
            Circle()
                .fill(tier.color)
                .frame(width: 12, height: 12)
            Text(tier.label)
                .font(HLFont.caption(.semibold))
                .foregroundStyle(Color.hlTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Timeline

    @ViewBuilder
    private var timelineView: some View {
        VStack(spacing: 0) {
            ForEach(Array(milestones.enumerated()), id: \.offset) { index, milestone in
                HStack(alignment: .top, spacing: HLSpacing.md) {
                    // Timeline line and dot
                    VStack(spacing: 0) {
                        Circle()
                            .fill(milestone.isAchieved ? milestone.tier.color : Color.hlDivider)
                            .frame(width: 16, height: 16)
                            .overlay {
                                if milestone.isAchieved {
                                    Image(systemName: HLIcon.checkmark)
                                        .font(.system(size: min(dotSize, 12), weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }

                        if index < milestones.count - 1 {
                            Rectangle()
                                .fill(Color.hlDivider)
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 16)

                    // Content card
                    milestoneCard(milestone)
                        .padding(.bottom, HLSpacing.sm)
                }
            }
        }
    }

    @ViewBuilder
    private func milestoneCard(_ milestone: MilestoneItem) -> some View {
        HStack(spacing: HLSpacing.sm) {
            // Tier badge
            ZStack {
                Circle()
                    .fill(milestone.isAchieved ? milestone.tier.color.opacity(0.15) : Color.hlDivider)
                    .frame(width: 44, height: 44)

                Image(systemName: milestone.isAchieved ? HLIcon.medal : milestone.habitIcon)
                    .font(HLFont.body(.semibold))
                    .foregroundStyle(milestone.isAchieved ? milestone.tier.color : Color.hlTextTertiary)
            }

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                HStack(spacing: HLSpacing.xxs) {
                    Text("\(milestone.days)-Day")
                        .font(HLFont.headline())
                        .foregroundStyle(milestone.isAchieved ? Color.hlTextPrimary : Color.hlTextTertiary)
                    Text(milestone.title)
                        .font(HLFont.subheadline())
                        .foregroundStyle(Color.hlTextSecondary)
                }

                Text(milestone.habitName)
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)

                if milestone.isAchieved {
                    if let date = milestone.achievedDate {
                        Text("Achieved \(date, format: .dateTime.month(.abbreviated).day().year())")
                            .font(HLFont.caption2())
                            .foregroundStyle(milestone.tier.color)
                    }
                } else {
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.hlDivider)
                            Capsule()
                                .fill(milestone.tier.color.opacity(0.6))
                                .frame(width: geo.size.width * milestone.progress)
                        }
                    }
                    .frame(height: 4)
                    .padding(.top, HLSpacing.xxxs)

                    Text(String(format: "%.0f%% complete", milestone.progress * 100))
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }

            Spacer(minLength: 0)
        }
        .hlCard()
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: HLIcon.medal)
                .font(.system(size: min(emptyIconSize, 52)))
                .foregroundStyle(Color.hlTextTertiary)
            Text("No milestones yet")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextSecondary)
            Text("Add habits and build streaks to reach milestones!")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.xxxl)
    }
}

// MARK: - Supporting Types

private struct MilestoneItem {
    let habitName: String
    let habitIcon: String
    let habitColor: Color
    let days: Int
    let title: String
    let tier: MilestoneTier
    let isAchieved: Bool
    let progress: Double
    let achievedDate: Date?
}

private enum MilestoneTier {
    case bronze, silver, gold

    var color: Color {
        switch self {
        case .bronze: return .hlBronze
        case .silver: return .hlSilver
        case .gold: return .hlGold
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

// MARK: - Preview

#Preview {
    NavigationStack {
        MilestonesView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
