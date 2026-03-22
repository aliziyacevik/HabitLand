import SwiftUI

// MARK: - Template Browser View

struct TemplateBrowserView: View {
    let onSelect: (HabitTemplate) -> Void
    var onPackSelect: (([HabitTemplate]) -> Void)?

    @State private var searchText = ""
    @State private var selectedCategory: HabitCategory?
    @State private var expandedPack: String?
    @State private var addedPack: String?

    private var filteredTemplates: [HabitTemplate] {
        var results: [HabitTemplate]
        if let category = selectedCategory {
            results = HabitTemplateLibrary.templates(for: category)
        } else {
            results = HabitTemplateLibrary.all
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(q) ||
                $0.description.lowercased().contains(q) ||
                $0.tags.contains { $0.contains(q) }
            }
        }
        return results
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Category filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HLSpacing.xs) {
                        categoryChip(nil, label: "All")
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            categoryChip(category, label: category.rawValue)
                        }
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.vertical, HLSpacing.sm)
                }

                // Template list
                ScrollView {
                    LazyVStack(spacing: HLSpacing.xs) {
                        // Packs section (only when showing all and no search)
                        if selectedCategory == nil && searchText.isEmpty {
                            packsRow
                                .padding(.bottom, HLSpacing.sm)
                        }

                        ForEach(filteredTemplates) { template in
                            Button {
                                HLHaptics.selection()
                                onSelect(template)
                            } label: {
                                templateCard(template)
                            }
                            .buttonStyle(.plain)
                        }

                        if filteredTemplates.isEmpty {
                            EmptyStateView(
                                icon: "magnifyingglass",
                                title: "No templates found",
                                subtitle: "Try a different search or category."
                            )
                            .padding(.top, HLSpacing.xl)
                        }
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.bottom, HLSpacing.xxl)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search templates...")
    }

    // MARK: - Category Chip

    private func categoryChip(_ category: HabitCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(HLAnimation.microSpring) {
                selectedCategory = category
            }
            HLHaptics.selection()
        } label: {
            HStack(spacing: HLSpacing.xxs) {
                if let category {
                    Image(systemName: category.icon)
                        .font(.system(size: 12))
                }
                Text(label)
                    .font(HLFont.caption(.medium))
            }
            .foregroundColor(isSelected ? .white : .hlTextSecondary)
            .padding(.horizontal, HLSpacing.sm)
            .padding(.vertical, HLSpacing.xs)
            .background(isSelected ? Color.hlPrimary : Color.hlSurface)
            .cornerRadius(HLRadius.full)
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.full)
                    .stroke(isSelected ? Color.clear : Color.hlCardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Packs Row

    private var packsRow: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Quick Start Packs")
                .font(HLFont.subheadline(.semibold))
                .foregroundColor(.hlTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.xs) {
                    ForEach(HabitTemplateLibrary.packs) { pack in
                        Button {
                            withAnimation(HLAnimation.standard) {
                                expandedPack = expandedPack == pack.id ? nil : pack.id
                            }
                            HLHaptics.selection()
                        } label: {
                            miniPackCard(pack)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Expanded pack preview
            if let packID = expandedPack,
               let pack = HabitTemplateLibrary.packs.first(where: { $0.id == packID }) {
                VStack(spacing: HLSpacing.sm) {
                    // Pack header
                    HStack {
                        Image(systemName: pack.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(pack.color)
                        Text(pack.name)
                            .font(HLFont.callout(.semibold))
                            .foregroundStyle(Color.hlTextPrimary)
                        Spacer()
                        Text("\(pack.templates.count) habits")
                            .font(HLFont.caption())
                            .foregroundStyle(Color.hlTextTertiary)
                    }

                    // Habit list preview
                    ForEach(pack.templates) { template in
                        HStack(spacing: HLSpacing.sm) {
                            Image(systemName: template.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(template.color)
                                .frame(width: 32, height: 32)
                                .background(template.color.opacity(0.12))
                                .cornerRadius(HLRadius.sm)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(template.name)
                                    .font(HLFont.callout(.medium))
                                    .foregroundStyle(Color.hlTextPrimary)
                                if template.goalCount > 1 {
                                    Text("\(template.goalCount) \(template.unit)")
                                        .font(HLFont.caption2())
                                        .foregroundStyle(Color.hlTextTertiary)
                                }
                            }
                            Spacer()
                        }
                    }

                    // Use This Pack button
                    if addedPack == pack.id {
                        HStack(spacing: HLSpacing.xxs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.hlPrimary)
                            Text("Pack Added!")
                                .font(HLFont.callout(.semibold))
                                .foregroundStyle(Color.hlPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HLSpacing.sm)
                    } else {
                        Button {
                            if let onPackSelect {
                                onPackSelect(pack.templates)
                            }
                            withAnimation(HLAnimation.celebration) {
                                addedPack = pack.id
                            }
                            HLHaptics.success()
                        } label: {
                            Text("Use This Pack")
                                .font(HLFont.callout(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, HLSpacing.sm)
                                .background(pack.color)
                                .cornerRadius(HLRadius.md)
                        }
                    }
                }
                .padding(HLSpacing.md)
                .background(Color.hlSurface)
                .cornerRadius(HLRadius.lg)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.lg)
                        .stroke(pack.color.opacity(0.3), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func miniPackCard(_ pack: HabitTemplatePack) -> some View {
        let isExpanded = expandedPack == pack.id
        let isAdded = addedPack == pack.id

        return VStack(alignment: .leading, spacing: HLSpacing.xxs) {
            HStack {
                Image(systemName: isAdded ? "checkmark.circle.fill" : pack.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isAdded ? .hlPrimary : pack.color)
                Spacer()
            }

            Text(pack.name)
                .font(HLFont.caption(.semibold))
                .foregroundColor(isAdded ? .hlTextTertiary : .hlTextPrimary)
                .lineLimit(1)

            Text(isAdded ? "Added!" : "\(pack.templates.count) habits")
                .font(HLFont.caption2())
                .foregroundColor(isAdded ? .hlPrimary : .hlTextTertiary)
        }
        .frame(width: 100)
        .padding(HLSpacing.sm)
        .background(isExpanded ? pack.color.opacity(0.08) : isAdded ? Color.hlPrimary.opacity(0.06) : Color.hlSurface)
        .cornerRadius(HLRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .stroke(isExpanded ? pack.color : isAdded ? Color.hlPrimary : Color.hlCardBorder, lineWidth: isExpanded ? 2 : 1)
        )
    }

    // MARK: - Template Card

    private func templateCard(_ template: HabitTemplate) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: template.icon)
                .font(.system(size: 18, weight: .semibold))
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

                    if template.goalCount > 1 {
                        Text("\(template.goalCount) \(template.unit)")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextTertiary)
                    }

                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(i < template.difficulty ? template.color : Color.hlDivider)
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.hlTextTertiary)
        }
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TemplateBrowserView { _ in }
    }
}
