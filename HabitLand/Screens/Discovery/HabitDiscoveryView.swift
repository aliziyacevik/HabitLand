import SwiftUI
import SwiftData

// MARK: - Habit Discovery View

struct HabitDiscoveryView: View {
    @ScaledMetric(relativeTo: .caption) private var tinyIconSize: CGFloat = 10
    @ScaledMetric(relativeTo: .caption) private var smallIconSize: CGFloat = 11
    @ScaledMetric(relativeTo: .caption) private var chipIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var categoryBadgeSize: CGFloat = 14
    @ScaledMetric(relativeTo: .body) private var cardIconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var templateIconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .title3) private var headerIconSize: CGFloat = 22
    @ScaledMetric(relativeTo: .title) private var heroIconSize: CGFloat = 36
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var addedTemplates: Set<String> = []

    private var searchResults: [HabitTemplate] {
        HabitTemplateLibrary.search(searchText)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hlBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: HLSpacing.lg) {
                        if searchText.isEmpty {
                            packsSection
                                .hlStaggeredAppear(index: 0)

                            categoriesSection
                                .hlStaggeredAppear(index: 1)

                            popularSection
                                .hlStaggeredAppear(index: 2)
                        } else {
                            searchResultsSection
                        }
                    }
                    .padding(.vertical, HLSpacing.sm)
                }
            }
            .navigationTitle("Discover")
            .searchable(text: $searchText, prompt: "Search habits...")
        }
    }

    // MARK: - Packs Section

    private var packsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Image(systemName: "rectangle.stack.fill")
                    .foregroundColor(.hlGold)
                Text("Habit Packs")
                    .font(HLFont.title3())
                    .foregroundColor(.hlTextPrimary)
            }
            .padding(.horizontal, HLSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.sm) {
                    ForEach(HabitTemplateLibrary.packs) { pack in
                        NavigationLink {
                            HabitPackDetailView(pack: pack)
                        } label: {
                            PackCard(pack: pack)
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
                ForEach(HabitTemplateLibrary.popular) { template in
                    TemplateRow(
                        template: template,
                        isAdded: addedTemplates.contains(template.id)
                    ) {
                        addTemplate(template)
                    }
                    .padding(.horizontal, HLSpacing.md)
                }
            }
        }
    }

    // MARK: - Search Results

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("\(searchResults.count) results")
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .padding(.horizontal, HLSpacing.md)

            VStack(spacing: HLSpacing.xs) {
                ForEach(searchResults) { template in
                    TemplateRow(
                        template: template,
                        isAdded: addedTemplates.contains(template.id)
                    ) {
                        addTemplate(template)
                    }
                    .padding(.horizontal, HLSpacing.md)
                }
            }

            if searchResults.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No habits found",
                    subtitle: "Try a different search term or browse categories."
                )
                .padding(.top, HLSpacing.xxl)
            }
        }
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
}

// MARK: - Pack Card

struct PackCard: View {
    @ScaledMetric(relativeTo: .caption) private var tinyIconSize: CGFloat = 10
    @ScaledMetric(relativeTo: .body) private var templateIconSize: CGFloat = 20
    let pack: HabitTemplatePack

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Image(systemName: pack.icon)
                    .font(.system(size: min(templateIconSize, 24), weight: .semibold))
                    .foregroundColor(pack.color)
                Spacer()
                Text("\(pack.templates.count) habits")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextTertiary)
            }

            Text(pack.name)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            Text(pack.subtitle)
                .font(HLFont.caption())
                .foregroundColor(.hlTextSecondary)
                .lineLimit(2)

            Spacer()

            // Template icons preview
            HStack(spacing: -4) {
                ForEach(pack.templates.prefix(4)) { template in
                    Image(systemName: template.icon)
                        .font(.system(size: min(tinyIconSize, 14), weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(template.color)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.hlSurface, lineWidth: 2))
                }
                if pack.templates.count > 4 {
                    Text("+\(pack.templates.count - 4)")
                        .font(HLFont.caption2(.semibold))
                        .foregroundColor(.hlTextTertiary)
                        .frame(width: 24, height: 24)
                        .background(Color.hlBackground)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.hlSurface, lineWidth: 2))
                }
            }
        }
        .frame(width: 180, height: 180)
        .hlCard()
        .hlInnerHighlight()
    }
}

// MARK: - Template Row (shared component)

struct TemplateRow: View {
    @ScaledMetric(relativeTo: .footnote) private var categoryBadgeSize: CGFloat = 14
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
                    Text(template.category.rawValue)
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextSecondary)

                    Text("--")
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)

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

            Button {
                onAdd()
            } label: {
                Image(systemName: isAdded ? "checkmark" : "plus")
                    .font(.system(size: min(categoryBadgeSize, 18), weight: .bold))
                    .foregroundColor(isAdded ? .white : .hlPrimary)
                    .frame(width: 32, height: 32)
                    .background(isAdded ? Color.hlPrimary : Color.hlPrimaryLight)
                    .cornerRadius(HLRadius.full)
            }
            .disabled(isAdded)
            .accessibilityLabel(isAdded ? "\(template.name) added" : "Add \(template.name)")
        }
        .hlCard()
    }
}

// MARK: - Category Grid Item

struct CategoryGridItem: View {
    @ScaledMetric(relativeTo: .footnote) private var categoryBadgeSize: CGFloat = 14
    @ScaledMetric(relativeTo: .body) private var templateIconSize: CGFloat = 20
    let category: HabitCategory

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: category.icon)
                .font(.system(size: min(templateIconSize, 24), weight: .semibold))
                .foregroundColor(category.color)
                .frame(width: 40, height: 40)
                .background(category.color.opacity(0.12))
                .cornerRadius(HLRadius.sm)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(category.rawValue)
                    .font(HLFont.subheadline(.medium))
                    .foregroundColor(.hlTextPrimary)
                Text("\(HabitTemplateLibrary.templates(for: category).count) habits")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            Spacer()
        }
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    HabitDiscoveryView()
        .modelContainer(for: Habit.self, inMemory: true)
}
