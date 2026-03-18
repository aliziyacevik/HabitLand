import SwiftUI

struct HabitSettingsView: View {
    @AppStorage("habit_reminderHour") private var reminderHour = 9
    @AppStorage("habit_reminderMinute") private var reminderMinute = 0
    @AppStorage("habit_weekStartsOn") private var weekStartsOn = 1
    @AppStorage("habit_showArchived") private var showArchived = false
    @AppStorage("habit_completionSound") private var completionSound = true
    @AppStorage("habit_hapticFeedback") private var hapticFeedback = true
    @AppStorage("habit_autoArchiveDays") private var autoArchiveDays = 30

    private var defaultReminderTime: Binding<Date> {
        Binding(
            get: { Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? Date() },
            set: { newValue in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = comps.hour ?? 9
                reminderMinute = comps.minute ?? 0
            }
        )
    }

    private let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        List {
            Section {
                DatePicker("Default Reminder Time", selection: defaultReminderTime, displayedComponents: .hourAndMinute)
                    .font(HLFont.body())
                    .tint(.hlPrimary)

                Picker("Week Starts On", selection: $weekStartsOn) {
                    ForEach(0..<weekdays.count, id: \.self) { i in
                        Text(weekdays[i]).tag(i)
                    }
                }
                .font(HLFont.body())
            } header: {
                Text("Schedule")
            }

            Section {
                Toggle(isOn: $showArchived) {
                    Text("Show Archived Habits")
                        .font(HLFont.body())
                }
                .tint(.hlPrimary)

                HStack {
                    Text("Auto-Archive After")
                        .font(HLFont.body())
                    Spacer()
                    Picker("", selection: $autoArchiveDays) {
                        Text("Never").tag(0)
                        Text("30 days").tag(30)
                        Text("60 days").tag(60)
                        Text("90 days").tag(90)
                    }
                    .pickerStyle(.menu)
                    .tint(.hlPrimary)
                }
            } header: {
                Text("Display")
            }

            Section {
                Toggle(isOn: $completionSound) {
                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text("Completion Sound")
                            .font(HLFont.body())
                        Text("Play a sound when you complete a habit")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextTertiary)
                    }
                }
                .tint(.hlPrimary)

                Toggle(isOn: $hapticFeedback) {
                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text("Haptic Feedback")
                            .font(HLFont.body())
                        Text("Vibrate on habit completion")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextTertiary)
                    }
                }
                .tint(.hlPrimary)
            } header: {
                Text("Feedback")
            }
        }
        .navigationTitle("Habit Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HabitSettingsView()
    }
}
