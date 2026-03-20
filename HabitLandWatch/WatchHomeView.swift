import SwiftUI
import SwiftData

struct WatchHomeView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.sortOrder)
    private var habits: [Habit]

    @Environment(\.modelContext) private var modelContext

    private var completedCount: Int { habits.filter(\.todayCompleted).count }
    private var totalCount: Int { habits.count }
    private var progress: Double { totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0 }

    var body: some View {
        NavigationStack {
            if habits.isEmpty {
                emptyState
            } else {
                habitList
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .font(.largeTitle)
                .foregroundStyle(.green)
            Text("No Habits")
                .font(.headline)
            Text("Add habits in the\niPhone app")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .navigationTitle("HabitLand")
    }

    // MARK: - Habit List

    private var habitList: some View {
        List {
            progressSection
            habitsSection
        }
        .navigationTitle("HabitLand")
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        Section {
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            completedCount == totalCount ? Color.green : Color.blue,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(completedCount)/\(totalCount)")
                        .font(.headline)
                    Text(completedCount == totalCount ? "All done!" : "Keep going")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let best = habits.max(by: { $0.currentStreak < $1.currentStreak }),
                   best.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(best.currentStreak)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    // MARK: - Habits Section

    private var habitsSection: some View {
        Section("Today") {
            ForEach(habits) { habit in
                HabitRow(habit: habit) {
                    toggleHabit(habit)
                }
            }
        }
    }

    // MARK: - Actions

    private func toggleHabit(_ habit: Habit) {
        let today = Calendar.current.startOfDay(for: Date())

        if habit.todayCompleted {
            if let completion = habit.completions.first(where: {
                Calendar.current.startOfDay(for: $0.date) == today && $0.isCompleted
            }) {
                modelContext.delete(completion)
            }
        } else {
            let completion = HabitCompletion(date: Date())
            completion.habit = habit
            modelContext.insert(completion)

            // Award XP
            let profileDescriptor = FetchDescriptor<UserProfile>()
            if let profile = try? modelContext.fetch(profileDescriptor).first {
                profile.xp += 10
                if profile.xp >= profile.xpForNextLevel {
                    profile.xp -= profile.xpForNextLevel
                    profile.level += 1
                }
            }
        }

        try? modelContext.save()
    }
}

// MARK: - Habit Row

struct HabitRow: View {
    let habit: Habit
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: habit.todayCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(habit.todayCompleted ? habitColor : .gray)
                    .animation(.easeInOut(duration: 0.2), value: habit.todayCompleted)

                VStack(alignment: .leading, spacing: 1) {
                    Text(habit.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .strikethrough(habit.todayCompleted, color: .secondary)
                        .foregroundStyle(habit.todayCompleted ? .secondary : .primary)

                    if habit.currentStreak > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.orange)
                            Text("\(habit.currentStreak)d")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var habitColor: Color {
        Color(hex: habit.colorHex) ?? .green
    }
}
