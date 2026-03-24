import SwiftUI
import SwiftData

// MARK: - Recommended Habits View

struct RecommendedHabitsView: View {
    @ScaledMetric(relativeTo: .caption) private var smallIconSize: CGFloat = 11
    @ScaledMetric(relativeTo: .caption) private var chipIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .title3) private var headerIconSize: CGFloat = 22
    @ScaledMetric(relativeTo: .title) private var heroIconSize: CGFloat = 36
    @Environment(\.modelContext) private var modelContext
    @Query private var existingHabits: [Habit]
    @State private var addedTemplates: Set<String> = []

    private var recommendations: [HabitTemplate] {
        let existingNames = Set(existingHabits.map(\.name))
        // Filter out habits user already has, take top 8
        return HabitTemplateLibrary.all
            .filter { !existingNames.contains($0.name) }
            .prefix(8)
            .map { $0 }
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HLSpacing.lg) {
                    header
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
                .font(.system(size: min(heroIconSize, 40)))
                .foregroundColor(.hlGold)

            Text("Recommended for You")
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text("Habits that complement what you're already tracking.")
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.md)
    }

    // MARK: - Recommended Cards

    private var recommendedCards: some View {
        VStack(spacing: HLSpacing.sm) {
            ForEach(recommendations) { template in
                RecommendedTemplateCard(
                    template: template,
                    isAdded: addedTemplates.contains(template.id)
                ) {
                    addTemplate(template)
                }
            }
        }
    }

    private func addTemplate(_ template: HabitTemplate) {
        let habit = template.toHabit()
        modelContext.insert(habit)
        try? modelContext.save()
        AchievementManager.checkAll(context: modelContext)
        HLHaptics.success()
        withAnimation(HLAnimation.celebration) {
            addedTemplates.insert(template.id)
        }
    }
}

// MARK: - Recommended Template Card

struct RecommendedTemplateCard: View {
    @ScaledMetric(relativeTo: .caption) private var smallIconSize: CGFloat = 11
    @ScaledMetric(relativeTo: .caption) private var chipIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .title3) private var headerIconSize: CGFloat = 22
    let template: HabitTemplate
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Image(systemName: template.icon)
                    .font(.system(size: min(headerIconSize, 26), weight: .semibold))
                    .foregroundColor(template.color)
                    .frame(width: 44, height: 44)
                    .background(template.color.opacity(0.12))
                    .cornerRadius(HLRadius.md)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text(template.name)
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)

                    HStack(spacing: HLSpacing.xs) {
                        Text(template.category.rawValue)
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextSecondary)

                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(i < template.difficulty ? template.color : Color.hlDivider)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }

                Spacer()
            }

            // Description
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: min(smallIconSize, 15)))
                        .foregroundColor(.hlWarning)
                    Text("Why this habit?")
                        .font(HLFont.caption(.semibold))
                        .foregroundColor(.hlTextSecondary)
                }

                Text(template.description)
                    .font(HLFont.footnote())
                    .foregroundColor(.hlTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HLSpacing.sm)
            .background(Color.hlBackground)
            .cornerRadius(HLRadius.sm)

            // Goal info
            if template.goalCount > 1 {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: "target")
                        .font(.system(size: min(chipIconSize, 16)))
                        .foregroundColor(.hlTextTertiary)
                    Text("Goal: \(template.goalCount) \(template.unit) per day")
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)
                }
            }

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

// MARK: - Preview

#Preview {
    NavigationStack {
        RecommendedHabitsView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
