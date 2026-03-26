import SwiftUI
import SwiftData
import UIKit

// MARK: - Daily Habits Overview

struct DailyHabitsOverview: View {
    @ScaledMetric(relativeTo: .caption) private var tinyIconSize: CGFloat = 9
    @ScaledMetric(relativeTo: .footnote) private var badgeIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .footnote) private var sectionIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var habitIconSize: CGFloat = 20
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.name) private var habits: [Habit]
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: HabitFilter = .all
    @State private var showCelebration = false
    @State private var celebrationMessage = ""
    @State private var xpGainHabitID: String?
    @State private var lastXPGainAmount: Int = 10
    @State private var achievementCelebration: AchievementCelebrationData?
    @State private var levelUpData: LevelUpData?
    @State private var showUndoToast = false
    @State private var showTimer = false
    @ObservedObject private var timerManager = HabitTimerManager.shared
    @State private var showDailyOverviewForHabit: String?
    @State private var undoHabitName = ""
    @State private var undoCompletion: HabitCompletion?
    private var profile: UserProfile? { profiles.first }

    enum HabitFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case completed = "Completed"
    }

    private var completedCount: Int {
        habits.filter(\.todayCompleted).count
    }

    private var totalCount: Int {
        habits.count
    }

    private var completionPercent: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    private var filteredHabits: [Habit] {
        switch selectedFilter {
        case .all:
            return Array(habits)
        case .pending:
            return habits.filter { !$0.todayCompleted }
        case .completed:
            return habits.filter(\.todayCompleted)
        }
    }

    private var groupedHabits: [(String, [Habit])] {
        let grouped = Dictionary(grouping: filteredHabits) { $0.category }
        return HabitCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            return (category.rawValue, items)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressHeader
                filterChips
                habitsList
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .navigationTitle("Today's Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: HLIcon.back)
                            .foregroundStyle(Color.hlTextPrimary)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .overlay {
                CelebrationOverlay(
                    isActive: $showCelebration,
                    message: celebrationMessage,
                    icon: "trophy.fill"
                )
            }
            .overlay {
                AchievementCelebrationOverlay(achievement: $achievementCelebration)
            }
            .overlay {
                LevelUpCelebrationOverlay(levelUpData: $levelUpData)
            }
            .overlay(alignment: .bottom) {
                UndoToast(
                    message: "\(undoHabitName) completed!",
                    onUndo: {
                        if let completion = undoCompletion {
                            modelContext.delete(completion)
                            try? modelContext.save()
                            removeXP(lastXPGainAmount)
                            undoCompletion = nil
                        }
                    },
                    isVisible: $showUndoToast
                )
            }
            .fullScreenCover(isPresented: $showTimer) {
                HabitTimerView(isPresented: $showTimer)
            }
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack {
                Text("\(completedCount) of \(totalCount) completed")
                    .font(HLFont.subheadline(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
                Spacer()
                Text("\(Int(completionPercent * 100))%")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: HLRadius.full)
                        .fill(Color.hlDivider)
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: HLRadius.full)
                        .fill(Color.hlPrimary)
                        .frame(width: geometry.size.width * completionPercent, height: 8)
                        .animation(HLAnimation.standard, value: completionPercent)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, HLSpacing.md)
        .padding(.vertical, HLSpacing.md)
        .background(Color.hlSurface)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HLSpacing.xs) {
                ForEach(HabitFilter.allCases, id: \.self) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.sm)
        }
    }

    private func filterChip(_ filter: HabitFilter) -> some View {
        let isSelected = selectedFilter == filter
        return Button {
            withAnimation(HLAnimation.quick) {
                selectedFilter = filter
            }
        } label: {
            Text(filter.rawValue)
                .font(HLFont.footnote(.medium))
                .foregroundStyle(isSelected ? Color.white : Color.hlTextSecondary)
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.hlPrimary : Color.hlSurface)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.hlDivider, lineWidth: 1)
                )
        }
    }

    // MARK: - Habits List

    private var habitsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: HLSpacing.lg, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedHabits, id: \.0) { sectionTitle, sectionHabits in
                    Section {
                        ForEach(sectionHabits) { habit in
                            habitCard(habit: habit)
                        }
                    } header: {
                        sectionHeader(title: sectionTitle, count: sectionHabits.count)
                    }
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xxxl)
        }
    }

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: sectionIcon(for: title))
                    .font(.system(size: min(badgeIconSize, 18)))
                    .foregroundStyle(Color.hlTextTertiary)
                Text(title)
                    .font(HLFont.footnote(.semibold))
                    .foregroundStyle(Color.hlTextSecondary)
            }
            Spacer()
            Text("\(count) habits")
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextTertiary)
        }
        .padding(.vertical, HLSpacing.xs)
        .padding(.horizontal, HLSpacing.xxs)
        .background(Color.hlBackground)
    }

    private func sectionIcon(for title: String) -> String {
        guard let category = HabitCategory.allCases.first(where: { $0.rawValue == title }) else {
            return HLIcon.clock
        }
        return category.icon
    }

    private func habitCard(habit: Habit) -> some View {
        HStack(spacing: HLSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: HLRadius.sm)
                    .fill(habit.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: habit.icon)
                    .font(.system(size: min(habitIconSize, 24)))
                    .foregroundStyle(habit.color)
            }

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                HStack(spacing: HLSpacing.xs) {
                    Text(habit.name)
                        .font(HLFont.callout(.medium))
                        .foregroundStyle(Color.hlTextPrimary)

                    if habit.currentStreak > 0 {
                        StreakFireView(streak: habit.currentStreak)
                            .frame(width: 22, height: 22)
                    }
                }

                HStack(spacing: HLSpacing.xs) {
                    Text(habit.category.rawValue)
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)

                    if habit.currentStreak > 0 {
                        Text("\(habit.currentStreak)d streak")
                            .font(HLFont.caption2(.semibold))
                            .foregroundStyle(Color.hlFlame)
                    }

                    if habit.mastery != .none {
                        HStack(spacing: 2) {
                            Image(systemName: habit.mastery.icon)
                                .font(.system(size: min(tinyIconSize, 13)))
                            Text(habit.mastery.label)
                                .font(HLFont.caption2(.semibold))
                        }
                        .foregroundStyle(habit.mastery.color)
                    }
                }
            }

            Spacer()

            if xpGainHabitID == habit.id.uuidString {
                XPGainView(amount: lastXPGainAmount)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Timer button for time-based habits
            if habit.unit == "minutes" && habit.goalCount > 0 && !habit.todayCompleted {
                Button {
                    timerManager.start(habit: (
                        id: habit.id,
                        name: habit.name,
                        icon: habit.icon,
                        color: habit.color,
                        minutes: habit.goalCount
                    ))
                    showTimer = true
                    HLHaptics.selection()
                } label: {
                    Image(systemName: "timer")
                        .font(.system(size: min(sectionIconSize, 20), weight: .semibold))
                        .foregroundStyle(habit.color)
                        .frame(width: 32, height: 32)
                        .background(habit.color.opacity(0.12))
                        .clipShape(Circle())
                }
            }

            Button {
                let wasCompleted = habit.todayCompleted
                withAnimation(HLAnimation.celebration) {
                    if wasCompleted {
                        let today = Calendar.current.startOfDay(for: Date())
                        if let completion = habit.safeCompletions.first(where: {
                            Calendar.current.startOfDay(for: $0.date) == today && $0.isCompleted
                        }) {
                            modelContext.delete(completion)
                        }
                    } else {
                        let completion = HabitCompletion(date: Date())
                        completion.habit = habit
                        modelContext.insert(completion)
                    }
                }
                if !wasCompleted {
                    HLHaptics.completionSuccess()
                    ReviewManager.trackCompletion()
                    // Undo toast
                    undoHabitName = habit.name
                    let latestCompletion = habit.safeCompletions.first(where: {
                        Calendar.current.isDateInToday($0.date) && $0.isCompleted
                    })
                    undoCompletion = latestCompletion
                    withAnimation(HLAnimation.quick) {
                        showUndoToast = true
                    }
                    // Daily bonus (first completion of the day)
                    let dailyBonus = claimDailyBonus()

                    // XP gain with streak multiplier + daily bonus
                    let xpAmount = streakXP(for: habit) + dailyBonus
                    lastXPGainAmount = xpAmount
                    gainXP(xpAmount)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        xpGainHabitID = habit.id.uuidString
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        xpGainHabitID = nil
                    }
                    // Daily bonus celebration
                    if dailyBonus > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            let streak = profile?.dailyBonusStreak ?? 1
                            celebrationMessage = "Day \(streak) bonus: +\(dailyBonus) XP"
                            showCelebration = true
                        }
                    }

                    // All-complete celebration
                    let newCompleted = completedCount + 1
                    if newCompleted == totalCount && totalCount > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            celebrationMessage = "All habits done!\nAmazing work today!"
                            showCelebration = true
                            HLHaptics.heavy()
                        }
                    }
                    // Check achievements
                    showAchievementIfNeeded(AchievementManager.checkAll(context: modelContext))
                    // Update weekly quests
                    WeeklyQuestManager.shared.updateProgress(context: modelContext)
                    // Donate to Siri/Spotlight
                    CompleteHabitIntent.donate(habit: habit.toEntity())
                } else {
                    removeXP(streakXP(for: habit))
                    HLHaptics.light()
                }
                try? modelContext.save()
            } label: {
                AnimatedCheckmark(isCompleted: habit.todayCompleted, color: habit.color, size: 28)
            }
            .accessibilityLabel(habit.todayCompleted ? "Mark \(habit.name) incomplete" : "Complete \(habit.name)")
        }
        .hlCard(padding: HLSpacing.sm)
        .contextMenu {
            if habit.unit == "minutes" && habit.goalCount > 0 && !habit.todayCompleted {
                Button {
                    timerManager.start(habit: (
                        id: habit.id,
                        name: habit.name,
                        icon: habit.icon,
                        color: habit.color,
                        minutes: habit.goalCount
                    ))
                    showTimer = true
                } label: {
                    Label("Start Timer", systemImage: "timer")
                }
            }

            Button {
                showDailyOverviewForHabit = habit.id.uuidString
            } label: {
                Label("View Details", systemImage: "info.circle")
            }

            if !habit.todayCompleted {
                Button {
                    addNoteForHabit(habit)
                } label: {
                    Label("Add Note", systemImage: "note.text")
                }
            }
        }
    }

    private func addNoteForHabit(_ habit: Habit) {
        // Opens detail view where notes can be edited
        showDailyOverviewForHabit = habit.id.uuidString
    }

    private func showAchievementIfNeeded(_ unlocked: [Achievement]) {
        guard let first = unlocked.first else { return }
        let totalAchievements = (try? modelContext.fetchCount(FetchDescriptor<Achievement>())) ?? 0
        let unlockedAchievements = (try? modelContext.fetchCount(FetchDescriptor<Achievement>(predicate: #Predicate { $0.isUnlocked }))) ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            achievementCelebration = AchievementCelebrationData(
                name: first.name,
                description: first.descriptionText,
                icon: first.icon,
                unlockedCount: unlockedAchievements,
                totalCount: totalAchievements
            )
        }
        ReviewManager.requestIfAppropriate()
    }

    private func claimDailyBonus() -> Int {
        guard let profile else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Already claimed today
        if let lastDate = profile.lastDailyBonusDate, calendar.isDateInToday(lastDate) {
            return 0
        }

        // Check if streak continues from yesterday
        if let lastDate = profile.lastDailyBonusDate, calendar.isDateInYesterday(lastDate) {
            profile.dailyBonusStreak += 1
        } else {
            profile.dailyBonusStreak = 1
        }
        profile.lastDailyBonusDate = today

        // Bonus scales with streak
        let streak = profile.dailyBonusStreak
        let bonus: Int
        switch streak {
        case 1...2: bonus = 5
        case 3...6: bonus = 15
        case 7...13: bonus = 30
        case 14...29: bonus = 50
        default: bonus = 100  // 30+ day daily streak
        }
        return bonus
    }

    private func streakXP(for habit: Habit) -> Int {
        let streak = habit.currentStreak
        let base = 10
        if streak >= 100 { return base * 3 }      // 30 XP
        if streak >= 30 { return base * 2 }        // 20 XP
        if streak >= 7 { return Int(Double(base) * 1.5) } // 15 XP
        return base                                 // 10 XP
    }

    private func gainXP(_ amount: Int) {
        guard let profile else { return }
        let oldLevel = profile.level
        profile.xp += amount
        while profile.xp >= profile.xpForNextLevel {
            profile.xp -= profile.xpForNextLevel
            profile.level += 1
        }
        if profile.level > oldLevel {
            let newTitle = profile.levelTitle
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                levelUpData = LevelUpData(
                    oldLevel: oldLevel,
                    newLevel: profile.level,
                    newTitle: newTitle
                )
            }
        }
    }

    private func removeXP(_ amount: Int) {
        guard let profile else { return }
        profile.xp -= amount
        while profile.xp < 0 && profile.level > 1 {
            profile.level -= 1
            profile.xp += profile.xpForNextLevel
        }
        profile.xp = max(0, profile.xp)
    }
}

// MARK: - Preview

#Preview {
    DailyHabitsOverview()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
}
