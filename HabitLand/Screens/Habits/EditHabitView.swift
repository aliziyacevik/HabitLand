import SwiftUI
import SwiftData

struct EditHabitView: View {
    @ScaledMetric(relativeTo: .body) private var iconPreviewSize: CGFloat = 20
    @ScaledMetric(relativeTo: .body) private var iconButtonSize: CGFloat = 40
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColorHex: String
    @State private var selectedCategory: HabitCategory
    @State private var frequency: HabitFrequency
    @State private var customDays: Set<Int>
    @State private var goalCount: Int
    @State private var unit: String
    @State private var reminderEnabled: Bool
    @State private var reminderTime: Date
    @State private var showDeleteAlert = false
    @State private var selectedHealthMetric: HealthKitMetric?
    @StateObject private var healthKit = HealthKitManager.shared

    private let iconOptions = [
        "checkmark.circle", "star.fill", "heart.fill", "bolt.fill",
        "flame.fill", "drop.fill", "leaf.fill", "brain.head.profile",
        "figure.run", "figure.walk", "book.fill", "pencil",
        "moon.fill", "sun.max.fill", "cup.and.saucer.fill", "fork.knife",
        "pill.fill", "cross.fill", "bed.double.fill", "music.note",
        "paintbrush.fill", "camera.fill", "phone.fill", "bubble.left.fill",
        "target", "flag.fill", "trophy.fill", "medal.fill",
        "dumbbell.fill", "bicycle", "note.text", "graduationcap.fill"
    ]

