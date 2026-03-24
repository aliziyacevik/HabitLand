import SwiftUI
import SwiftData

// MARK: - Habit Pack Detail View

struct HabitPackDetailView: View {
    @ScaledMetric(relativeTo: .title) private var headerIconSize: CGFloat = 40
    let pack: HabitTemplatePack
    @Environment(\.modelContext) private var modelContext
    @State private var addedTemplates: Set<String> = []

    private var allAdded: Bool {
        pack.templates.allSatisfy { addedTemplates.contains($0.id) }
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    packHeader
                    addAllButton
                    templatesList
                }
                .padding(.vertical, HLSpacing.sm)
            }
        }
        .navigationTitle(pack.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Pack Header

    private var packHeader: some View {
        VStack(spacing: HLSpacing.sm) {
            Image(systemName: pack.icon)
                .font(.system(size: min(headerIconSize, 48), weight: .semibold))
                .foregroundColor(pack.color)
                .frame(width: 80, height: 80)
                .background(pack.color.opacity(0.15))
                .cornerRadius(HLRadius.xl)

            Text(pack.name)
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text(pack.subtitle)
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HLSpacing.lg)

            Text("\(pack.templates.count) habits")
                .font(HLFont.caption(.medium))
                .foregroundColor(pack.color)
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xxs)
                .background(pack.color.opacity(0.12))
                .cornerRadius(HLRadius.full)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.md)
    }

    // MARK: - Add All Button

    private var addAllButton: some View {
        Button {
            addAllTemplates()
        } label: {
            HStack {
                Image(systemName: allAdded ? "checkmark" : "plus.rectangle.on.rectangle")
                Text(allAdded ? "All Added" : "Add Entire Pack")
            }
            .font(HLFont.headline())
            .foregroundColor(allAdded ? .white : pack.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.md)
            .background(allAdded ? pack.color : pack.color.opacity(0.12))
            .cornerRadius(HLRadius.lg)
        }
        .disabled(allAdded)
        .padding(.horizontal, HLSpacing.md)
    }

    // MARK: - Templates List

    private var templatesList: some View {
        VStack(spacing: HLSpacing.xs) {
            ForEach(pack.templates) { template in
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

    // MARK: - Actions

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

    private func addAllTemplates() {
        for (index, template) in pack.templates.enumerated() {
            guard !addedTemplates.contains(template.id) else { continue }
            let habit = template.toHabit(sortOrder: index)
            modelContext.insert(habit)
        }
        try? modelContext.save()
        AchievementManager.checkAll(context: modelContext)
        HLHaptics.success()
        withAnimation(HLAnimation.celebration) {
            for template in pack.templates {
                addedTemplates.insert(template.id)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitPackDetailView(pack: HabitTemplateLibrary.packs[0])
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
