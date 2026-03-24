import SwiftUI

struct NotificationSettingsView: View {
    @ScaledMetric(relativeTo: .footnote) private var settingsIconSize: CGFloat = 14
    @AppStorage("notif_master") private var masterToggle = true
    @AppStorage("notif_habits") private var habitReminders = true
    @AppStorage("notif_streaks") private var streakAlerts = true
    @AppStorage("notif_achievements") private var achievements = true
    @AppStorage("notif_social") private var socialNotifications = true
    @AppStorage("notif_quietHours") private var quietHoursEnabled = false
    @AppStorage("notif_quietStartHour") private var quietStartHour = 22
    @AppStorage("notif_quietStartMinute") private var quietStartMinute = 0
    @AppStorage("notif_quietEndHour") private var quietEndHour = 7
    @AppStorage("notif_quietEndMinute") private var quietEndMinute = 0
    @AppStorage("notif_sound") private var soundEnabled = true
    @AppStorage("notif_weeklySummary") private var weeklySummary = true

    private var quietHoursStart: Binding<Date> {
        Binding(
            get: { Calendar.current.date(from: DateComponents(hour: quietStartHour, minute: quietStartMinute)) ?? Date() },
            set: { newValue in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                quietStartHour = comps.hour ?? 22
                quietStartMinute = comps.minute ?? 0
            }
        )
    }

    private var quietHoursEnd: Binding<Date> {
        Binding(
            get: { Calendar.current.date(from: DateComponents(hour: quietEndHour, minute: quietEndMinute)) ?? Date() },
            set: { newValue in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                quietEndHour = comps.hour ?? 7
                quietEndMinute = comps.minute ?? 0
            }
        )
    }

    var body: some View {
        List {
            Section {
                Toggle(isOn: $masterToggle) {
                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text("Enable Notifications")
                            .font(HLFont.body())
                        Text("Turn off to mute all notifications")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextTertiary)
                    }
                }
                .tint(.hlPrimary)
            }

            if masterToggle {
                Section {
                    notificationToggle("Habit Reminders", subtitle: "Daily reminders for your habits", icon: "bell.fill", color: .hlPrimary, isOn: $habitReminders)
                    notificationToggle("Streak Alerts", subtitle: "Warnings when streaks are at risk", icon: "flame.fill", color: .hlFlame, isOn: $streakAlerts)
                    notificationToggle("Achievements", subtitle: "When you unlock new achievements", icon: "trophy.fill", color: .hlGold, isOn: $achievements)
                    notificationToggle("Social", subtitle: "Friend requests, challenges, messages", icon: "person.2.fill", color: .hlInfo, isOn: $socialNotifications)
                    notificationToggle("Weekly Summary", subtitle: "Progress recap every Sunday", icon: "chart.bar.fill", color: .hlMindfulness, isOn: $weeklySummary)
                } header: {
                    Text("Notification Types")
                }

                Section {
                    Toggle(isOn: $quietHoursEnabled) {
                        Text("Quiet Hours")
                            .font(HLFont.body())
                    }
                    .tint(.hlPrimary)

                    if quietHoursEnabled {
                        DatePicker("Start", selection: quietHoursStart, displayedComponents: .hourAndMinute)
                            .font(HLFont.body())
                            .tint(.hlPrimary)
                        DatePicker("End", selection: quietHoursEnd, displayedComponents: .hourAndMinute)
                            .font(HLFont.body())
                            .tint(.hlPrimary)
                    }
                } header: {
                    Text("Quiet Hours")
                } footer: {
                    Text("Notifications will be silenced during quiet hours")
                }

                Section {
                    Toggle(isOn: $soundEnabled) {
                        Text("Notification Sound")
                            .font(HLFont.body())
                    }
                    .tint(.hlPrimary)
                } header: {
                    Text("Sound")
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .animation(HLAnimation.standard, value: masterToggle)
        .animation(HLAnimation.standard, value: quietHoursEnabled)
        .onChange(of: weeklySummary) { _, enabled in
            if enabled {
                NotificationManager.shared.scheduleWeeklySummary()
            } else {
                NotificationManager.shared.cancelWeeklySummary()
            }
        }
    }

    private func notificationToggle(_ title: String, subtitle: String, icon: String, color: Color, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: min(settingsIconSize, 18)))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(color)
                    .cornerRadius(HLRadius.xs)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text(title)
                        .font(HLFont.body())
                    Text(subtitle)
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)
                }
            }
        }
        .tint(.hlPrimary)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
