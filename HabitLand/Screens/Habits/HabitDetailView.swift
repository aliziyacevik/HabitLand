import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                headerSection
                    .hlStaggeredAppear(index: 0)
                calendarHeatMap
                    .hlStaggeredAppear(index: 1)
                statsRow
                    .hlStaggeredAppear(index: 2)
                weeklyChart
                    .hlStaggeredAppear(index: 3)
                recentCompletions
                    .hlStaggeredAppear(index: 4)
                actionButtons
                    .hlStaggeredAppear(index: 5)
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showEditSheet = true } label: {
                        Label("Edit", systemImage: HLIcon.edit)
                    }
                    Button {
                        habit.isArchived.toggle()
                        habit.updatedAt = Date()
                    } label: {
                        Label(habit.isArchived ? "Unarchive" : "Archive", systemImage: HLIcon.archive)
                    }
                    Button(role: .destructive) { showDeleteAlert = true } label: {
                        Label("Delete", systemImage: HLIcon.delete)
                    }
                } label: {
                    Image(systemName: HLIcon.more)
                        .foregroundStyle(Color.hlTextPrimary)
                }
                .accessibilityLabel("More options")
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditHabitView(habit: habit)
                .hlSheetContent()
        }
        .alert("Delete Habit?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(habit)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. All completion history will be lost.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: HLSpacing.sm) {
            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: habit.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(habit.color)
            }

            Text(habit.name)
                .font(HLFont.title2())
                .foregroundStyle(Color.hlTextPrimary)
                .lineLimit(2)
                .truncationMode(.tail)

            // Category Badge
            HStack(spacing: HLSpacing.xxs) {
                Image(systemName: habit.category.icon)
                    .font(HLFont.caption())
                Text(habit.category.rawValue)
                    .font(HLFont.caption(.semibold))
            }
            .foregroundStyle(habit.category.color)
            .padding(.horizontal, HLSpacing.sm)
            .padding(.vertical, HLSpacing.xxs)
            .background(habit.category.color.opacity(0.12))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .hlCard()
    }

    // MARK: - Calendar Heat Map

    private var calendarHeatMap: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Last 30 Days")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            let days = last30Days()
            let columns = Array(repeating: GridItem(.flexible(), spacing: HLSpacing.xxs), count: 7)

            LazyVGrid(columns: columns, spacing: HLSpacing.xxs) {
                ForEach(days, id: \.self) { date in
                    let completed = isDateCompleted(date)
                    Circle()
                        .fill(completed ? habit.color : habit.color.opacity(0.1))
                        .frame(width: 28, height: 28)
                        .overlay {
                            if Calendar.current.isDateInToday(date) {
                                Circle()
                                    .stroke(Color.hlTextPrimary, lineWidth: 1.5)
                            }
                        }
                }
            }

            // Legend
            HStack(spacing: HLSpacing.sm) {
                HStack(spacing: HLSpacing.xxs) {
                    Circle().fill(habit.color.opacity(0.1)).frame(width: 10, height: 10)
                    Text("Missed").font(HLFont.caption2()).foregroundStyle(Color.hlTextTertiary)
                }
                HStack(spacing: HLSpacing.xxs) {
                    Circle().fill(habit.color).frame(width: 10, height: 10)
                    Text("Completed").font(HLFont.caption2()).foregroundStyle(Color.hlTextTertiary)
                }
                Spacer()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(calendarHeatMapAccessibilityLabel)
        .hlCard()
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: HLSpacing.xs) {
            StatBox(title: "Current", value: "\(habit.currentStreak)", subtitle: "streak", color: Color.hlFlame)
            StatBox(title: "Best", value: "\(habit.bestStreak)", subtitle: "streak", color: Color.hlGold)
            StatBox(title: "Total", value: "\(habit.totalCompletions)", subtitle: "done", color: Color.hlPrimary)
            StatBox(title: "Rate", value: "\(Int(habit.weekCompletionRate * 100))%", subtitle: "weekly", color: Color.hlInfo)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(habit.currentStreak)-day current streak, \(habit.bestStreak)-day best streak, \(habit.totalCompletions) total completions, \(Int(habit.weekCompletionRate * 100)) percent weekly rate")
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("This Week")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            HStack(alignment: .bottom, spacing: HLSpacing.xs) {
                ForEach(weekDayData(), id: \.day) { item in
                    VStack(spacing: HLSpacing.xxs) {
                        RoundedRectangle(cornerRadius: HLRadius.xs)
                            .fill(item.completed ? habit.color : habit.color.opacity(0.15))
                            .frame(height: item.completed ? 48 : 24)
                            .frame(maxWidth: .infinity)

                        Text(item.day)
                            .font(HLFont.caption2(.medium))
                            .foregroundStyle(item.isToday ? Color.hlTextPrimary : Color.hlTextTertiary)
                    }
                }
            }
            .frame(height: 64)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(habitWeeklyChartAccessibilityLabel)
        }
        .hlCard()
    }

    // MARK: - Recent Completions

    private var recentCompletions: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("Recent Completions")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Spacer()
                NavigationLink(destination: HabitHistoryView(habit: habit)) {
                    Text("See All")
                        .font(HLFont.subheadline(.medium))
                        .foregroundStyle(Color.hlPrimary)
                }
            }

            let recent = habit.safeCompletions
                .filter(\.isCompleted)
                .sorted { $0.date > $1.date }
                .prefix(5)

            if recent.isEmpty {
                Text("No completions yet")
                    .font(HLFont.subheadline())
                    .foregroundStyle(Color.hlTextTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, HLSpacing.md)
            } else {
                ForEach(Array(recent)) { completion in
                    HStack {
                        Image(systemName: HLIcon.checkmark)
                            .font(HLFont.caption(.bold))
                            .foregroundStyle(Color.hlPrimary)
                            .frame(width: 24, height: 24)
                            .background(Color.hlPrimaryLight)
                            .clipShape(Circle())

                        Text(completion.date, style: .date)
                            .font(HLFont.subheadline())
                            .foregroundStyle(Color.hlTextPrimary)

                        Spacer()

                        Text(completion.date, style: .time)
                            .font(HLFont.caption())
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                    if completion.id != recent.last?.id {
                        Divider().overlay(Color.hlDivider)
                    }
                }
            }
        }
        .hlCard()
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: HLSpacing.sm) {
            NavigationLink(destination: HabitStatisticsView(habit: habit)) {
                actionRow(icon: HLIcon.chart, title: "Statistics", color: Color.hlInfo)
            }
            NavigationLink(destination: HabitScheduleView(habit: habit)) {
                actionRow(icon: HLIcon.calendar, title: "Schedule", color: Color.hlPrimary)
            }
            NavigationLink(destination: HabitNotesView(habit: habit)) {
                actionRow(icon: HLIcon.note, title: "Notes", color: Color.hlProductivity)
            }
            NavigationLink(destination: HabitReminderView(habit: habit)) {
                actionRow(icon: HLIcon.bell, title: "Reminders", color: Color.hlMindfulness)
            }
        }
    }

    private func actionRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(HLFont.body(.medium))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: HLRadius.sm))
            Text(title)
                .font(HLFont.body())
                .foregroundStyle(Color.hlTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(HLFont.caption(.medium))
                .foregroundStyle(Color.hlTextTertiary)
        }
        .hlCard()
    }

    // MARK: - Accessibility Helpers

    private var calendarHeatMapAccessibilityLabel: String {
        let days = last30Days()
        let completedDays = days.filter { isDateCompleted($0) }.count
        return "Last 30 days calendar. \(completedDays) of \(days.count) days completed."
    }

    private var habitWeeklyChartAccessibilityLabel: String {
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let data = weekDayData()
        let descriptions = data.enumerated().map { index, item in
            let name = index < dayNames.count ? dayNames[index] : item.day
            return "\(name) \(item.completed ? "completed" : "not completed")"
        }
        let completedCount = data.filter(\.completed).count
        return "This week: \(descriptions.joined(separator: ", ")). \(completedCount) of \(data.count) days completed."
    }

    // MARK: - Helpers

    private func last30Days() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<30).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }

    private func isDateCompleted(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        return habit.safeCompletions.contains { completion in
            calendar.startOfDay(for: completion.date) == day && completion.isCompleted
        }
    }

    private func weekDayData() -> [(day: String, completed: Bool, isToday: Bool)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today) ?? today
        let labels = ["S", "M", "T", "W", "T", "F", "S"]

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) ?? startOfWeek
            let completed = isDateCompleted(date)
            let isToday = calendar.isDateInToday(date)
            return (day: labels[offset], completed: completed, isToday: isToday)
        }
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: HLSpacing.xxxs) {
            Text(title)
                .font(HLFont.caption2(.medium))
                .foregroundStyle(Color.hlTextTertiary)
            Text(value)
                .font(HLFont.title3(.bold))
                .foregroundStyle(color)
            Text(subtitle)
                .font(HLFont.caption2())
                .foregroundStyle(Color.hlTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(value) \(subtitle) \(title)")
        .hlCard(padding: HLSpacing.sm)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitDetailView(habit: {
            let h = Habit(name: "Morning Meditation", icon: "brain.head.profile", colorHex: "#9966E6", category: .mindfulness)
            h.completions = (0..<15).map { i in
                HabitCompletion(
                    date: Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date(),
                    isCompleted: Bool.random()
                )
            }
            return h
        }())
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
