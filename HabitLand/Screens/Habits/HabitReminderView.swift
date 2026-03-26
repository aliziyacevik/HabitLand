import SwiftUI
import SwiftData
import UserNotifications

struct HabitReminderView: View {
    @ScaledMetric(relativeTo: .title3) private var bellIconSize: CGFloat = 22
    @Bindable var habit: Habit
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var reminderEnabled: Bool
    @State private var reminderTime: Date
    @State private var repeatOption: ReminderRepeatOption = .daily
    @State private var customMessage = ""
    @State private var showTestConfirmation = false

    init(habit: Habit) {
        self.habit = habit
        _reminderEnabled = State(initialValue: habit.reminderEnabled)
        _reminderTime = State(initialValue: habit.reminderTime ?? Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date())
        _customMessage = State(initialValue: habit.reminderMessage)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                enableSection
                if reminderEnabled {
                    timeSection
                    repeatSection
                    messageSection
                    #if DEBUG
                    testButton
                    #endif
                }
                saveButton
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.md)
            .hlAdaptiveWidth()
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if showTestConfirmation {
                testNotificationOverlay
            }
        }
    }

    // MARK: - Enable Section

    private var enableSection: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.hlMindfulness.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: HLIcon.bell)
                        .font(.system(size: min(bellIconSize, 26)))
                        .foregroundStyle(Color.hlMindfulness)
                }

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("Reminders")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                    Text("Get notified to complete your habit")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary)
                }

                Spacer()

                Toggle("", isOn: $reminderEnabled)
                    .tint(Color.hlPrimary)
                    .labelsHidden()
            }
        }
        .hlCard()
    }

    // MARK: - Time Section

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Reminder Time")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
        }
        .hlCard()
    }

    // MARK: - Repeat Section

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Repeat")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            ForEach(ReminderRepeatOption.allCases, id: \.self) { option in
                Button {
                    repeatOption = option
                } label: {
                    HStack {
                        Image(systemName: option.icon)
                            .foregroundStyle(habit.color)
                            .frame(width: 24)
                        Text(option.rawValue)
                            .font(HLFont.body())
                            .foregroundStyle(Color.hlTextPrimary)
                        Spacer()
                        if repeatOption == option {
                            Image(systemName: HLIcon.checkmark)
                                .font(HLFont.body(.semibold))
                                .foregroundStyle(Color.hlPrimary)
                        }
                    }
                    .padding(.vertical, HLSpacing.xxs)
                }

                if option != ReminderRepeatOption.allCases.last {
                    Divider().overlay(Color.hlDivider)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Message Section

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Custom Message")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            Text("Leave empty for default message")
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextTertiary)

            TextField("e.g. Time to meditate!", text: $customMessage)
                .font(HLFont.body())
                .padding(HLSpacing.sm)
                .background(Color.hlBackground)
                .cornerRadius(HLRadius.md)

            // Preview
            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                Text("Preview")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextTertiary)

                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: habit.icon)
                        .font(HLFont.body())
                        .foregroundStyle(habit.color)
                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text("HabitLand")
                            .font(HLFont.caption(.semibold))
                            .foregroundStyle(Color.hlTextPrimary)
                        Text(customMessage.isEmpty ? "Time for \(habit.name)!" : customMessage)
                            .font(HLFont.subheadline())
                            .foregroundStyle(Color.hlTextSecondary)
                    }
                    Spacer()
                    Text("now")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                }
                .padding(HLSpacing.sm)
                .background(Color.hlBackground)
                .cornerRadius(HLRadius.md)
            }
        }
        .hlCard()
    }

    // MARK: - Test Button

    private var testButton: some View {
        Button {
            // Send actual test notification with icon attachment
            NotificationManager.shared.scheduleTestNotification(
                habitId: habit.id,
                habitName: habit.name,
                icon: habit.icon,
                customMessage: customMessage
            )

            withAnimation(HLAnimation.spring) {
                showTestConfirmation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(HLAnimation.standard) {
                    showTestConfirmation = false
                }
            }
        } label: {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "bell.badge")
                Text("Send Test Notification")
            }
            .font(HLFont.body(.medium))
            .foregroundStyle(Color.hlInfo)
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.sm)
            .background(Color.hlInfo.opacity(0.1))
            .cornerRadius(HLRadius.lg)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            habit.reminderEnabled = reminderEnabled
            habit.reminderTime = reminderEnabled ? reminderTime : nil
            habit.reminderMessage = customMessage
            habit.updatedAt = Date()
            try? modelContext.save()

            // Cancel existing and reschedule if enabled
            NotificationManager.shared.cancelHabitReminder(habitId: habit.id)
            if reminderEnabled {
                NotificationManager.shared.scheduleHabitReminder(
                    habitId: habit.id,
                    habitName: habit.name,
                    at: reminderTime,
                    customMessage: customMessage
                )
            }

            dismiss()
        } label: {
            Text("Save Reminder Settings")
                .font(HLFont.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.md)
                .background(Color.hlPrimary)
                .cornerRadius(HLRadius.lg)
        }
        .padding(.top, HLSpacing.xs)
    }

    // MARK: - Test Overlay

    private var testNotificationOverlay: some View {
        VStack {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: HLIcon.checkmark)
                    .font(HLFont.body(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.hlSuccess)
                    .clipShape(Circle())
                Text("Test notification sent!")
                    .font(HLFont.body(.medium))
                    .foregroundStyle(Color.hlTextPrimary)
            }
            .hlCard(shadow: HLShadow.lg)
            .transition(.move(edge: .top).combined(with: .opacity))

            Spacer()
        }
        .padding(.top, HLSpacing.md)
    }
}

// MARK: - Repeat Option

enum ReminderRepeatOption: String, CaseIterable {
    case daily = "Every Day"
    case scheduledDays = "Scheduled Days Only"
    case weekdays = "Weekdays Only"
    case weekends = "Weekends Only"

    var icon: String {
        switch self {
        case .daily: return "arrow.triangle.2.circlepath"
        case .scheduledDays: return "calendar"
        case .weekdays: return "briefcase"
        case .weekends: return "sun.max"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitReminderView(habit: Habit(name: "Morning Meditation", icon: "brain.head.profile", colorHex: "#9966E6", category: .mindfulness, reminderEnabled: true))
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
