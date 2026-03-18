import SwiftUI
import SwiftData

// MARK: - Sort Option

enum HabitSortOption: String, CaseIterable {
    case custom = "Custom"
    case name = "Name"
    case streak = "Streak"
    case category = "Category"
    case newest = "Newest"

    var icon: String {
        switch self {
        case .custom: return "arrow.up.arrow.down"
        case .name: return "textformat.abc"
        case .streak: return "flame.fill"
        case .category: return "folder.fill"
        case .newest: return "clock.fill"
        }
    }
}

// MARK: - Habit List View

struct HabitListView: View {
    @Query private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedFilter: Int = 0
    @State private var searchText = ""
    @State private var sortOption: HabitSortOption = .custom
    @State private var showCreateHabit = false
    @State private var showPaywall = false
    @State private var showLimitAlert = false
    @ObservedObject private var proManager = ProManager.shared

    private var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    private var filteredHabits: [Habit] {
        let isArchived = selectedFilter == 1
        var result = habits.filter { $0.isArchived == isArchived }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        switch sortOption {
        case .custom:
            result.sort { $0.sortOrder < $1.sortOrder }
        case .name:
            result.sort { $0.name < $1.name }
        case .streak:
            result.sort { $0.currentStreak > $1.currentStreak }
        case .category:
            result.sort { $0.category.rawValue < $1.category.rawValue }
        case .newest:
            result.sort { $0.createdAt > $1.createdAt }
        }

        return result
    }

    private var completedToday: Int {
        activeHabits.filter { $0.todayCompleted }.count
    }