    private let colorOptions = [
        "#34C759", "#338FFF", "#9966E6", "#F24D4D",
        "#FFC207", "#FF9A1A", "#F27D8D", "#6659CC",
        "#00BCD4", "#8BC34A", "#795548", "#607D8B"
    ]

    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    init(habit: Habit) {
        self.habit = habit
        _name = State(initialValue: habit.name)
        _selectedIcon = State(initialValue: habit.icon)
        _selectedColorHex = State(initialValue: habit.colorHex)
        _selectedCategory = State(initialValue: habit.category)
        _frequency = State(initialValue: habit.frequency)
        _customDays = State(initialValue: Set(habit.targetDays))
        _goalCount = State(initialValue: habit.goalCount)
        _unit = State(initialValue: habit.unit)
        _reminderEnabled = State(initialValue: habit.reminderEnabled)
        _reminderTime = State(initialValue: habit.reminderTime ?? Date())
        _selectedHealthMetric = State(initialValue: habit.healthKitMetric.flatMap { HealthKitMetric(rawValue: $0) })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    nameSection
                    iconSection
                    colorSection
                    categorySection
                    frequencySection
                    goalSection
                    if healthKit.isAvailable {
                        healthKitSection
                    }
                    reminderSection
                    saveButton
                    deleteButton
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.md)
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: HLIcon.close)
                            .foregroundStyle(Color.hlTextPrimary)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .alert("Delete Habit?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(habit)
                    try? modelContext.save()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All completion history will be lost.")
            }
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Habit Name")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)
            TextField("e.g. Morning Meditation", text: $name)
                .font(HLFont.body())
                .padding(HLSpacing.sm)
                .background(Color.hlSurface)
                .cornerRadius(HLRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .stroke(Color.hlCardBorder, lineWidth: 1)
                )
                .onChange(of: name) { _, newValue in
                    if newValue.count > 50 {
                        name = String(newValue.prefix(50))
                    }
                }
        }
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Icon")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            let columns = Array(repeating: GridItem(.flexible(), spacing: HLSpacing.xs), count: 8)
            LazyVGrid(columns: columns, spacing: HLSpacing.xs) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                    } label: {
                        Image(systemName: icon)
                            .font(.system(size: min(iconPreviewSize, 24)))
                            .foregroundStyle(selectedIcon == icon ? .white : Color.hlTextSecondary)
                            .frame(width: min(iconButtonSize, 56), height: min(iconButtonSize, 56))
                            .background(selectedIcon == icon ? selectedColor : Color.hlSurface)
                            .cornerRadius(HLRadius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: HLRadius.sm)
                                    .stroke(selectedIcon == icon ? Color.clear : Color.hlCardBorder, lineWidth: 1)
                            )
                    }
                }
            }
            .hlCard()
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Color")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.sm) {
                    ForEach(colorOptions, id: \.self) { hex in
                        Button {
                            selectedColorHex = hex
                        } label: {
                            Circle()
                                .fill(Color(hex: hex) ?? .gray)
                                .frame(width: min(iconButtonSize, 56), height: min(iconButtonSize, 56))
                                .overlay {
                                    if selectedColorHex == hex {
                                        Circle().stroke(.white, lineWidth: 3).padding(HLSpacing.xxxs)
                                        Circle().stroke(Color(hex: hex) ?? .gray, lineWidth: 2)
                                    }
                                }
                        }
                    }
                }
                .padding(.vertical, HLSpacing.xxs)
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Category")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            FlowLayout(spacing: HLSpacing.xs) {
                ForEach(HabitCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: HLSpacing.xxs) {
                            Image(systemName: category.icon)
                                .font(HLFont.caption())
                            Text(category.rawValue)
                                .font(HLFont.subheadline(.medium))
                        }
                        .foregroundStyle(selectedCategory == category ? .white : category.color)
                        .padding(.horizontal, HLSpacing.sm)
                        .padding(.vertical, HLSpacing.xs)
                        .background(selectedCategory == category ? category.color : category.color.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Frequency")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            Picker("Frequency", selection: $frequency) {
                ForEach(HabitFrequency.allCases, id: \.self) { freq in
                    Text(freq.rawValue).tag(freq)
                }
            }
            .pickerStyle(.segmented)

            if frequency == .custom {
                HStack(spacing: HLSpacing.xs) {
                    ForEach(0..<7, id: \.self) { day in
                        Button {
                            if customDays.contains(day) {
                                customDays.remove(day)
                            } else {
                                customDays.insert(day)
                            }
                        } label: {
                            Text(dayLabels[day])
                                .font(HLFont.subheadline(.semibold))
                                .foregroundStyle(customDays.contains(day) ? .white : Color.hlTextSecondary)
                                .frame(width: min(iconButtonSize, 56), height: min(iconButtonSize, 56))
                                .background(customDays.contains(day) ? selectedColor : Color.hlSurface)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(customDays.contains(day) ? Color.clear : Color.hlCardBorder, lineWidth: 1)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, HLSpacing.xxs)
            }
        }
    }

    private var goalSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Daily Goal")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            HStack(spacing: HLSpacing.md) {
                Stepper(value: $goalCount, in: 1...99) {
                    HStack(spacing: HLSpacing.xs) {
                        Text("\(goalCount)")
                            .font(HLFont.title3(.bold))
                            .foregroundStyle(Color.hlTextPrimary)
                        Text("per day")
                            .font(HLFont.subheadline())
                            .foregroundStyle(Color.hlTextSecondary)
                    }
                }
            }
            .hlCard()

            TextField("Unit (e.g. glasses, minutes, pages)", text: $unit)
                .font(HLFont.body())
                .padding(HLSpacing.sm)
                .background(Color.hlSurface)
                .cornerRadius(HLRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .stroke(Color.hlCardBorder, lineWidth: 1)
                )
        }
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Reminder")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            VStack(spacing: HLSpacing.sm) {
                Toggle(isOn: $reminderEnabled) {
                    HStack(spacing: HLSpacing.xs) {
                        Image(systemName: HLIcon.bell)
                            .foregroundStyle(Color.hlMindfulness)
                        Text("Enable Reminder")
                            .font(HLFont.body())
                            .foregroundStyle(Color.hlTextPrimary)
                    }
                }
                .tint(Color.hlPrimary)
                .onChange(of: reminderEnabled) { _, enabled in
                    if enabled {
                        Task {
                            _ = await NotificationManager.shared.requestPermission()
                        }
                    }
                }

                if reminderEnabled {
                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .font(HLFont.body())
                        .foregroundStyle(Color.hlTextPrimary)
                }
            }
            .hlCard()
        }
    }

    // MARK: - HealthKit

    private var healthKitSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.hlHealth)
                Text("Apple Health")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            Text("Auto-complete this habit from Health data")
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextSecondary)

            VStack(spacing: HLSpacing.xxs) {
                Button {
                    selectedHealthMetric = nil
                    HLHaptics.selection()
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(Color.hlTextTertiary)
                        Text("Manual tracking")
                            .font(HLFont.body())
                            .foregroundStyle(Color.hlTextPrimary)
                        Spacer()
                        if selectedHealthMetric == nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.hlPrimary)
                        }
                    }
                    .padding(.vertical, HLSpacing.xs)
                    .padding(.horizontal, HLSpacing.sm)
                }

                ForEach(HealthKitMetric.allCases) { metric in
                    Button {
                        selectedHealthMetric = metric
                        goalCount = metric.defaultGoal
                        unit = metric.unit
                        HLHaptics.selection()
                    } label: {
                        HStack {
                            Image(systemName: metric.icon)
                                .foregroundStyle(Color.hlPrimary)
                                .frame(width: 24)
                            Text(metric.rawValue)
                                .font(HLFont.body())
                                .foregroundStyle(Color.hlTextPrimary)
                            Spacer()
                            Text("\(metric.defaultGoal) \(metric.unit)")
                                .font(HLFont.caption())
                                .foregroundStyle(Color.hlTextTertiary)
                            if selectedHealthMetric == metric {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.hlPrimary)
                            }
                        }
                        .padding(.vertical, HLSpacing.xs)
                        .padding(.horizontal, HLSpacing.sm)
                    }
                }
            }
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .stroke(Color.hlCardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Buttons

    private var saveButton: some View {
        Button {
            saveChanges()
        } label: {
            Text("Save Changes")
                .font(HLFont.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.md)
                .background(name.trimmingCharacters(in: .whitespaces).isEmpty || (frequency == .custom && customDays.isEmpty) ? Color.hlTextTertiary : Color.hlPrimary)
                .cornerRadius(HLRadius.lg)
        }
        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || (frequency == .custom && customDays.isEmpty))
        .padding(.top, HLSpacing.xs)
    }

    private var deleteButton: some View {
        Button {
            showDeleteAlert = true
        } label: {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: HLIcon.delete)
                Text("Delete Habit")
            }
            .font(HLFont.body(.medium))
            .foregroundStyle(Color.hlError)
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.sm)
        }
    }

    // MARK: - Helpers

    private var selectedColor: Color {
        Color(hex: selectedColorHex) ?? .hlPrimary
    }

    private var targetDays: [Int] {
        switch frequency {
        case .daily: return [0, 1, 2, 3, 4, 5, 6]
        case .weekdays: return [1, 2, 3, 4, 5]
        case .weekends: return [0, 6]
        case .custom: return Array(customDays).sorted()
        }
    }

    private func saveChanges() {
        habit.name = name
        habit.icon = selectedIcon
        habit.colorHex = selectedColorHex
        habit.category = selectedCategory
        habit.frequency = frequency
        habit.targetDays = targetDays
        habit.goalCount = goalCount
        habit.unit = unit
        habit.reminderEnabled = reminderEnabled
        habit.reminderTime = reminderEnabled ? reminderTime : nil
        habit.healthKitMetric = selectedHealthMetric?.rawValue
        habit.updatedAt = Date()

        // Reschedule or cancel notification
        NotificationManager.shared.cancelHabitReminder(habitId: habit.id)
        if reminderEnabled {
            NotificationManager.shared.scheduleHabitReminder(
                habitId: habit.id,
                habitName: name,
                icon: selectedIcon,
                at: reminderTime
            )
        }

        dismiss()
    }
}

// MARK: - Preview

#Preview {
    EditHabitView(habit: Habit(name: "Morning Meditation", icon: "brain.head.profile", colorHex: "#9966E6", category: .mindfulness))
        .modelContainer(for: Habit.self, inMemory: true)
}
