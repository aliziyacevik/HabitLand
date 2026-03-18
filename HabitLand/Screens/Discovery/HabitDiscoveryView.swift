import SwiftUI
import UIKit

// MARK: - Habit Discovery View

struct HabitDiscoveryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: HabitCategory?

    private var filteredPopularHabits: [DiscoverableHabit] {
        if searchText.isEmpty { return DiscoverableHabit.popular }
        return DiscoverableHabit.popular.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hlBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: HLSpacing.lg) {
                        forYouSection
                            .hlStaggeredAppear(index: 0)

                        categoriesSection
                            .hlStaggeredAppear(index: 1)

                        popularSection
                            .hlStaggeredAppear(index: 2)
                    }
                    .padding(.vertical, HLSpacing.sm)
                }
            }
            .navigationTitle("Discover")
            .searchable(text: $searchText, prompt: "Search habits...")
        }
    }

    // MARK: - For You Section

    private var forYouSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Image(systemName: HLIcon.sparkles)
                    .foregroundColor(.hlGold)
                Text("For You")
                    .font(HLFont.title3())
                    .foregroundColor(.hlTextPrimary)
            }
            .padding(.horizontal, HLSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.sm) {
                    ForEach(DiscoverableHabit.recommended) { habit in
                        NavigationLink {
                            RecommendedHabitsView()
                        } label: {
                            RecommendedHabitCard(habit: habit)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HLSpacing.md)
            }
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Categories")
                .font(HLFont.title3())
                .foregroundColor(.hlTextPrimary)
                .padding(.horizontal, HLSpacing.md)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: HLSpacing.sm),
                    GridItem(.flexible(), spacing: HLSpacing.sm),
                ],
                spacing: HLSpacing.sm
            ) {
                ForEach(HabitCategory.allCases, id: \.self) { category in
                    NavigationLink {
                        HabitCategoriesView(category: category)
                    } label: {
                        CategoryGridItem(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HLSpacing.md)
        }
    }

    // MARK: - Popular Section

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Popular Habits")
                .font(HLFont.title3())
                .foregroundColor(.hlTextPrimary)
                .padding(.horizontal, HLSpacing.md)

            VStack(spacing: HLSpacing.xs) {
                ForEach(filteredPopularHabits) { habit in
                    PopularHabitRow(habit: habit)
                        .padding(.horizontal, HLSpacing.md)
                }
            }
        }
    }
}

// MARK: - Recommended Habit Card

struct RecommendedHabitCard: View {
    let habit: DiscoverableHabit

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Image(systemName: habit.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(habit.category.color)
                Spacer()
                Image(systemName: HLIcon.sparkles)
                    .font(.system(size: 12))
                    .foregroundColor(.hlGold)
            }

            Text(habit.name)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            Text(habit.reason)
                .font(HLFont.caption())
                .foregroundColor(.hlTextSecondary)
                .lineLimit(2)

            Spacer()

            Text("Add to My Habits")
                .font(HLFont.caption(.semibold))
                .foregroundColor(.hlPrimary)
        }
        .frame(width: 160, height: 160)
        .hlCard()
        .hlInnerHighlight()
    }
}

// MARK: - Category Grid Item

struct CategoryGridItem: View {
    let category: HabitCategory

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: category.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(category.color)
                .frame(width: 40, height: 40)
                .background(category.color.opacity(0.12))
                .cornerRadius(HLRadius.sm)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(category.rawValue)
                    .font(HLFont.subheadline(.medium))
                    .foregroundColor(.hlTextPrimary)
                Text("\(category.habitCount) habits")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            Spacer()
        }
        .hlCard()
    }
}

// MARK: - Popular Habit Row

struct PopularHabitRow: View {
    let habit: DiscoverableHabit
    @Environment(\.modelContext) private var modelContext
    @State private var isAdded = false

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: habit.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(habit.category.color)
                .frame(width: 40, height: 40)
                .background(habit.category.color.opacity(0.12))
                .cornerRadius(HLRadius.sm)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(habit.name)
                    .font(HLFont.body(.medium))
                    .foregroundColor(.hlTextPrimary)

                HStack(spacing: HLSpacing.xs) {
                    Text(habit.category.rawValue)
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextSecondary)

                    Text("--")
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)

                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(i < habit.difficulty ? habit.category.color : Color.hlDivider)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }

            Spacer()

            Button {
                let newHabit = Habit(
                    name: habit.name,
                    icon: habit.icon,
                    colorHex: habit.category.colorHex,
                    category: habit.category
                )
                modelContext.insert(newHabit)
                AchievementManager.checkAll(context: modelContext)
                HLHaptics.completionSuccess()
                withAnimation(HLAnimation.celebration) { isAdded = true }
            } label: {
                Image(systemName: isAdded ? "checkmark" : "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isAdded ? .white : .hlPrimary)
                    .frame(width: 32, height: 32)
                    .background(isAdded ? Color.hlPrimary : Color.hlPrimaryLight)
                    .cornerRadius(HLRadius.full)
            }
            .disabled(isAdded)
            .accessibilityLabel(isAdded ? "\(habit.name) added" : "Add \(habit.name)")
        }
        .hlCard()
    }
}

// MARK: - Discoverable Habit Model

struct DiscoverableHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let category: HabitCategory
    let difficulty: Int // 1-3
    let reason: String

    static let recommended: [DiscoverableHabit] = [
        DiscoverableHabit(name: "Morning Meditation", icon: "brain.head.profile", category: .mindfulness, difficulty: 1, reason: "Based on your sleep patterns, morning mindfulness could improve your day."),
        DiscoverableHabit(name: "Drink 8 Glasses of Water", icon: "drop.fill", category: .health, difficulty: 1, reason: "Hydration pairs well with your existing exercise habits."),
        DiscoverableHabit(name: "Evening Journal", icon: "note.text", category: .mindfulness, difficulty: 1, reason: "Reflective writing can boost your mindfulness practice."),
    ]

    static let popular: [DiscoverableHabit] = [
        DiscoverableHabit(name: "Walk 10k Steps", icon: "figure.walk", category: .fitness, difficulty: 2, reason: ""),
        DiscoverableHabit(name: "Read 30 Minutes", icon: "book.fill", category: .learning, difficulty: 1, reason: ""),
        DiscoverableHabit(name: "No Sugar", icon: "leaf.fill", category: .nutrition, difficulty: 3, reason: ""),
        DiscoverableHabit(name: "Cold Shower", icon: "snowflake", category: .health, difficulty: 3, reason: ""),
        DiscoverableHabit(name: "Practice Gratitude", icon: "heart.fill", category: .mindfulness, difficulty: 1, reason: ""),
        DiscoverableHabit(name: "Stretch for 10 min", icon: "figure.flexibility", category: .fitness, difficulty: 1, reason: ""),
    ]
}

// MARK: - Category Habit Count Extension

extension HabitCategory {
    var habitCount: Int {
        switch self {
        case .health: return 12
        case .fitness: return 15
        case .mindfulness: return 10
        case .productivity: return 14
        case .sleep: return 8
        case .social: return 6
        case .learning: return 11
        case .nutrition: return 9
        }
    }
}

// MARK: - Preview

#Preview {
    HabitDiscoveryView()
}
