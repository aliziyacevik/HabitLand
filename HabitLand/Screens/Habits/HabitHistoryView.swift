import SwiftUI
import SwiftData

struct HabitHistoryView: View {
    let habit: Habit

    @State private var filterOption: HistoryFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            // Filter Picker
            Picker("Filter", selection: $filterOption) {
                ForEach(HistoryFilter.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.xs)

            // Completions List
            let grouped = groupedCompletions
            if grouped.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: HLSpacing.md, pinnedViews: .sectionHeaders) {
                        ForEach(grouped, id: \.month) { group in
                            Section {
                                ForEach(group.items) { completion in
                                    completionRow(completion)
                                }
                            } header: {
                                sectionHeader(group.month, count: group.items.count)
                            }
                        }
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.bottom, HLSpacing.xl)
                }
            }
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Completion Row

    private func completionRow(_ completion: HabitCompletion) -> some View {
        HStack(spacing: HLSpacing.sm) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(completion.isCompleted ? Color.hlPrimary.opacity(0.15) : Color.hlError.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: completion.isCompleted ? HLIcon.checkmark : "xmark")
                    .font(HLFont.caption(.bold))
                    .foregroundStyle(completion.isCompleted ? Color.hlPrimary : Color.hlError)
            }

            // Details
            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(completion.date, style: .date)
                    .font(HLFont.subheadline(.medium))
                    .foregroundStyle(Color.hlTextPrimary)

                HStack(spacing: HLSpacing.xs) {
                    Text(completion.date, style: .time)
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)

                    if completion.count > 1 {
                        Text("\(completion.count)x")
                            .font(HLFont.caption(.semibold))
                            .foregroundStyle(habit.color)
                            .padding(.horizontal, HLSpacing.xxs)
                            .padding(.vertical, HLSpacing.xxxs)
                            .background(habit.color.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            // Note indicator
            if let note = completion.note, !note.isEmpty {
                Image(systemName: HLIcon.note)
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextTertiary)
            }

            // Status badge
            Text(completion.isCompleted ? "Done" : "Missed")
                .font(HLFont.caption2(.semibold))
                .foregroundStyle(completion.isCompleted ? Color.hlPrimary : Color.hlError)
                .padding(.horizontal, HLSpacing.xs)
                .padding(.vertical, HLSpacing.xxxs)
                .background(
                    (completion.isCompleted ? Color.hlPrimary : Color.hlError).opacity(0.1)
                )
                .clipShape(Capsule())
        }
        .hlCard()
    }

    // MARK: - Section Header

    private func sectionHeader(_ month: String, count: Int) -> some View {
        HStack {
            Text(month)
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)
            Spacer()
            Text("\(count) entries")
                .font(HLFont.caption(.medium))
                .foregroundStyle(Color.hlTextTertiary)
        }
        .padding(.vertical, HLSpacing.xs)
        .padding(.horizontal, HLSpacing.xxs)
        .background(Color.hlBackground)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Spacer()
            Image(systemName: HLIcon.calendar)
                .font(.system(size: 48))
                .foregroundStyle(Color.hlTextTertiary)
            Text("No history yet")
                .font(HLFont.title3())
                .foregroundStyle(Color.hlTextPrimary)
            Text("Completions will appear here as you track your habit")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(HLSpacing.lg)
    }

    // MARK: - Helpers

    private var filteredCompletions: [HabitCompletion] {
        switch filterOption {
        case .all:
            return habit.completions.sorted { $0.date > $1.date }
        case .completed:
            return habit.completions.filter(\.isCompleted).sorted { $0.date > $1.date }
        case .missed:
            return habit.completions.filter { !$0.isCompleted }.sorted { $0.date > $1.date }
        }
    }

    private var groupedCompletions: [(month: String, items: [HabitCompletion])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: filteredCompletions) { completion in
            formatter.string(from: completion.date)
        }

        return grouped
            .map { (month: $0.key, items: $0.value) }
            .sorted { item1, item2 in
                guard let d1 = item1.items.first?.date, let d2 = item2.items.first?.date else { return false }
                return d1 > d2
            }
    }
}

// MARK: - Filter

enum HistoryFilter: String, CaseIterable {
    case all = "All"
    case completed = "Completed"
    case missed = "Missed"
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitHistoryView(habit: {
            let h = Habit(name: "Morning Meditation", icon: "brain.head.profile", colorHex: "#9966E6", category: .mindfulness)
            h.completions = (0..<30).map { i in
                HabitCompletion(
                    date: Calendar.current.date(byAdding: .day, value: -i, to: Date())!,
                    isCompleted: i % 3 != 0,
                    count: Int.random(in: 1...3),
                    note: i % 5 == 0 ? "Felt great today" : nil
                )
            }
            return h
        }())
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
