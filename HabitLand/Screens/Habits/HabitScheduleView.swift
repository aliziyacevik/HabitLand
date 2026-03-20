import SwiftUI
import SwiftData

struct HabitScheduleView: View {
    let habit: Habit

    @State private var selectedMonth = Date()

    private let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let shortDayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                weekView
                monthCalendar
                scheduleInfo
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Week View

    private var weekView: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Active Days")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            HStack(spacing: HLSpacing.xs) {
                ForEach(0..<7, id: \.self) { day in
                    let isActive = habit.targetDays.contains(day)
                    VStack(spacing: HLSpacing.xxs) {
                        Text(dayLabels[day])
                            .font(HLFont.caption(.medium))
                            .foregroundStyle(isActive ? Color.hlTextPrimary : Color.hlTextTertiary)

                        Circle()
                            .fill(isActive ? habit.color : Color.hlDivider)
                            .frame(width: 36, height: 36)
                            .overlay {
                                if isActive {
                                    Image(systemName: HLIcon.checkmark)
                                        .font(HLFont.caption(.bold))
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Month Calendar

    private var monthCalendar: some View {
        VStack(spacing: HLSpacing.sm) {
            // Month Navigation
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(HLFont.body(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                }

                Spacer()

                Text(monthYearString(selectedMonth))
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(HLFont.body(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                }
            }

            // Day Headers
            let columns = Array(repeating: GridItem(.flexible(), spacing: HLSpacing.xxs), count: 7)

            LazyVGrid(columns: columns, spacing: HLSpacing.xxs) {
                ForEach(shortDayLabels, id: \.self) { label in
                    Text(label)
                        .font(HLFont.caption2(.semibold))
                        .foregroundStyle(Color.hlTextTertiary)
                        .frame(height: 24)
                }
            }

            // Calendar Days
            LazyVGrid(columns: columns, spacing: HLSpacing.xxs) {
                ForEach(calendarDays(), id: \.self) { date in
                    if let date = date {
                        let completed = isDateCompleted(date)
                        let isToday = Calendar.current.isDateInToday(date)
                        let isScheduled = isDayScheduled(date)

                        VStack(spacing: HLSpacing.xxxs) {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(HLFont.subheadline(isToday ? .bold : .regular))
                                .foregroundStyle(isToday ? Color.hlPrimary : Color.hlTextPrimary)
                                .frame(width: 32, height: 32)
                                .background {
                                    if completed {
                                        Circle().fill(habit.color)
                                    } else if isToday {
                                        Circle().stroke(Color.hlPrimary, lineWidth: 1.5)
                                    }
                                }
                                .foregroundStyle(completed ? .white : (isToday ? Color.hlPrimary : Color.hlTextPrimary))

                            Circle()
                                .fill(isScheduled ? habit.color.opacity(0.4) : Color.clear)
                                .frame(width: 4, height: 4)
                        }
                    } else {
                        Color.clear.frame(height: 38)
                    }
                }
            }
        }
        .hlCard()
    }

    // MARK: - Schedule Info

    private var scheduleInfo: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Schedule Details")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            HStack(spacing: HLSpacing.sm) {
                Image(systemName: HLIcon.repeat_)
                    .foregroundStyle(habit.color)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("Frequency")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextTertiary)
                    Text(habit.frequency.rawValue)
                        .font(HLFont.body(.medium))
                        .foregroundStyle(Color.hlTextPrimary)
                }
                Spacer()
            }

            Divider().overlay(Color.hlDivider)

            HStack(spacing: HLSpacing.sm) {
                Image(systemName: HLIcon.target)
                    .foregroundStyle(habit.color)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("Daily Goal")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextTertiary)
                    Text("\(habit.goalCount) \(habit.unit)")
                        .font(HLFont.body(.medium))
                        .foregroundStyle(Color.hlTextPrimary)
                }
                Spacer()
            }

            Divider().overlay(Color.hlDivider)

            HStack(spacing: HLSpacing.sm) {
                Image(systemName: HLIcon.calendar)
                    .foregroundStyle(habit.color)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("Active Days")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextTertiary)
                    Text(activeDaysText)
                        .font(HLFont.body(.medium))
                        .foregroundStyle(Color.hlTextPrimary)
                }
                Spacer()
            }
        }
        .hlCard()
    }

    // MARK: - Helpers

    private var activeDaysText: String {
        let names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let active = habit.targetDays.sorted().map { names[$0] }
        return active.joined(separator: ", ")
    }

    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }

    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func calendarDays() -> [Date?] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let firstDay = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else {
            return []
        }

        let weekday = calendar.component(.weekday, from: firstDay) - 1
        var days: [Date?] = Array(repeating: nil, count: weekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }

    private func isDateCompleted(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        return habit.safeCompletions.contains { completion in
            calendar.startOfDay(for: completion.date) == day && completion.isCompleted
        }
    }

    private func isDayScheduled(_ date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date) - 1
        return habit.targetDays.contains(weekday)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitScheduleView(habit: {
            let h = Habit(name: "Exercise", icon: "figure.run", colorHex: "#338FFF", category: .fitness, frequency: .weekdays, targetDays: [1, 2, 3, 4, 5])
            h.completions = (0..<10).map { i in
                HabitCompletion(date: Calendar.current.date(byAdding: .day, value: -i * 2, to: Date())!)
            }
            return h
        }())
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
