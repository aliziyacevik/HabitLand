import SwiftUI
import SwiftData
import UIKit

// MARK: - Recommended Habits View

struct RecommendedHabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var addedHabits: Set<UUID> = []

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HLSpacing.lg) {
                    // Header
                    header

                    // Based on Your Goals
                    goalsSection

                    // Recommended Cards
                    recommendedCards
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.sm)
            }
        }
        .navigationTitle("Recommended")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: HLSpacing.sm) {
            Image(systemName: HLIcon.sparkles)
                .font(.system(size: 36))
                .foregroundColor(.hlGold)

            Text("Recommended for You")
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text("Personalized habits based on your goals, current habits, and patterns.")
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.md)
    }

    // MARK: - Goals Section

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Based on Your Goals")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.xs) {
                    GoalTag(icon: "heart.fill", label: "Better Health", color: .hlHealth)
                    GoalTag(icon: "moon.fill", label: "Sleep Quality", color: .hlSleep)
                    GoalTag(icon: "brain.head.profile", label: "Focus", color: .hlMindfulness)
                }
            }
        }
    }

    // MARK: - Recommended Cards

    private var recommendedCards: some View {
        VStack(spacing: HLSpacing.sm) {
            ForEach(RecommendedHabitItem.samples) { item in
                RecommendedHabitDetailCard(
                    item: item,
                    isAdded: addedHabits.contains(item.id),
                    onAdd: {
                        withAnimation(HLAnimation.spring) {
                            _ = addedHabits.insert(item.id)
                            let habit = Habit(
                                name: item.name,
                                icon: item.icon,
                                colorHex: item.category.colorHex,
                                category: item.category
                            )
                            modelContext.insert(habit)
                            HLHaptics.success()
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Goal Tag

struct GoalTag: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: HLSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(label)
                .font(HLFont.caption(.medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, HLSpacing.sm)
        .padding(.vertical, HLSpacing.xs)
        .background(color.opacity(0.12))
        .cornerRadius(HLRadius.full)
    }
}

// MARK: - Recommended Habit Detail Card

struct RecommendedHabitDetailCard: View {
    let item: RecommendedHabitItem
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            // Header
            HStack {
                Image(systemName: item.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(item.category.color)
                    .frame(width: 44, height: 44)
                    .background(item.category.color.opacity(0.12))
                    .cornerRadius(HLRadius.md)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text(item.name)
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)

                    HStack(spacing: HLSpacing.xs) {
                        Text(item.category.rawValue)
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextSecondary)

                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(i < item.difficulty ? item.category.color : Color.hlDivider)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }

                Spacer()

                HStack(spacing: HLSpacing.xxxs) {
                    Image(systemName: HLIcon.sparkles)
                        .font(.system(size: 10))
                    Text("\(item.matchScore)% match")
                        .font(HLFont.caption(.semibold))
                }
                .foregroundColor(.hlGold)
            }

            // Why This Habit
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.hlWarning)
                    Text("Why this habit?")
                        .font(HLFont.caption(.semibold))
                        .foregroundColor(.hlTextSecondary)
                }

                Text(item.reason)
                    .font(HLFont.footnote())
                    .foregroundColor(.hlTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HLSpacing.sm)
            .background(Color.hlBackground)
            .cornerRadius(HLRadius.sm)

            // Add Button
            Button {
                onAdd()
            } label: {
                HStack {
                    Image(systemName: isAdded ? "checkmark" : "plus")
                    Text(isAdded ? "Added" : "Add to My Habits")
                }
                .font(HLFont.subheadline(.semibold))
                .foregroundColor(isAdded ? .white : .hlPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.xs)
                .background(isAdded ? Color.hlPrimary : Color.hlPrimaryLight)
                .cornerRadius(HLRadius.sm)
            }
            .disabled(isAdded)
        }
        .hlCard()
    }
}

// MARK: - Recommended Habit Item Model

struct RecommendedHabitItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let category: HabitCategory
    let difficulty: Int
    let reason: String
    let matchScore: Int

    static let samples: [RecommendedHabitItem] = [
        RecommendedHabitItem(
            name: "Morning Meditation",
            icon: "brain.head.profile",
            category: .mindfulness,
            difficulty: 1,
            reason: "You tend to complete habits better in the morning. A 10-minute meditation can improve focus throughout your day and complements your existing exercise routine.",
            matchScore: 95
        ),
        RecommendedHabitItem(
            name: "Drink 8 Glasses of Water",
            icon: "drop.fill",
            category: .health,
            difficulty: 1,
            reason: "Proper hydration boosts cognitive performance. Pairing this with your fitness habits will improve recovery and energy levels.",
            matchScore: 91
        ),
        RecommendedHabitItem(
            name: "Evening Journal",
            icon: "note.text",
            category: .mindfulness,
            difficulty: 1,
            reason: "Reflective journaling before bed can improve sleep quality. Given your sleep goals, this is a great fit for winding down.",
            matchScore: 87
        ),
        RecommendedHabitItem(
            name: "Stretch for 10 Minutes",
            icon: "figure.flexibility",
            category: .fitness,
            difficulty: 1,
            reason: "Active recovery pairs well with your exercise habit. Stretching reduces injury risk and improves flexibility over time.",
            matchScore: 83
        ),
        RecommendedHabitItem(
            name: "Read Before Bed",
            icon: "book.fill",
            category: .learning,
            difficulty: 1,
            reason: "Replacing screen time with reading can improve your sleep onset. Users with similar profiles report 20% better sleep quality.",
            matchScore: 79
        ),
    ]
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RecommendedHabitsView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