    private var todayProgress: Double {
        guard !activeHabits.isEmpty else { return 0 }
        return Double(completedToday) / Double(activeHabits.count)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.hlBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Summary Header
                        if selectedFilter == 0 && !filteredHabits.isEmpty {
                            summaryHeader
                                .padding(.horizontal, HLSpacing.md)
                                .padding(.top, HLSpacing.sm)
                                .padding(.bottom, HLSpacing.xs)
                        }

                        // Filter Tabs
                        filterTabs
                            .padding(.horizontal, HLSpacing.md)
                            .padding(.top, filteredHabits.isEmpty || selectedFilter == 1 ? HLSpacing.sm : 0)

                        // Sort Row
                        sortRow
                            .padding(.horizontal, HLSpacing.md)
                            .padding(.top, HLSpacing.sm)
                            .padding(.bottom, HLSpacing.xs)

                        // Free Tier Banner
                        if selectedFilter == 0 && !proManager.isPro && !activeHabits.isEmpty {
                            freeTierBanner
                                .padding(.horizontal, HLSpacing.md)
                                .padding(.bottom, HLSpacing.xs)
                        }

                        // Habit List
                        if filteredHabits.isEmpty {
                            emptyStateView
                                .frame(minHeight: 400)
                        } else {
                            habitList
                        }
                    }
                    .padding(.bottom, HLSpacing.xxxl + HLSpacing.xl)
                }

                // FAB
                if selectedFilter == 0 {
                    fabButton
                }
            }
            .navigationTitle("My Habits")
            .searchable(text: $searchText, prompt: "Search habits...")
            .sheet(isPresented: $showCreateHabit) {
                CreateHabitView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("Habit Limit Reached", isPresented: $showLimitAlert) {
                Button("Upgrade to Pro") {
                    showPaywall = true
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text("Free plan allows up to \(ProManager.freeHabitLimit) active habits. Upgrade to HabitLand Pro for unlimited habits and premium features.")
            }
        }
    }

    // MARK: - Summary Header

    private var summaryHeader: some View {
        HStack(spacing: HLSpacing.md) {
            // Progress Ring
            ProgressRing(
                progress: todayProgress,
                color: .hlPrimary,
                lineWidth: 5
            )
            .frame(width: 52, height: 52)

            // Stats
            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text("Today's Progress")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)

                Text("\(completedToday) of \(activeHabits.count) completed")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            Spacer()

            // Streak badge (best streak among active habits)
            if let bestStreak = activeHabits.map({ $0.currentStreak }).max(), bestStreak > 0 {
                VStack(spacing: HLSpacing.xxxs) {
                    HStack(spacing: 3) {
                        Image(systemName: HLIcon.flame)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.hlFlame)
                        Text("\(bestStreak)")
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlTextPrimary)
                    }
                    Text("best")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(Color.hlSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.lg)
                        .stroke(Color.hlPrimary.opacity(0.15), lineWidth: 1)
                )
        )
        .hlShadow(HLShadow.sm)
    }

    // MARK: - Filter Tabs

    private var filterTabs: some View {
        HStack(spacing: HLSpacing.xs) {
            filterTab(title: "Active", count: habits.filter { !$0.isArchived }.count, tag: 0)
            filterTab(title: "Archived", count: habits.filter { $0.isArchived }.count, tag: 1)
            Spacer()
        }
    }

    private func filterTab(title: String, count: Int, tag: Int) -> some View {
        Button {
            withAnimation(HLAnimation.microSpring) {
                selectedFilter = tag
            }
        } label: {
            HStack(spacing: HLSpacing.xxs) {
                Text(title)
                    .font(HLFont.subheadline(selectedFilter == tag ? .semibold : .regular))

                Text("\(count)")
                    .font(HLFont.caption(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(selectedFilter == tag ? Color.hlPrimary.opacity(0.15) : Color.hlDivider)
                    )
            }
            .foregroundStyle(selectedFilter == tag ? Color.hlPrimary : Color.hlTextTertiary)
            .padding(.horizontal, HLSpacing.sm)
            .padding(.vertical, HLSpacing.xs)
            .background(
                Capsule()
                    .fill(selectedFilter == tag ? Color.hlPrimary.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sort Row

    private var sortRow: some View {
        HStack {
            if !filteredHabits.isEmpty {
                Text("\(filteredHabits.count) habit\(filteredHabits.count == 1 ? "" : "s")")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextTertiary)
            }

            Spacer()

            Menu {
                ForEach(HabitSortOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation(HLAnimation.standard) {
                            sortOption = option
                        }
                    } label: {
                        Label {
                            Text(option.rawValue)
                        } icon: {
                            if sortOption == option {
                                Image(systemName: "checkmark")
                            } else {
                                Image(systemName: option.icon)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11, weight: .semibold))
                    Text(sortOption.rawValue)
                        .font(HLFont.caption(.medium))
                }
                .foregroundStyle(Color.hlTextSecondary)
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xxs + 2)
                .background(
                    Capsule()
                        .fill(Color.hlSurface)
                        .overlay(
                            Capsule()
                                .stroke(Color.hlDivider, lineWidth: 1)
                        )
                )
            }
        }
    }

    // MARK: - Free Tier Banner

    private var freeTierBanner: some View {
        let remaining = max(0, ProManager.freeHabitLimit - activeHabits.count)
        let atLimit = remaining == 0

        return HStack(spacing: HLSpacing.sm) {
            // Icon
            ZStack {
                Circle()
                    .fill(atLimit ? Color.hlWarning.opacity(0.15) : Color.hlPrimary.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: atLimit ? "exclamationmark.triangle.fill" : "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(atLimit ? Color.hlWarning : Color.hlPrimary)
            }

            VStack(alignment: .leading, spacing: 1) {
                if atLimit {
                    Text("Habit limit reached")
                        .font(HLFont.caption(.semibold))
                        .foregroundStyle(Color.hlTextPrimary)
                } else {
                    Text("\(remaining) habit\(remaining == 1 ? "" : "s") remaining on free plan")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                }
            }

            Spacer()

            Button {
                showPaywall = true
            } label: {
                Text("Upgrade")
                    .font(HLFont.caption(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, HLSpacing.sm)
                    .padding(.vertical, HLSpacing.xxs + 2)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
        }
        .padding(.horizontal, HLSpacing.sm)
        .padding(.vertical, HLSpacing.xs + 2)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .fill(Color.hlSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .stroke(atLimit ? Color.hlWarning.opacity(0.3) : Color.hlDivider, lineWidth: 1)
                )
        )
    }

    // MARK: - Habit List

    private var habitList: some View {
        LazyVStack(spacing: HLSpacing.sm) {
            ForEach(Array(filteredHabits.enumerated()), id: \.element.id) { index, habit in
                NavigationLink(destination: HabitDetailView(habit: habit)) {
                    HabitCardView(habit: habit)
                }
                .buttonStyle(HLCardPressStyle())
                .hlStaggeredAppear(index: index)
                .draggable(habit.id.uuidString) {
                    HabitCardView(habit: habit)
                        .frame(width: 300)
                        .opacity(0.8)
                }
                .dropDestination(for: String.self) { items, _ in
                    guard let draggedID = items.first,
                          let draggedUUID = UUID(uuidString: draggedID),
                          let fromIndex = filteredHabits.firstIndex(where: { $0.id == draggedUUID }),
                          let toIndex = filteredHabits.firstIndex(where: { $0.id == habit.id }),
                          fromIndex != toIndex else { return false }

                    reorderHabit(from: fromIndex, to: toIndex)
                    return true
                }
            }
        }
        .padding(.horizontal, HLSpacing.md)
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            if proManager.canCreateHabit(currentCount: activeHabits.count) {
                showCreateHabit = true
            } else {
                showLimitAlert = true
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

    // MARK: - Reorder

    private func reorderHabit(from sourceIndex: Int, to destIndex: Int) {
        var reordered = filteredHabits
        let moved = reordered.remove(at: sourceIndex)
        reordered.insert(moved, at: destIndex)
        for (i, habit) in reordered.enumerated() {
            habit.sortOrder = i
        }
        sortOption = .custom
        HLHaptics.selection()
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: HLSpacing.md) {
            Spacer()

            ZStack {
                Circle()
                    .fill(selectedFilter == 0 ? Color.hlPrimary.opacity(0.08) : Color.hlTextTertiary.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: selectedFilter == 0 ? "leaf.fill" : HLIcon.archive)
                    .font(.system(size: 40))
                    .foregroundStyle(selectedFilter == 0 ? Color.hlPrimary.opacity(0.6) : Color.hlTextTertiary)
            }

            Text(selectedFilter == 0 ? "No habits yet" : "No archived habits")
                .font(HLFont.title3(.semibold))
                .foregroundStyle(Color.hlTextPrimary)

            Text(selectedFilter == 0 ? "Create your first habit and start\nbuilding a better routine." : "Archived habits will appear here.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)

            if selectedFilter == 0 {
                Button {
                    if proManager.canCreateHabit(currentCount: activeHabits.count) {
                        showCreateHabit = true
                    } else {
                        showLimitAlert = true
                    }
                } label: {
                    HStack(spacing: HLSpacing.xs) {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Habit")
                    }
                    .font(HLFont.subheadline(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, HLSpacing.lg)
                    .padding(.vertical, HLSpacing.sm)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.top, HLSpacing.xs)
            }

            Spacer()
        }
    }
}

// MARK: - Habit Card

struct HabitCardView: View {
    let habit: Habit

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .fill(habit.color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: habit.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(habit.color)
            }

            // Name and Category
            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(habit.name)
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                    .lineLimit(1)
                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: habit.category.icon)
                        .font(.system(size: 10))
                    Text(habit.category.rawValue)
                        .font(HLFont.caption(.medium))
                }
                .foregroundStyle(Color.hlTextTertiary)
            }

            Spacer()

            // Streak
            if habit.currentStreak > 0 {
                streakBadge
            }

            // Progress Ring
            ProgressRing(progress: habit.todayProgress, color: habit.color, lineWidth: 3.5)
                .frame(width: 34, height: 34)
        }
        .hlCard()
    }

    @ViewBuilder
    private var streakBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: HLIcon.flame)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(streakColor)
            Text("\(habit.currentStreak)")
                .font(HLFont.subheadline(.semibold))
                .foregroundStyle(Color.hlTextPrimary)
        }
        .padding(.horizontal, HLSpacing.xs)
        .padding(.vertical, HLSpacing.xxs)
        .background(
            Capsule()
                .fill(streakColor.opacity(0.1))
        )
    }

    private var streakColor: Color {
        switch habit.currentStreak {
        case 0..<7: return Color.hlFlame
        case 7..<30: return Color.hlGold
        default: return Color.hlError
        }
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.12), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(HLAnimation.progressFill, value: progress)
            if progress >= 1.0 {
                Image(systemName: HLIcon.checkmark)
                    .font(.system(size: lineWidth * 2.5, weight: .bold))
                    .foregroundStyle(color)
            }
        }
        .hlRingGlow(progress: progress, color: color)
    }
}

// MARK: - Preview

#Preview {
    HabitListView()
        .modelContainer(for: Habit.self, inMemory: true)
}
