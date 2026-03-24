import SwiftUI
import SwiftData

// MARK: - Habit Categories View

struct HabitCategoriesView: View {
    @ScaledMetric(relativeTo: .title) private var heroIconSize: CGFloat = 36
    let category: HabitCategory
    @Environment(\.modelContext) private var modelContext
    @State private var addedTemplates: Set<String> = []

    private var templates: [HabitTemplate] {
        HabitTemplateLibrary.templates(for: category)
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    categoryHeader

                    VStack(spacing: HLSpacing.xs) {
                        ForEach(templates) { template in
                            CategoryTemplateRow(
                                template: template,
                                isAdded: addedTemplates.contains(template.id)
                            ) {
                                addTemplate(template)
                            }
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
                .font(.system(size: min(heroIconSize, 40), weight: .semibold))
                .foregroundColor(category.color)
                .frame(width: 72, height: 72)
                .background(category.color.opacity(0.15))
                .cornerRadius(HLRadius.xl)

            Text(category.rawValue)
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text("\(templates.count) habits available")
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.md)
    }

    private func addTemplate(_ template: HabitTemplate) {
        let habit = template.toHabit()
        modelContext.insert(habit)
        try? modelContext.save()
        AchievementManager.checkAll(context: modelContext)
        HLHaptics.completionSuccess()
        withAnimation(HLAnimation.celebration) {
            addedTemplates.insert(template.id)
        }
    }
}

// MARK: - Category Template Row

struct CategoryTemplateRow: View {
    @ScaledMetric(relativeTo: .footnote) private var chipIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .body) private var cardIconSize: CGFloat = 18
    let template: HabitTemplate
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: template.icon)
                .font(.system(size: min(cardIconSize, 22), weight: .semibold))
                .foregroundColor(template.color)
                .frame(width: 40, height: 40)
                .background(template.color.opacity(0.12))
                .cornerRadius(HLRadius.sm)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(template.name)
                    .font(HLFont.body(.medium))
                    .foregroundColor(.hlTextPrimary)

                HStack(spacing: HLSpacing.xs) {
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(i < template.difficulty ? template.color : Color.hlDivider)
                                .frame(width: 16, height: 4)
                        }
                    }

                    Text(template.difficultyLabel)
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }

                Text(template.description)
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Button {
                onAdd()
            } label: {
                Image(systemName: isAdded ? "checkmark" : "plus")
                    .font(.system(size: min(chipIconSize, 18), weight: .bold))
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

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitCategoriesView(category: .fitness)
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
