import SwiftUI
import SwiftData
import UIKit

// MARK: - Home Dashboard View

struct HomeDashboardView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.name) private var habits: [Habit]
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @State private var showDailyOverview = false
    @State private var showWeeklyProgress = false
    @State private var showNotifications = false
    @State private var showCelebration = false
    @State private var celebrationMessage = ""
    @State private var xpGainHabitID: String?
    @State private var showCreateHabit = false
    @State private var showPomodoro = false
    @State private var showChain = false
    @State private var showPaywall = false
    @State private var showUndoToast = false
    @State private var undoHabitName = ""
    @State private var undoCompletion: HabitCompletion?
    @State private var achievementCelebration: AchievementCelebrationData?
    @State private var levelUpData: LevelUpData?
    @ObservedObject private var proManager = ProManager.shared
    @ObservedObject private var questManager = WeeklyQuestManager.shared

    // MARK: - Computed Properties

    private var profile: UserProfile? { profiles.first }
    private var userName: String { profile?.name ?? "User" }
    private var completedCount: Int { habits.filter(\.todayCompleted).count }
    private var totalCount: Int { habits.count }
    private var streakDays: Int { habits.map(\.currentStreak).max() ?? 0 }
    private var bestStreak: Int { habits.map(\.bestStreak).max() ?? 0 }

    private var completionPercent: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    private var progressStatusText: String {
        if completedCount == totalCount && totalCount > 0 { return "All done!" }
        if completionPercent >= 0.5 { return "On track today!" }
        if completedCount > 0 { return "Keep going!" }
        return "Let's get started!"
    }

    private var progressStatusIcon: String {
        if completedCount == totalCount && totalCount > 0 { return "checkmark.seal.fill" }
        if completionPercent >= 0.5 { return HLIcon.trendUp }
        return "arrow.right.circle"
    }

    private var progressStatusColor: Color {
        if completedCount == totalCount && totalCount > 0 { return Color.hlSuccess }
        if completionPercent >= 0.5 { return Color.hlSuccess }
        if completedCount > 0 { return Color.hlInfo }
        return Color.hlTextTertiary
    }

    private var greeting: String {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-screenshotMode") {
            return "Good morning"
        }
        #endif
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    // MARK: - Weekly Data

    private var weeklyDays: [(label: String, value: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find the start of the week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7 // Monday = 0
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return []
        }

        let labels = ["M", "T", "W", "T", "F", "S", "S"]
        let habitCount = max(totalCount, 1)

        return (0..<7).map { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return (label: labels[offset], value: 0, isToday: false)
            }
            let dayStart = calendar.startOfDay(for: day)
            let isToday = dayStart == today

            // Only count days up to today
            guard dayStart <= today else {
                return (label: labels[offset], value: 0, isToday: false)
            }

            let completedForDay = habits.filter { habit in
                habit.safeCompletions.contains { completion in
                    calendar.startOfDay(for: completion.date) == dayStart && completion.isCompleted
                }
            }.count

            let percent = Int(Double(completedForDay) / Double(habitCount) * 100)
            return (label: labels[offset], value: percent, isToday: isToday)
        }
    }

    private var weeklyAverage: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let daysSoFar = daysFromMonday + 1
        let values = weeklyDays.prefix(daysSoFar).map(\.value)
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / values.count
    }

    private var weeklyBest: Int {
        weeklyDays.map(\.value).max() ?? 0
    }

    private var weeklyTotal: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else { return 0 }

        return habits.reduce(0) { total, habit in
            total + habit.safeCompletions.filter { completion in
                let day = calendar.startOfDay(for: completion.date)
                return day >= monday && day <= today && completion.isCompleted
            }.count
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: HLSpacing.lg) {
                        greetingHeader
                            .hlStaggeredAppear(index: 0)

                        if habits.isEmpty {
                            emptyState
                                .hlStaggeredAppear(index: 1)
                        } else {
                            dailyProgressCard
                                .hlStaggeredAppear(index: 1)
                            if completedCount == 0 && totalCount > 0 {
                                firstDayProgressionCard
                                    .hlStaggeredAppear(index: 2)
                            }
                            motivationCard
                                .hlStaggeredAppear(index: 2)
                            streakCard
                                .hlStaggeredAppear(index: 3)
                            weeklyQuestsCard
                                .hlStaggeredAppear(index: 4)
                            todaysHabitsSection
                                .hlStaggeredAppear(index: 5)
                            quickInsightsCard
                                .hlStaggeredAppear(index: 5)
                            weeklyOverviewCard
                                .hlStaggeredAppear(index: 6)
                        }
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.bottom, HLSpacing.xxxl + HLSpacing.xl)
                }

                // Floating Action Button
                Button {
                    let activeCount = habits.count
                    if proManager.canCreateHabit(currentCount: activeCount) {
                        showCreateHabit = true
                    } else {
                        showPaywall = true
                        HLHaptics.warning()
                    }
                } label: {
                    Image(systemName: HLIcon.add)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .hlShadow(HLShadow.lg)
                }
                .padding(.trailing, HLSpacing.lg)
                .padding(.bottom, HLSpacing.lg)
                .accessibilityLabel("Add new habit")
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("HabitLand")
                        .font(HLFont.title2())
                        .foregroundStyle(Color.hlPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPomodoro = true
                    } label: {
                        Image(systemName: "timer")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.hlFlame)
                    }
                    .accessibilityLabel("Pomodoro Focus")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNotifications = true
                    } label: {
                        Image(systemName: HLIcon.notification)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.hlTextSecondary)
                    }
                    .accessibilityLabel("Notifications")
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationCenterView()
                    .hlSheetContent()
            }
            .sheet(isPresented: $showDailyOverview) {
                DailyHabitsOverview()
                    .hlSheetContent()
            }
            .sheet(isPresented: $showWeeklyProgress) {
                WeeklyProgressView()
                    .hlSheetContent()
            }
            .sheet(isPresented: $showCreateHabit, onDismiss: {
                showAchievementIfNeeded(AchievementManager.checkAll(context: modelContext))
            }) {
                CreateHabitView()
                    .hlSheetContent()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: .habitLimit)
                    .hlSheetContent()
            }
            .fullScreenCover(isPresented: $showPomodoro) {
                PomodoroView(isPresented: $showPomodoro)
            }
            .fullScreenCover(isPresented: $showChain) {
                HabitChainView(
                    habits: habits.filter { !$0.todayCompleted },
                    chainName: "Daily Chain"
                )
            }
            .overlay(alignment: .bottom) {
                UndoToast(
                    message: "\(undoHabitName) completed!",
                    onUndo: {
                        if let completion = undoCompletion {
                            modelContext.delete(completion)
                            removeXP(10)
                            HLHaptics.light()
                        }
                    },
                    isVisible: $showUndoToast
                )
                .padding(.bottom, HLSpacing.xxxl + HLSpacing.xl)
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
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.lg) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 64))
                .foregroundStyle(Color.hlPrimary)
                .symbolEffect(.pulse, options: .repeating)

            VStack(spacing: HLSpacing.xs) {
                Text("Your journey starts here")
                    .font(HLFont.title2(.semibold))
                    .foregroundStyle(Color.hlTextPrimary)

                Text("Create your first habit and start building a better routine, one day at a time.")
                    .font(HLFont.subheadline())
                    .foregroundStyle(Color.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HLSpacing.md)
            }

            Button {
                showCreateHabit = true
            } label: {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create First Habit")
                }
                .font(HLFont.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.sm)
                .background(Color.hlPrimary)
                .cornerRadius(HLRadius.lg)
            }
            .padding(.horizontal, HLSpacing.lg)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.xxxl)
        .hlCard()
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text("\(greeting), \(userName)")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlTextPrimary)
                Text(todayString)
                    .font(HLFont.subheadline())
                    .foregroundStyle(Color.hlTextSecondary)
            }

            // XP Progress Bar
            if let profile {
                HStack(spacing: HLSpacing.sm) {
                    // Level badge
                    Text("LV\(profile.level)")
                        .font(HLFont.caption2(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, HLSpacing.xs)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(HLRadius.full)

                    // XP bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: HLRadius.full)
                                .fill(Color.hlDivider)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: HLRadius.full)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.hlPrimary, Color.hlGold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geo.size.width * min(profile.levelProgress, 1.0),
                                    height: 6
                                )
                                .animation(HLAnimation.progressFill, value: profile.xp)
                        }
                    }
                    .frame(height: 6)

                    // XP text
                    Text("\(profile.xp)/\(profile.xpForNextLevel)")
                        .font(HLFont.caption2(.semibold))
                        .foregroundStyle(Color.hlTextTertiary)
                        .monospacedDigit()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, HLSpacing.xs)
    }

    // MARK: - Daily Progress Card

    private var dailyProgressCard: some View {
        HStack(spacing: HLSpacing.lg) {
            ZStack {
                Circle()
                    .stroke(Color.hlDivider, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: completionPercent)
                    .stroke(Color.hlPrimary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(HLAnimation.standard, value: completionPercent)
                VStack(spacing: HLSpacing.xxxs) {
                    Text("\(Int(completionPercent * 100))%")
                        .font(HLFont.title2())
                        .foregroundStyle(Color.hlTextPrimary)
                    Text("done")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                Text("Daily Progress")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Text("\(completedCount) of \(totalCount) habits completed")
                    .font(HLFont.subheadline())
                    .foregroundStyle(Color.hlTextSecondary)

                HStack(spacing: HLSpacing.sm) {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: progressStatusIcon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(progressStatusColor)
                        Text(progressStatusText)
                            .font(HLFont.caption(.medium))
                            .foregroundStyle(progressStatusColor)
                    }

                    if completedCount < totalCount && totalCount >= 2 {
                        Button {
                            showChain = true
                        } label: {
                            HStack(spacing: HLSpacing.xxs) {
                                Image(systemName: "link")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Chain")
                                    .font(HLFont.caption2(.semibold))
                            }
                            .foregroundStyle(Color.hlPrimary)
                            .padding(.horizontal, HLSpacing.xs)
                            .padding(.vertical, 3)
                            .background(Color.hlPrimary.opacity(0.12))
                            .cornerRadius(HLRadius.full)
                        }
                    }
                }
            }

            Spacer()
        }
        .hlCard()
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        HStack(spacing: HLSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.hlFlame.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: HLIcon.flame)
                    .font(.system(size: 26))
                    .foregroundStyle(Color.hlFlame)
                    .symbolEffect(.bounce, options: .repeating.speed(0.3))
            }

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text("Current Streak")
                    .font(HLFont.subheadline())
                    .foregroundStyle(Color.hlTextSecondary)
                HStack(alignment: .firstTextBaseline, spacing: HLSpacing.xxs) {
                    Text("\(streakDays)")
                        .font(HLFont.largeTitle())
                        .foregroundStyle(Color.hlFlame)
                    Text("days")
                        .font(HLFont.body())
                        .foregroundStyle(Color.hlTextSecondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: HLSpacing.xxxs) {
                Text("Best")
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextTertiary)
                Text("\(bestStreak) days")
                    .font(HLFont.subheadline(.semibold))
                    .foregroundStyle(Color.hlTextSecondary)
            }
        }
        .hlCard()
    }

    // MARK: - Weekly Quests Card

    private var weeklyQuestsCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Image(systemName: "scroll.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.hlGold)
                Text("Weekly Quests")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Spacer()
                Text("\(questManager.quests.filter(\.isCompleted).count)/\(questManager.quests.count)")
                    .font(HLFont.caption(.bold))
                    .foregroundStyle(Color.hlGold)
            }

            ForEach(questManager.quests) { quest in
                HStack(spacing: HLSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(quest.isCompleted ? Color.hlPrimary.opacity(0.15) : Color.hlDivider.opacity(0.5))
                            .frame(width: 36, height: 36)
                        Image(systemName: quest.isCompleted ? "checkmark.circle.fill" : quest.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(quest.isCompleted ? Color.hlPrimary : Color.hlTextTertiary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(quest.title)
                            .font(HLFont.callout(.medium))
                            .foregroundStyle(quest.isCompleted ? Color.hlTextTertiary : Color.hlTextPrimary)
                            .strikethrough(quest.isCompleted)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: HLRadius.full)
                                    .fill(Color.hlDivider)
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: HLRadius.full)
                                    .fill(quest.isCompleted ? Color.hlPrimary : Color.hlGold)
                                    .frame(width: geo.size.width * quest.progressFraction, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }

                    Text("\(quest.progress)/\(quest.target)")
                        .font(HLFont.caption2(.medium))
                        .foregroundStyle(Color.hlTextTertiary)
                        .frame(width: 36)

                    Text("+\(quest.xpReward)")
                        .font(HLFont.caption2(.bold))
                        .foregroundStyle(quest.isCompleted ? Color.hlPrimary : Color.hlGold)
                }
            }
        }
        .hlCard()
        .onAppear {
            questManager.updateProgress(context: modelContext)
        }
    }

    // MARK: - Today's Habits Section

    private var todaysHabitsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("Today's Habits")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Spacer()
                Button("See All") {
                    showDailyOverview = true
                }
                .font(HLFont.subheadline(.medium))
                .foregroundStyle(Color.hlPrimary)
            }

            VStack(spacing: HLSpacing.xs) {
                ForEach(habits) { habit in
                    habitRow(habit: habit)
                }
            }
        }
    }

    private func habitRow(habit: Habit) -> some View {
        HStack(spacing: HLSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: HLRadius.sm)
                    .fill(habit.color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: habit.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(habit.color)
            }

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                HStack(spacing: HLSpacing.xs) {
                    Text(habit.name)
                        .font(HLFont.callout(.medium))
                        .foregroundStyle(Color.hlTextPrimary)

                    if habit.currentStreak > 0 {
                        StreakFireView(streak: habit.currentStreak)
                            .frame(width: 24, height: 24)
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
                }
            }

            Spacer()

            // XP gain floating text
            if xpGainHabitID == habit.id.uuidString {
                XPGainView(amount: 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
                        undoCompletion = completion
                    }
                }
                if !wasCompleted {
                    HLHaptics.completionSuccess()
                    ReviewManager.trackCompletion()
                    // Show undo toast
                    undoHabitName = habit.name
                    withAnimation(HLAnimation.quick) {
                        showUndoToast = true
                    }
                    // XP gain
                    gainXP(10)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        xpGainHabitID = habit.id.uuidString
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        xpGainHabitID = nil
                    }
                    // All-complete celebration
                    let newCompletedCount = habits.filter({ $0.todayCompleted || $0.id == habit.id }).count
                    if newCompletedCount == totalCount && totalCount > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            celebrationMessage = "All habits done!\nAmazing work today!"
                            showCelebration = true
                            HLHaptics.heavy()
                        }
                    }
                    // Streak milestones
                    let newStreak = habit.currentStreak + 1
                    if [7, 14, 30, 50, 100, 365].contains(newStreak) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            celebrationMessage = "\(newStreak)-day streak!\nYou're on fire!"
                            showCelebration = true
                            HLHaptics.heavy()
                        }
                        ReviewManager.requestIfAppropriate()
                    }
                    // Check achievements
                    showAchievementIfNeeded(AchievementManager.checkAll(context: modelContext))
                    // Donate to Siri/Spotlight
                    CompleteHabitIntent.donate(habit: habit.toEntity())
                } else {
                    removeXP(10)
                    HLHaptics.light()
                }
            } label: {
                AnimatedCheckmark(isCompleted: habit.todayCompleted, color: habit.color, size: 26)
            }
            .accessibilityLabel(habit.todayCompleted ? "Mark \(habit.name) incomplete" : "Complete \(habit.name)")
        }
        .hlCard(padding: HLSpacing.sm)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if !habit.todayCompleted {
                Button {
                    completeHabit(habit)
                } label: {
                    Label("Done", systemImage: "checkmark")
                }
                .tint(Color.hlPrimary)
            }
        }
        .swipeActions(edge: .leading) {
            NavigationLink(value: habit.id) {
                Label("Details", systemImage: "info.circle")
            }
            .tint(Color.hlInfo)
        }
    }

    private func completeHabit(_ habit: Habit) {
        let completion = HabitCompletion(date: Date())
        withAnimation(HLAnimation.celebration) {
            completion.habit = habit
            modelContext.insert(completion)
        }
        HLHaptics.completionSuccess()
        ReviewManager.trackCompletion()
        gainXP(10)
        showAchievementIfNeeded(AchievementManager.checkAll(context: modelContext))
        CompleteHabitIntent.donate(habit: habit.toEntity())
        undoHabitName = habit.name
        undoCompletion = completion
        withAnimation(HLAnimation.quick) {
            showUndoToast = true
        }
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

    // MARK: - First Day Progression Card

    private var firstDayProgressionCard: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.hlGold)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("Your Journey Begins!")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                    Text("Complete your first habit to earn +10 XP")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary)
                }

                Spacer()
            }

            // Mini progression preview
            HStack(spacing: HLSpacing.lg) {
                VStack(spacing: HLSpacing.xxs) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.hlPrimary)
                    Text("Complete")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.hlDivider)

                VStack(spacing: HLSpacing.xxs) {
                    Text("+10")
                        .font(HLFont.callout(.bold))
                        .foregroundStyle(Color.hlGold)
                    Text("Earn XP")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.hlDivider)

                VStack(spacing: HLSpacing.xxs) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.hlPrimary)
                    Text("Level Up")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.xs)
        }
        .hlCard()
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .stroke(Color.hlGold.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Motivation Card

    private var motivationCard: some View {
        HStack(spacing: HLSpacing.sm) {
            Text(motivationEmoji)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(motivationTitle)
                    .font(HLFont.subheadline(.semibold))
                    .foregroundStyle(Color.hlTextPrimary)
                Text(motivationSubtitle)
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextSecondary)
            }

            Spacer()
        }
        .hlCard()
    }

    private var motivationEmoji: String {
        if completedCount == totalCount && totalCount > 0 { return "🏆" }
        if streakDays >= 30 { return "💎" }
        if streakDays >= 7 { return "🔥" }
        if completionPercent >= 0.5 { return "💪" }
        return "🌱"
    }

    private var motivationTitle: String {
        if completedCount == totalCount && totalCount > 0 {
            return "Perfect day! All habits done."
        }
        if streakDays >= 30 {
            return "\(streakDays)-day streak! You're unstoppable."
        }
        if streakDays >= 7 {
            return "Week streak! Keep the momentum."
        }
        let remaining = totalCount - completedCount
        if remaining <= 2 && remaining > 0 {
            return "Almost there! Just \(remaining) left."
        }
        return "Every small step counts."
    }

    private var motivationSubtitle: String {
        if completedCount == totalCount && totalCount > 0 {
            return "Come back tomorrow to keep your streak alive."
        }
        if streakDays >= 7 {
            return "You've been consistent for \(streakDays) days."
        }
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Start your morning strong."
        } else if hour < 18 {
            return "Make this afternoon count."
        }
        return "End your day on a high note."
    }

    // MARK: - Quick Insights Card

    private var quickInsightsCard: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: HLIcon.sparkles)
                .font(.system(size: 22))
                .foregroundStyle(Color.hlMindfulness)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text("Weekly Insight")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextTertiary)
                Text(insightText)
                    .font(HLFont.callout(.semibold))
                    .foregroundStyle(Color.hlTextPrimary)
                Text(insightSubtext)
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextSecondary)
            }

            Spacer()
        }
        .hlCard()
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .stroke(Color.hlMindfulness.opacity(0.25), lineWidth: 1)
        )
    }

    private var insightText: String {
        if completedCount == totalCount && totalCount > 0 {
            return "All habits done today!"
        } else if completionPercent >= 0.5 {
            return "You're over halfway there today!"
        } else if totalCount > 0 {
            return "\(totalCount - completedCount) habits left to go."
        } else {
            return "Add habits to start tracking."
        }
    }

    private var insightSubtext: String {
        if completedCount == totalCount && totalCount > 0 {
            return "Amazing work. Keep the streak alive."
        } else if completionPercent >= 0.5 {
            return "Keep up the momentum to hit your best week yet."
        } else {
            return "Small steps add up. You've got this."
        }
    }

    // MARK: - Weekly Overview Card

    private var weeklyOverviewCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("This Week")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Spacer()
                Button("Details") {
                    showWeeklyProgress = true
                }
                .font(HLFont.subheadline(.medium))
                .foregroundStyle(Color.hlPrimary)
            }

            HStack(alignment: .bottom, spacing: HLSpacing.xs) {
                ForEach(Array(weeklyDays.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: HLSpacing.xxs) {
                        RoundedRectangle(cornerRadius: HLRadius.xs)
                            .fill(day.isToday ? Color.hlPrimary : Color.hlPrimary.opacity(0.35))
                            .frame(height: max(8, CGFloat(day.value) / 100.0 * 80))
                            .frame(maxWidth: .infinity)

                        Text(day.label)
                            .font(HLFont.caption2(day.isToday ? .bold : .regular))
                            .foregroundStyle(day.isToday ? Color.hlPrimary : Color.hlTextTertiary)
                    }
                }
            }
            .frame(height: 100)

            HStack(spacing: HLSpacing.lg) {
                weekStat(title: "Avg", value: "\(weeklyAverage)%")
                weekStat(title: "Best", value: "\(weeklyBest)%")
                weekStat(title: "Total", value: "\(weeklyTotal)")
            }
            .frame(maxWidth: .infinity)
        }
        .hlCard()
    }

    private func weekStat(title: String, value: String) -> some View {
        VStack(spacing: HLSpacing.xxxs) {
            Text(value)
                .font(HLFont.callout(.semibold))
                .foregroundStyle(Color.hlTextPrimary)
            Text(title)
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextTertiary)
        }
    }
}

// MARK: - Preview

#Preview {
    HomeDashboardView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, UserProfile.self], inMemory: true)
}
