import SwiftUI

struct HabitPreferenceView: View {
    @State private var selectedCategories: Set<HabitCategory> = []
    var onContinue: (Set<HabitCategory>) -> Void = { _ in }

    private let columns = [
        GridItem(.flexible(), spacing: HLSpacing.sm),
        GridItem(.flexible(), spacing: HLSpacing.sm),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    // Header
                    VStack(spacing: HLSpacing.xs) {
                        Text("What Matters to You?")
                            .font(HLFont.largeTitle())
                            .foregroundColor(.hlTextPrimary)

                        Text("Choose at least 3 categories to get started.")
                            .font(HLFont.body())
                            .foregroundColor(.hlTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, HLSpacing.xxl)

                    // Category Grid
                    LazyVGrid(columns: columns, spacing: HLSpacing.sm) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            CategoryCard(
                                category: category,
                                isSelected: selectedCategories.contains(category)
                            ) {
                                withAnimation(HLAnimation.spring) {
                                    if selectedCategories.contains(category) {
                                        selectedCategories.remove(category)
                                    } else {
                                        selectedCategories.insert(category)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, HLSpacing.lg)
                .padding(.bottom, HLSpacing.xl)
            }

            // Selection count + Continue
            VStack(spacing: HLSpacing.sm) {
                if !selectedCategories.isEmpty {
                    Text("\(selectedCategories.count) selected")
                        .font(HLFont.footnote(.medium))
                        .foregroundColor(.hlTextSecondary)
                }

                HLButton(
                    "Continue",
                    style: .primary,
                    size: .lg,
                    isFullWidth: true,
                    isDisabled: selectedCategories.count < 3
                ) {
                    onContinue(selectedCategories)
                }
            }
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    @ScaledMetric(relativeTo: .title3) private var categoryIconSize: CGFloat = 24
    let category: HabitCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: HLSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: category.icon)
                        .font(.system(size: min(categoryIconSize, 28), weight: .semibold))
                        .foregroundColor(category.color)
                }

                Text(category.rawValue)
                    .font(HLFont.callout(.semibold))
                    .foregroundColor(.hlTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.lg)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .strokeBorder(
                        isSelected ? Color.hlPrimary : Color.hlCardBorder,
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            .hlShadow(isSelected ? HLShadow.md : HLShadow.sm)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HabitPreferenceView()
}
