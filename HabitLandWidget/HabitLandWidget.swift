import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Provider

@MainActor
struct HabitTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            completedCount: 3,
            totalCount: 5,
            topHabits: [
                .init(name: "Meditation", icon: "brain.head.profile", colorHex: "#9966E6", streak: 14, isCompleted: true),
                .init(name: "Exercise", icon: "figure.run", colorHex: "#F24D4D", streak: 7, isCompleted: false),
                .init(name: "Read", icon: "book.fill", colorHex: "#FFC207", streak: 21, isCompleted: true),
            ],
            bestStreakName: "Meditation",
            bestStreakDays: 14
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        completion(fetchEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        let entry = fetchEntry()
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let nextUpdate = min(midnight, Date().addingTimeInterval(1800))
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchEntry() -> HabitWidgetEntry {
        let context = SharedModelContainer.container.mainContext
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { !$0.isArchived })

        guard let habits = try? context.fetch(descriptor), !habits.isEmpty else {
            return HabitWidgetEntry(date: Date(), completedCount: 0, totalCount: 0, topHabits: [], bestStreakName: nil, bestStreakDays: 0)
        }

        let completed = habits.filter(\.todayCompleted)
        let sorted = habits.sorted { $0.sortOrder < $1.sortOrder }
        let top = sorted.prefix(5).map { habit in
            WidgetHabit(
                name: habit.name,
                icon: habit.icon,
                colorHex: habit.colorHex,
                streak: habit.currentStreak,
                isCompleted: habit.todayCompleted
            )
        }

        let bestStreak = habits.max(by: { $0.currentStreak < $1.currentStreak })

        return HabitWidgetEntry(
            date: Date(),
            completedCount: completed.count,
            totalCount: habits.count,
            topHabits: Array(top),
            bestStreakName: bestStreak?.name,
            bestStreakDays: bestStreak?.currentStreak ?? 0
        )
    }
}

// MARK: - Entry

struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let completedCount: Int
    let totalCount: Int
    let topHabits: [WidgetHabit]
    let bestStreakName: String?
    let bestStreakDays: Int

    var progress: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }
}

struct WidgetHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let colorHex: String
    let streak: Int
    let isCompleted: Bool

    var color: Color {
        Color(hex: colorHex) ?? .green
    }
}

// MARK: - Small Widget View

struct SmallProgressView: View {
    let entry: HabitWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
                Text("HabitLand")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(
                        entry.completedCount == entry.totalCount ? Color.green : Color(hex: "#338FFF") ?? .blue,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(entry.completedCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("/\(entry.totalCount)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 70, height: 70)
            .frame(maxWidth: .infinity)

            Spacer()

            if entry.bestStreakDays > 0, entry.bestStreakName != nil {
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(entry.bestStreakDays)d")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(12)
    }
}

// MARK: - Medium Widget View

struct MediumProgressView: View {
    let entry: HabitWidgetEntry

    var body: some View {
        HStack(spacing: 12) {
            // Left: progress ring
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    Text("HabitLand")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: entry.progress)
                        .stroke(
                            entry.completedCount == entry.totalCount ? Color.green : Color(hex: "#338FFF") ?? .blue,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text("\(entry.completedCount)/\(entry.totalCount)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text("done")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 64, height: 64)

                Spacer()
            }
            .frame(width: 80)

            // Right: habit list
            VStack(alignment: .leading, spacing: 4) {
                ForEach(entry.topHabits.prefix(4)) { habit in
                    HStack(spacing: 6) {
                        Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.caption)
                            .foregroundStyle(habit.isCompleted ? habit.color : .gray.opacity(0.4))

                        Text(habit.name)
                            .font(.caption)
                            .fontWeight(habit.isCompleted ? .medium : .regular)
                            .foregroundStyle(habit.isCompleted ? .secondary : .primary)
                            .strikethrough(habit.isCompleted, color: .secondary)
                            .lineLimit(1)

                        Spacer()

                        if habit.streak > 0 {
                            HStack(spacing: 1) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.orange)
                                Text("\(habit.streak)")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                let remaining = entry.totalCount - entry.topHabits.prefix(4).count
                if remaining > 0 {
                    Text("+\(remaining) more")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
    }
}

// MARK: - Widget Definition

struct DailyProgressWidget: Widget {
    let kind = "DailyProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitTimelineProvider()) { entry in
            Group {
                if #available(iOS 17.0, *) {
                    WidgetView(entry: entry)
                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    WidgetView(entry: entry)
                        .padding()
                        .background()
                }
            }
        }
        .configurationDisplayName("Daily Progress")
        .description("Track your daily habit progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: HabitWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallProgressView(entry: entry)
        case .systemMedium:
            MediumProgressView(entry: entry)
        default:
            SmallProgressView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct HabitLandWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyProgressWidget()
    }
}

