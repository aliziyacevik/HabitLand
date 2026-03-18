import SwiftUI
import SwiftData

struct CreateHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "checkmark.circle"
    @State private var selectedColorHex = "#34C759"
    @State private var selectedCategory: HabitCategory = .health
    @State private var frequency: HabitFrequency = .daily
    @State private var customDays: Set<Int> = []
    @State private var goalCount = 1
    @State private var unit = "times"
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @State private var showIconPicker = false

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
                    reminderSection
                    createButton
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.md)
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: HLIcon.close)
                            .foregroundStyle(Color.hlTextPrimary)
                    }
                    .accessibilityLabel("Cancel")
                }
            }
        }
    }

    // MARK: - Name

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
        }
    }

    // MARK: - Icon Picker

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
                            .font(.system(size: 20))
                            .foregroundStyle(selectedIcon == icon ? .white : Color.hlTextSecondary)
                            .frame(width: 40, height: 40)
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

    // MARK: - Color Picker

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
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if selectedColorHex == hex {
                                        Circle()
                                            .stroke(.white, lineWidth: 3)
                                            .padding(2)
                                        Circle()
                                            .stroke(Color(hex: hex) ?? .gray, lineWidth: 2)
                                    }
                                }
                        }
                    }
                }
                .padding(.vertical, HLSpacing.xxs)
            }
        }
    }

    // MARK: - Category

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

    // MARK: - Frequency

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
                                .frame(width: 40, height: 40)
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

    // MARK: - Goal

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

    // MARK: - Reminder

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

                if reminderEnabled {
                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .font(HLFont.body())
                        .foregroundStyle(Color.hlTextPrimary)
                }
            }
            .hlCard()
        }
    }

    // MARK: - Create Button

    private var createButton: some View {
        Button {
            createHabit()
        } label: {
            Text("Create Habit")
                .font(HLFont.headline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.md)
                .background(name.isEmpty ? Color.hlTextTertiary : Color.hlPrimary)
                .cornerRadius(HLRadius.lg)
        }
        .disabled(name.isEmpty)
        .padding(.top, HLSpacing.xs)
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

    private func createHabit() {
        let habit = Habit(
            name: name,
            icon: selectedIcon,
            colorHex: selectedColorHex,
            category: selectedCategory,
            frequency: frequency,
            targetDays: targetDays,
            reminderTime: reminderEnabled ? reminderTime : nil,
            reminderEnabled: reminderEnabled,
            goalCount: goalCount,
            unit: unit
        )
        modelContext.insert(habit)

        if reminderEnabled {
            NotificationManager.shared.scheduleHabitReminder(
                habitId: habit.id,
                habitName: habit.name,
                icon: habit.icon,
                at: reminderTime
            )
        }

        dismiss()
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            guard index < result.positions.count else { break }
            let position = result.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(subview.sizeThatFits(.unspecified))
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}

// MARK: - Preview

#Preview {
    CreateHabitView()
        .modelContainer(for: Habit.self, inMemory: true)
}
