import SwiftUI
import SwiftData

struct StarterHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let colorHex: String
    let category: HabitCategory
}

private let availableStarterHabits: [StarterHabit] = [
    StarterHabit(name: "Drink Water", icon: "drop.fill", colorHex: "#338FFF", category: .health),
    StarterHabit(name: "Morning Walk", icon: "figure.walk", colorHex: "#34C759", category: .fitness),
    StarterHabit(name: "Meditate", icon: "brain.head.profile", colorHex: "#9966E6", category: .mindfulness),
    StarterHabit(name: "Read 20 min", icon: "book.fill", colorHex: "#FF9A1A", category: .learning),
    StarterHabit(name: "Stretch", icon: "figure.flexibility", colorHex: "#F27D8D", category: .fitness),
    StarterHabit(name: "Journal", icon: "pencil", colorHex: "#6659CC", category: .mindfulness),
    StarterHabit(name: "Eat Healthy", icon: "fork.knife", colorHex: "#34C759", category: .nutrition),
    StarterHabit(name: "No Phone Before Bed", icon: "moon.fill", colorHex: "#6659CC", category: .sleep),
    StarterHabit(name: "Exercise 30 min", icon: "dumbbell.fill", colorHex: "#338FFF", category: .fitness),
    StarterHabit(name: "Learn Something New", icon: "graduationcap.fill", colorHex: "#FF9A1A", category: .learning),
    StarterHabit(name: "Take Vitamins", icon: "pill.fill", colorHex: "#F24D4D", category: .health),
    StarterHabit(name: "Practice Gratitude", icon: "heart.fill", colorHex: "#F27D8D", category: .mindfulness),
]

struct StarterHabitsView: View {
    @Environment(\.modelContext) private var modelContext
    var onComplete: () -> Void = {}

    @State private var selectedHabits: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: HLSpacing.xs) {
                Text("Pick Your Habits")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlTextPrimary)

                Text("Choose a few to get started. You can always add more later.")
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HLSpacing.lg)
            }
            .padding(.top, HLSpacing.xl)
            .padding(.bottom, HLSpacing.lg)

            // Habit Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HLSpacing.sm) {
                    ForEach(availableStarterHabits) { habit in
                        starterHabitCard(habit)
                    }
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.bottom, HLSpacing.xxxl)
            }

            // Bottom bar
            VStack(spacing: HLSpacing.sm) {
                HLButton(
                    selectedHabits.isEmpty ? "Skip for Now" : "Add \(selectedHabits.count) Habits",
                    icon: selectedHabits.isEmpty ? nil : "plus",
                    style: selectedHabits.isEmpty ? .secondary : .primary,
                    size: .lg,
                    isFullWidth: true
                ) {
                    createSelectedHabits()
                    onComplete()
                }

                if !selectedHabits.isEmpty {
                    Text("Free users can track up to 3 habits")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
            .background(Color.hlBackground)
        }
        .background(Color.hlBackground.ignoresSafeArea())
    }

    private func starterHabitCard(_ habit: StarterHabit) -> some View {
        let isSelected = selectedHabits.contains(habit.id)
        let atLimit = selectedHabits.count >= 3 && !isSelected && !ProManager.shared.isPro

        return Button {
            if isSelected {
                selectedHabits.remove(habit.id)
            } else if !atLimit {
                selectedHabits.insert(habit.id)
            } else {
                HLHaptics.warning()
            }
            HLHaptics.selection()
        } label: {
            VStack(spacing: HLSpacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .fill((Color(hex: habit.colorHex) ?? .hlPrimary).opacity(isSelected ? 0.2 : 0.08))
                        .frame(height: 56)

                    Image(systemName: habit.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: habit.colorHex) ?? .hlPrimary)
                }

                Text(habit.name)
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextPrimary)
                    .lineLimit(1)
            }
            .padding(HLSpacing.sm)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .stroke(isSelected ? (Color(hex: habit.colorHex) ?? .hlPrimary) : Color.hlCardBorder, lineWidth: isSelected ? 2 : 1)
            )
            .opacity(atLimit ? 0.5 : 1)
        }
        .animation(HLAnimation.microSpring, value: isSelected)
    }

    private func createSelectedHabits() {
        let selected = availableStarterHabits.filter { selectedHabits.contains($0.id) }
        for (index, starter) in selected.enumerated() {
            let habit = Habit(
                name: starter.name,
                icon: starter.icon,
                colorHex: starter.colorHex,
                category: starter.category,
                sortOrder: index
            )
            modelContext.insert(habit)
        }
        try? modelContext.save()
    }
}

#Preview {
    StarterHabitsView()
        .modelContainer(for: Habit.self, inMemory: true)
}
