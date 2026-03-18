import SwiftUI

// MARK: - Habit Categories View

struct HabitCategoriesView: View {
    let category: HabitCategory
    @State private var addedHabits: Set<UUID> = []

    private var habits: [CategoryHabitItem] {
        CategoryHabitItem.habitsFor(category)
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    // Category Header
                    categoryHeader

                    // Habits List
                    VStack(spacing: HLSpacing.xs) {
                        ForEach(habits) { habit in
                            CategoryHabitRow(
                                habit: habit,
                                isAdded: addedHabits.contains(habit.id),
                                onAdd: {
                                    withAnimation(HLAnimation.spring) {
                                        _ = addedHabits.insert(habit.id)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, HLSpacing.md)
                }
                .padding(.vertical, HLSpacing.sm)
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Category Header

    private var categoryHeader: some View {
        VStack(spacing: HLSpacing.sm) {
            Image(systemName: category.icon)
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(category.color)
                .frame(width: 72, height: 72)
                .background(category.color.opacity(0.15))
                .cornerRadius(HLRadius.xl)

            Text(category.rawValue)
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text("\(habits.count) habits available")
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.md)
    }
}

// MARK: - Category Habit Row

struct CategoryHabitRow: View {
    let habit: CategoryHabitItem
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: habit.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(habit.color)
                .frame(width: 40, height: 40)
                .background(habit.color.opacity(0.12))
                .cornerRadius(HLRadius.sm)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(habit.name)
                    .font(HLFont.body(.medium))
                    .foregroundColor(.hlTextPrimary)

                HStack(spacing: HLSpacing.xs) {
                    // Difficulty indicator
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(i < habit.difficulty ? habit.color : Color.hlDivider)
                                .frame(width: 16, height: 4)
                        }
                    }

                    Text(habit.difficultyLabel)
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }

                Text(habit.description)
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Button {
                onAdd()
            } label: {
                Image(systemName: isAdded ? "checkmark" : "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isAdded ? .white : .hlPrimary)
                    .frame(width: 32, height: 32)
                    .background(isAdded ? Color.hlPrimary : Color.hlPrimaryLight)
                    .cornerRadius(HLRadius.full)
            }
            .disabled(isAdded)
        }
        .hlCard()
    }
}

// MARK: - Category Habit Item Model

struct CategoryHabitItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let difficulty: Int // 1-3
    let description: String

    var difficultyLabel: String {
        switch difficulty {
        case 1: return "Easy"
        case 2: return "Medium"
        default: return "Hard"
        }
    }

    static func habitsFor(_ category: HabitCategory) -> [CategoryHabitItem] {
        switch category {
        case .health:
            return [
                CategoryHabitItem(name: "Drink 8 Glasses of Water", icon: "drop.fill", color: .hlHealth, difficulty: 1, description: "Stay hydrated throughout the day with regular water intake."),
                CategoryHabitItem(name: "Take Vitamins", icon: "pills.fill", color: .hlHealth, difficulty: 1, description: "Never miss your daily vitamins and supplements."),
                CategoryHabitItem(name: "Cold Shower", icon: "snowflake", color: .hlHealth, difficulty: 3, description: "Build resilience with cold exposure therapy."),
                CategoryHabitItem(name: "No Alcohol", icon: "wineglass", color: .hlHealth, difficulty: 2, description: "Track alcohol-free days for better health."),
            ]
        case .fitness:
            return [
                CategoryHabitItem(name: "Walk 10k Steps", icon: "figure.walk", color: .hlFitness, difficulty: 2, description: "Hit your daily step goal for cardiovascular health."),
                CategoryHabitItem(name: "Strength Training", icon: "dumbbell.fill", color: .hlFitness, difficulty: 2, description: "Build muscle with regular resistance training."),
                CategoryHabitItem(name: "Stretch for 10 Min", icon: "figure.flexibility", color: .hlFitness, difficulty: 1, description: "Improve flexibility and prevent injuries."),
                CategoryHabitItem(name: "Run 5K", icon: "figure.run", color: .hlFitness, difficulty: 3, description: "Train for and maintain a regular running habit."),
            ]
        case .mindfulness:
            return [
                CategoryHabitItem(name: "Morning Meditation", icon: "brain.head.profile", color: .hlMindfulness, difficulty: 1, description: "Start your day with 10 minutes of calm meditation."),
                CategoryHabitItem(name: "Practice Gratitude", icon: "heart.fill", color: .hlMindfulness, difficulty: 1, description: "Write down three things you are grateful for."),
                CategoryHabitItem(name: "Deep Breathing", icon: "wind", color: .hlMindfulness, difficulty: 1, description: "Practice box breathing for stress relief."),
                CategoryHabitItem(name: "Digital Detox", icon: "iphone.slash", color: .hlMindfulness, difficulty: 3, description: "Spend an hour device-free each day."),
            ]
        case .productivity:
            return [
                CategoryHabitItem(name: "Plan Your Day", icon: "checklist", color: .hlProductivity, difficulty: 1, description: "Spend 10 minutes planning your top priorities."),
                CategoryHabitItem(name: "Pomodoro Sessions", icon: "timer", color: .hlProductivity, difficulty: 2, description: "Complete focused work blocks with breaks."),
                CategoryHabitItem(name: "Inbox Zero", icon: "tray.fill", color: .hlProductivity, difficulty: 2, description: "Process and clear your email inbox daily."),
                CategoryHabitItem(name: "No Social Media", icon: "iphone.slash", color: .hlProductivity, difficulty: 3, description: "Avoid social media during work hours."),
            ]
        case .sleep:
            return [
                CategoryHabitItem(name: "Sleep by 11pm", icon: "moon.fill", color: .hlSleep, difficulty: 2, description: "Maintain a consistent bedtime for better rest."),
                CategoryHabitItem(name: "No Screens Before Bed", icon: "iphone.slash", color: .hlSleep, difficulty: 2, description: "Avoid blue light 30 minutes before sleep."),
                CategoryHabitItem(name: "Wind Down Routine", icon: "zzz", color: .hlSleep, difficulty: 1, description: "Follow a relaxing pre-sleep routine."),
            ]
        case .social:
            return [
                CategoryHabitItem(name: "Call a Friend", icon: "phone.fill", color: .hlSocial, difficulty: 1, description: "Stay connected with a daily phone call."),
                CategoryHabitItem(name: "Random Act of Kindness", icon: "hand.raised.fill", color: .hlSocial, difficulty: 1, description: "Do something nice for someone each day."),
            ]
        case .learning:
            return [
                CategoryHabitItem(name: "Read 30 Minutes", icon: "book.fill", color: .hlInfo, difficulty: 1, description: "Expand your knowledge with daily reading."),
                CategoryHabitItem(name: "Learn a Language", icon: "globe", color: .hlInfo, difficulty: 2, description: "Practice a new language for 15 minutes."),
                CategoryHabitItem(name: "Online Course", icon: "play.rectangle.fill", color: .hlInfo, difficulty: 2, description: "Complete one lesson from an online course."),
            ]
        case .nutrition:
            return [
                CategoryHabitItem(name: "Eat Vegetables", icon: "leaf.fill", color: .hlPrimary, difficulty: 1, description: "Include vegetables in every meal."),
                CategoryHabitItem(name: "No Sugar", icon: "xmark.circle", color: .hlPrimary, difficulty: 3, description: "Avoid added sugars for the day."),
                CategoryHabitItem(name: "Meal Prep", icon: "frying.pan.fill", color: .hlPrimary, difficulty: 2, description: "Prepare healthy meals in advance."),
            ]
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitCategoriesView(category: .fitness)
    }
}
