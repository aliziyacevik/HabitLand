import SwiftUI
import SwiftData

struct StarterHabitsView: View {
    @ScaledMetric(relativeTo: .footnote) private var chipIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .title3) private var statIconSize: CGFloat = 24
    @Environment(\.modelContext) private var modelContext
    var onComplete: (Int) -> Void = { _ in }

    @State private var selectedTemplates: Set<String> = []
    @State private var showXPPreview = false

    private let templates = HabitTemplateLibrary.starterPicks

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: HLSpacing.xs) {
                Text("Want a few more?")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlTextPrimary)

                Text("Pick some extra habits to build your routine.")
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
                    ForEach(templates) { template in
                        starterHabitCard(template)
                    }
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.bottom, HLSpacing.xxxl)
            }

            // Bottom bar
            VStack(spacing: HLSpacing.sm) {
                // XP preview
                if !selectedTemplates.isEmpty {
                    HStack(spacing: HLSpacing.xs) {
                        Image(systemName: "sparkles")
                            .font(.system(size: min(chipIconSize, 18), weight: .semibold))
                            .foregroundStyle(Color.hlGold)
                        Text("You'll earn \(selectedTemplates.count * 10) XP for getting started!")
                            .font(HLFont.caption(.semibold))
                            .foregroundStyle(Color.hlGold)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                HLButton(
                    selectedTemplates.isEmpty ? "I'm Good for Now" : "Add \(selectedTemplates.count) Habits",
                    icon: selectedTemplates.isEmpty ? "arrow.right" : "plus",
                    style: selectedTemplates.isEmpty ? .secondary : .primary,
                    size: .lg,
                    isFullWidth: true
                ) {
                    let count = createSelectedHabits()
                    onComplete(count)
                }

                if !selectedTemplates.isEmpty {
                    Text("Free users can track up to 5 habits")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
            .background(Color.hlBackground)
            .animation(HLAnimation.standard, value: selectedTemplates.count)
        }
        .background(Color.hlBackground.ignoresSafeArea())
    }

    private func starterHabitCard(_ template: HabitTemplate) -> some View {
        let isSelected = selectedTemplates.contains(template.id)
        let atLimit = selectedTemplates.count >= 5 && !isSelected && !ProManager.shared.isPro

        return Button {
            if isSelected {
                selectedTemplates.remove(template.id)
            } else if !atLimit {
                selectedTemplates.insert(template.id)
            } else {
                HLHaptics.warning()
            }
            HLHaptics.selection()
        } label: {
            VStack(spacing: HLSpacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .fill(template.color.opacity(isSelected ? 0.2 : 0.08))
                        .frame(height: 56)

                    Image(systemName: template.icon)
                        .font(.system(size: min(statIconSize, 28)))
                        .foregroundStyle(template.color)
                }

                Text(template.name)
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextPrimary)
                    .lineLimit(1)
            }
            .padding(HLSpacing.sm)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .stroke(isSelected ? template.color : Color.hlCardBorder, lineWidth: isSelected ? 2 : 1)
            )
            .opacity(atLimit ? 0.5 : 1)
        }
        .animation(HLAnimation.microSpring, value: isSelected)
    }

    @discardableResult
    private func createSelectedHabits() -> Int {
        let selected = templates.filter { selectedTemplates.contains($0.id) }
        for (index, template) in selected.enumerated() {
            let habit = template.toHabit(sortOrder: index)
            modelContext.insert(habit)
        }
        try? modelContext.save()
        return selected.count
    }
}

#Preview {
    StarterHabitsView()
        .modelContainer(for: Habit.self, inMemory: true)
}
