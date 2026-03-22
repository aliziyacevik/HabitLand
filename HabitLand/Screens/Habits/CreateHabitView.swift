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
    @State private var showTemplateBrowser = false
    @State private var selectedHealthMetric: HealthKitMetric?
    @StateObject private var healthKit = HealthKitManager.shared

    private let iconOptions = [
        "checkmark.circle", "star.fill", "heart.fill", "bolt.fill",
        "flame.fill", "drop.fill", "leaf.fill", "brain.head.profile",
        "figure.run", "figure.walk", "figure.stand", "book.fill",
        "pencil", "moon.fill", "sun.max.fill", "cup.and.saucer.fill",
        "fork.knife", "pill.fill", "cross.fill", "bed.double.fill",
        "music.note", "paintbrush.fill", "camera.fill", "map.fill",
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
                    browseTemplatesButton
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
                .onChange(of: name) { _, newValue in
                    if newValue.count > 50 {
                        name = String(newValue.prefix(50))
                    }
                }

            Text("\(name.count)/50")
                .font(HLFont.caption2())
                .foregroundColor(name.count >= 45 ? .hlError : .hlTextTertiary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    // MARK: - Icon Picker

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Icon")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            let columns = Array(repeating: GridItem(.flexible(), spacing: HLSpacing.xs), count: 6)
            LazyVGrid(columns: columns, spacing: HLSpacing.xs) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                    } label: {
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundStyle(selectedIcon == icon ? .white : Color.hlTextSecondary)
                            .frame(width: 44, height: 44)
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
                // None option
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
                        // Auto-fill all fields from metric
                        if name.isEmpty || HealthKitMetric.allCases.contains(where: { $0.suggestedName == name }) {
                            name = metric.suggestedName
                        }
                        selectedIcon = metric.icon
                        selectedColorHex = metric.suggestedColorHex
                        selectedCategory = HabitCategory(rawValue: metric.suggestedCategory) ?? .health
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
                .background(name.trimmingCharacters(in: .whitespaces).isEmpty || (frequency == .custom && customDays.isEmpty) ? Color.hlTextTertiary : Color.hlPrimary)
                .cornerRadius(HLRadius.lg)
        }
        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || (frequency == .custom && customDays.isEmpty))
        .padding(.top, HLSpacing.xs)
    }

    // MARK: - Browse Templates

    private var browseTemplatesButton: some View {
        Button {
            showTemplateBrowser = true
        } label: {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.hlGold)
                    .frame(width: 40, height: 40)
                    .background(Color.hlGold.opacity(0.12))
                    .cornerRadius(HLRadius.sm)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("Browse Templates")
                        .font(HLFont.body(.medium))
                        .foregroundColor(.hlTextPrimary)
                    Text("Choose from \(HabitTemplateLibrary.all.count)+ ready-made habits")
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.hlTextTertiary)
            }
            .hlCard()
        }
        .sheet(isPresented: $showTemplateBrowser) {
            NavigationStack {
                TemplateBrowserView(
                    onSelect: { template in
                        applyTemplate(template)
                        showTemplateBrowser = false
                    },
                    onPackSelect: { templates in
                        let existingCount = (try? modelContext.fetchCount(FetchDescriptor<Habit>(predicate: #Predicate { !$0.isArchived }))) ?? 0
                        let limit = ProManager.shared.isPro ? Int.max : ProManager.freeHabitLimit
                        let available = max(0, limit - existingCount)

                        let toAdd = Array(templates.prefix(available))
                        guard !toAdd.isEmpty else { return }

                        for (index, template) in toAdd.enumerated() {
                            let habit = template.toHabit(sortOrder: index)
                            modelContext.insert(habit)
                        }
                        try? modelContext.save()
                        AchievementManager.checkAll(context: modelContext)
                        // Close both browser and create view
                        showTemplateBrowser = false
                        dismiss()
                    }
                )
                .navigationTitle("Choose a Template")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") { showTemplateBrowser = false }
                    }
                }
            }
            .hlSheetContent()
        }
    }

    private func applyTemplate(_ template: HabitTemplate) {
        name = template.name
        selectedIcon = template.icon
        selectedColorHex = template.colorHex
        selectedCategory = template.category
        frequency = template.frequency
        if template.frequency == .custom {
            customDays = Set(template.targetDays)
        }
        goalCount = template.goalCount
        unit = template.unit
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
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        guard frequency != .custom || !customDays.isEmpty else { return }

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
        habit.healthKitMetric = selectedHealthMetric?.rawValue
        modelContext.insert(habit)

        if reminderEnabled {
            NotificationManager.shared.scheduleHabitReminder(
                habitId: habit.id,
                habitName: habit.name,
                icon: habit.icon,
                at: reminderTime
            )
        }

        // Request HealthKit authorization if needed
        if let metric = selectedHealthMetric {
            Task {
                _ = await healthKit.requestAuthorization(for: [metric])
            }
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
