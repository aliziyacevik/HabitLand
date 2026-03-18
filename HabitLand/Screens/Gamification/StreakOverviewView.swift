import SwiftUI
import SwiftData

struct StreakOverviewView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }) private var habits: [Habit]

    private var activeStreaks: [Habit] {
        habits.filter { $0.currentStreak > 0 }.sorted { $0.currentStreak > $1.currentStreak }
    }

    private var longestStreak: Habit? {
        activeStreaks.first
    }

    private var atRiskStreaks: [Habit] {
        // Habits with a streak that haven't been completed today
        habits.filter { $0.currentStreak > 0 && !$0.todayCompleted }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                summaryHeader
                if let longest = longestStreak {
                    featuredStreakCard(longest)
                }
                if !atRiskStreaks.isEmpty {
                    atRiskSection
                }
                allStreaksSection
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .background(Color.hlBackground)
        .navigationTitle("Streaks")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Summary Header

    @ViewBuilder
    private var summaryHeader: some View {
        HStack(spacing: HLSpacing.lg) {
            VStack(spacing: HLSpacing.xxs) {
                Text("\(activeStreaks.count)")
                    .font(HLFont.largeTitle(.bold))
                    .foregroundStyle(Color.hlFlame)
                Text("Active Streaks")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: HLSpacing.xxs) {
                Text("\(longestStreak?.currentStreak ?? 0)")
                    .font(HLFont.largeTitle(.bold))
                    .foregroundStyle(Color.hlGold)
                Text("Longest Current")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: HLSpacing.xxs) {
                Text("\(habits.map(\.bestStreak).max() ?? 0)")
                    .font(HLFont.largeTitle(.bold))
                    .foregroundStyle(Color.hlPrimary)
                Text("All-Time Best")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .hlCard()
    }

    // MARK: - Featured Streak

    @ViewBuilder
    private func featuredStreakCard(_ habit: Habit) -> some View {
        VStack(spacing: HLSpacing.sm) {
            Image(systemName: HLIcon.flame)
                .font(.system(size: 44))
                .foregroundStyle(Color.hlFlame)
                .symbolEffect(.pulse, isActive: true)

            Text("\(habit.currentStreak) days")
                .font(HLFont.largeTitle(.bold))
                .foregroundStyle(Color.hlTextPrimary)

            Text(habit.name)
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextSecondary)

            Text("Your longest active streak")
                .font(HLFont.footnote())
                .foregroundStyle(Color.hlTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.lg)
        .background(
            LinearGradient(
                colors: [Color.hlFlame.opacity(0.08), Color.hlGold.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .hlCard(padding: HLSpacing.md)
    }

    // MARK: - At Risk

    @ViewBuilder
    private var atRiskSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.hlWarning)
                Text("Streaks at Risk")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            ForEach(atRiskStreaks, id: \.id) { habit in
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: habit.icon)
                        .font(HLFont.body())
                        .foregroundStyle(habit.color)
                        .frame(width: 36, height: 36)
                        .background(habit.color.opacity(0.12), in: RoundedRectangle(cornerRadius: HLRadius.sm))

                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text(habit.name)
                            .font(HLFont.subheadline(.semibold))
                            .foregroundStyle(Color.hlTextPrimary)
                        Text("\(habit.currentStreak) day streak")
                            .font(HLFont.caption())
                            .foregroundStyle(Color.hlTextSecondary)
                    }

                    Spacer()

                    Text("Complete today!")
                        .font(HLFont.caption(.semibold))
                        .foregroundStyle(Color.hlWarning)
                }
                .padding(.vertical, HLSpacing.xxs)

                if habit.id != atRiskStreaks.last?.id {
                    Divider().background(Color.hlDivider)
                }
            }
        }
        .hlCard()
    }

    // MARK: - All Streaks

    @ViewBuilder
    private var allStreaksSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("All Habit Streaks")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            if activeStreaks.isEmpty {
                VStack(spacing: HLSpacing.sm) {
                    Image(systemName: HLIcon.flame)
                        .font(.system(size: 32))
                        .foregroundStyle(Color.hlTextTertiary)
                    Text("No active streaks")
                        .font(HLFont.subheadline())
                        .foregroundStyle(Color.hlTextTertiary)
                    Text("Complete habits consistently to build streaks!")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.lg)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: HLSpacing.sm),
                    GridItem(.flexible(), spacing: HLSpacing.sm)
                ], spacing: HLSpacing.sm) {
                    ForEach(activeStreaks, id: \.id) { habit in
                        streakCard(habit)
                    }
                }
            }
        }
        .hlCard()
    }

    @ViewBuilder
    private func streakCard(_ habit: Habit) -> some View {
        VStack(spacing: HLSpacing.xs) {
            HStack(spacing: HLSpacing.xxs) {
                Image(systemName: HLIcon.flame)
                    .foregroundStyle(Color.hlFlame)
                Text("\(habit.currentStreak)")
                    .font(HLFont.title2())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            Text(habit.name)
                .font(HLFont.caption(.medium))
                .foregroundStyle(Color.hlTextSecondary)
                .lineLimit(1)

            if habit.todayCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(HLFont.footnote())
                    .foregroundStyle(Color.hlPrimary)
            } else {
                Image(systemName: "circle")
                    .font(HLFont.footnote())
                    .foregroundStyle(Color.hlTextTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(HLSpacing.sm)
        .background(Color.hlBackground, in: RoundedRectangle(cornerRadius: HLRadius.md))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StreakOverviewView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
