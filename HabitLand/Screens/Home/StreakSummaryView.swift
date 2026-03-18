import SwiftData
import SwiftUI

// MARK: - Streak Summary View

struct StreakSummaryView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.name)
    private var habits: [Habit]

    @State private var flameScale: CGFloat = 1.0
    @Environment(\.dismiss) private var dismiss

    // MARK: - Display Model

    private struct HabitStreakInfo: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let color: Color
        let currentDays: Int
        let bestDays: Int
        let totalCompletions: Int
        let isAtRisk: Bool
    }

    private var streakEntries: [HabitStreakInfo] {
        habits.map { habit in
            HabitStreakInfo(
                name: habit.name,
                icon: habit.icon,
                color: habit.color,
                currentDays: habit.currentStreak,
                bestDays: habit.bestStreak,
                totalCompletions: habit.totalCompletions,
                isAtRisk: habit.currentStreak > 0 && !habit.todayCompleted
            )
        }
    }

    private var longestStreak: HabitStreakInfo? {
        streakEntries.max(by: { $0.currentDays < $1.currentDays })
    }

    private var atRiskStreaks: [HabitStreakInfo] {
        streakEntries.filter(\.isAtRisk)
    }

    private var activeStreaks: [HabitStreakInfo] {
        streakEntries.filter { $0.currentDays > 0 && !$0.isAtRisk }
            .sorted { $0.currentDays > $1.currentDays }
    }

    private var totalStreakDays: Int {
        streakEntries.reduce(0) { $0 + $1.currentDays }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                if habits.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: HLSpacing.lg) {
                        totalStatsBar
                        if let featured = longestStreak {
                            featuredStreakCard(featured)
                        }
                        if !atRiskStreaks.isEmpty {
                            atRiskSection
                        }
                        activeStreaksSection
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.bottom, HLSpacing.xxxl)
                }
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .navigationTitle("Streaks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: HLIcon.back)
                            .foregroundStyle(Color.hlTextPrimary)
                    }
                }
            }
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
                ) {
                    flameScale = 1.15
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Spacer()
            Image(systemName: HLIcon.flame)
                .font(.system(size: 48))
                .foregroundStyle(Color.hlTextTertiary)
            Text("No habits yet")
                .font(HLFont.title3())
                .foregroundStyle(Color.hlTextSecondary)
            Text("Add your first habit to start building streaks!")
                .font(HLFont.callout())
                .foregroundStyle(Color.hlTextTertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, HLSpacing.lg)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Total Stats Bar

    private var totalStatsBar: some View {
        HStack(spacing: HLSpacing.lg) {
            VStack(spacing: HLSpacing.xxxs) {
                Text("\(streakEntries.filter { $0.currentDays > 0 }.count)")
                    .font(HLFont.title2())
                    .foregroundStyle(Color.hlPrimary)
                Text("Active")
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextTertiary)
            }
            Divider().frame(height: 36)
            VStack(spacing: HLSpacing.xxxs) {
                Text("\(totalStreakDays)")
                    .font(HLFont.title2())
                    .foregroundStyle(Color.hlFlame)
                Text("Total Days")
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextTertiary)
            }
            Divider().frame(height: 36)
            VStack(spacing: HLSpacing.xxxs) {
                Text("\(atRiskStreaks.count)")
                    .font(HLFont.title2())
                    .foregroundStyle(Color.hlWarning)
                Text("At Risk")
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextTertiary)
            }
            Divider().frame(height: 36)
            VStack(spacing: HLSpacing.xxxs) {
                Text("\(longestStreak?.currentDays ?? 0)")
                    .font(HLFont.title2())
                    .foregroundStyle(Color.hlGold)
                Text("Longest")
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .hlCard()
    }

    // MARK: - Featured Streak Card

    private func featuredStreakCard(_ streak: HabitStreakInfo) -> some View {
        VStack(spacing: HLSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.hlFlame.opacity(0.3), Color.hlFlame.opacity(0.05)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(flameScale)

                Image(systemName: HLIcon.flame)
                    .font(.system(size: 52))
                    .foregroundStyle(Color.hlFlame)
                    .scaleEffect(flameScale)
            }

            VStack(spacing: HLSpacing.xxs) {
                Text("Longest Active Streak")
                    .font(HLFont.subheadline())
                    .foregroundStyle(Color.hlTextSecondary)

                HStack(alignment: .firstTextBaseline, spacing: HLSpacing.xxs) {
                    Text("\(streak.currentDays)")
                        .font(HLFont.largeTitle())
                        .foregroundStyle(Color.hlFlame)
                    Text("days")
                        .font(HLFont.title3())
                        .foregroundStyle(Color.hlTextSecondary)
                }

                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: streak.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(streak.color)
                    Text(streak.name)
                        .font(HLFont.callout(.medium))
                        .foregroundStyle(Color.hlTextPrimary)
                }
            }

            HStack(spacing: HLSpacing.xl) {
                VStack(spacing: HLSpacing.xxxs) {
                    Text("\(streak.bestDays)")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlGold)
                    Text("Best Ever")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                }
                VStack(spacing: HLSpacing.xxxs) {
                    Text("\(streak.totalCompletions)")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlInfo)
                    Text("Total Done")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .hlCard(padding: HLSpacing.lg)
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .stroke(Color.hlFlame.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - At Risk Section

    private var atRiskSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hlWarning)
                Text("At Risk")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            Text("Complete these today or lose your streak!")
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextSecondary)

            VStack(spacing: HLSpacing.xs) {
                ForEach(atRiskStreaks) { streak in
                    streakRow(streak, isAtRisk: true)
                }
            }
        }
    }

    // MARK: - Active Streaks Section

    private var activeStreaksSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("All Active Streaks")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            if activeStreaks.isEmpty {
                VStack(spacing: HLSpacing.sm) {
                    Image(systemName: HLIcon.flame)
                        .font(.system(size: 32))
                        .foregroundStyle(Color.hlTextTertiary)
                    Text("No active streaks yet")
                        .font(HLFont.callout())
                        .foregroundStyle(Color.hlTextSecondary)
                    Text("Complete habits daily to build streaks!")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .hlCard(padding: HLSpacing.lg)
            } else {
                VStack(spacing: HLSpacing.xs) {
                    ForEach(activeStreaks) { streak in
                        streakRow(streak, isAtRisk: false)
                    }
                }
            }
        }
    }

    // MARK: - Streak Row

    private func streakRow(_ streak: HabitStreakInfo, isAtRisk: Bool) -> some View {
        HStack(spacing: HLSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: HLRadius.sm)
                    .fill(streak.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: streak.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(streak.color)
            }

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(streak.name)
                    .font(HLFont.callout(.medium))
                    .foregroundStyle(Color.hlTextPrimary)

                HStack(spacing: HLSpacing.xs) {
                    Text("Best: \(streak.bestDays)d")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)

                    if isAtRisk {
                        Text("Expires today!")
                            .font(HLFont.caption2(.semibold))
                            .foregroundStyle(Color.hlWarning)
                    }
                }
            }

            Spacer()

            HStack(spacing: HLSpacing.xxs) {
                Image(systemName: HLIcon.flame)
                    .font(.system(size: 14))
                    .foregroundStyle(isAtRisk ? Color.hlWarning : Color.hlFlame)
                Text("\(streak.currentDays)")
                    .font(HLFont.title3())
                    .foregroundStyle(isAtRisk ? Color.hlWarning : Color.hlFlame)
                Text("days")
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextTertiary)
            }
        }
        .hlCard(padding: HLSpacing.sm)
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .stroke(isAtRisk ? Color.hlWarning.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    StreakSummaryView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
