import SwiftUI
import SwiftData

// MARK: - Reminder Settings View

struct ReminderSettingsView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }, sort: \Habit.name)
    private var habits: [Habit]

    @State private var remindersEnabled = true
    @State private var defaultReminderTime = Calendar.current.date(
        from: DateComponents(hour: 9, minute: 0)
    ) ?? Date()
    @State private var smartRemindersEnabled = true
    @State private var quietHoursEnabled = true
    @State private var quietHoursStart = Calendar.current.date(
        from: DateComponents(hour: 22, minute: 0)
    ) ?? Date()
    @State private var quietHoursEnd = Calendar.current.date(
        from: DateComponents(hour: 7, minute: 0)
    ) ?? Date()

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            Form {
                // Master Toggle
                Section {
                    Toggle(isOn: $remindersEnabled) {
                        Label {
                            Text("Enable Reminders")
                                .font(HLFont.body())
                        } icon: {
                            Image(systemName: HLIcon.bell)
                                .foregroundColor(.hlPrimary)
                        }
                    }
                    .tint(.hlPrimary)
                } footer: {
                    Text("Turn off to silence all habit reminders.")
                        .font(HLFont.caption())
                }

                if remindersEnabled {
                    // Default Time
                    Section("Default Reminder Time") {
                        DatePicker(
                            "Default Time",
                            selection: $defaultReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .font(HLFont.body())
                    }

                    // Smart Reminders
                    Section {
                        Toggle(isOn: $smartRemindersEnabled) {
                            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                                Text("Smart Reminders")
                                    .font(HLFont.body())
                                Text("Automatically adjust timing based on your patterns")
                                    .font(HLFont.caption())
                                    .foregroundColor(.hlTextSecondary)
                            }
                        }
                        .tint(.hlPrimary)
                    }

                    // Quiet Hours
                    Section {
                        Toggle(isOn: $quietHoursEnabled) {
                            Label {
                                Text("Quiet Hours")
                                    .font(HLFont.body())
                            } icon: {
                                Image(systemName: HLIcon.moon)
                                    .foregroundColor(.hlSleep)
                            }
                        }
                        .tint(.hlPrimary)

                        if quietHoursEnabled {
                            DatePicker(
                                "From",
                                selection: $quietHoursStart,
                                displayedComponents: .hourAndMinute
                            )
                            .font(HLFont.body())

                            DatePicker(
                                "Until",
                                selection: $quietHoursEnd,
                                displayedComponents: .hourAndMinute
                            )
                            .font(HLFont.body())
                        }
                    } footer: {
                        if quietHoursEnabled {
                            Text("No reminders will be sent during quiet hours.")
                                .font(HLFont.caption())
                        }
                    }

                    // Habit-Specific Overrides
                    if !habits.isEmpty {
                        Section("Habit-Specific Reminders") {
                            ForEach(habits) { habit in
                                HabitReminderRow(habit: habit)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Reminder Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Habit Reminder Row

struct HabitReminderRow: View {
    @Bindable var habit: Habit

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: { habit.reminderTime ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date() },
            set: { habit.reminderTime = $0 }
        )
    }

    var body: some View {
        VStack(spacing: HLSpacing.xs) {
            HStack {
                Image(systemName: habit.icon)
                    .foregroundColor(habit.color)
                    .frame(width: 24)

                Text(habit.name)
                    .font(HLFont.body())

                Spacer()

                Toggle("", isOn: $habit.reminderEnabled)
                    .tint(.hlPrimary)
                    .labelsHidden()
            }

            if habit.reminderEnabled {
                DatePicker(
                    "Time",
                    selection: reminderTimeBinding,
                    displayedComponents: .hourAndMinute
                )
                .font(HLFont.footnote())
                .foregroundColor(.hlTextSecondary)
            }
        }
        .padding(.vertical, HLSpacing.xxxs)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ReminderSettingsView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
