import SwiftUI

struct ThemeOnboardingView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @ScaledMetric(relativeTo: .title) private var themeCircleSize: CGFloat = 96
    @ScaledMetric(relativeTo: .body) private var smallThemeIconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var previewIconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .title) private var themeIconSize: CGFloat = 44
    var onContinue: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: HLSpacing.xxxl) {
                    // Header
                    VStack(spacing: HLSpacing.xs) {
                        ZStack {
                            Circle()
                                .fill(themeManager.accentTheme.primary.opacity(0.12))
                                .frame(width: min(themeCircleSize, 110), height: min(themeCircleSize, 110))

                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: min(themeIconSize, 50), weight: .medium))
                                .foregroundStyle(themeManager.accentTheme.primary)
                        }
                        .animation(HLAnimation.standard, value: themeManager.accentTheme)
                        .padding(.bottom, HLSpacing.sm)

                        Text("Choose Your Theme")
                            .font(HLFont.largeTitle())
                            .foregroundColor(.hlTextPrimary)

                        Text("Make HabitLand yours.")
                            .font(HLFont.body())
                            .foregroundColor(.hlTextSecondary)
                    }
                    .padding(.top, HLSpacing.xxl)

                    // Appearance Mode
                    VStack(alignment: .leading, spacing: HLSpacing.sm) {
                        Text("Appearance")
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlTextPrimary)
                            .padding(.horizontal, HLSpacing.xs)

                        HStack(spacing: HLSpacing.sm) {
                            ForEach(AppearanceMode.allCases) { mode in
                                Button {
                                    withAnimation(HLAnimation.quick) {
                                        themeManager.appearanceMode = mode
                                    }
                                    HLHaptics.selection()
                                } label: {
                                    VStack(spacing: HLSpacing.xs) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: HLRadius.md)
                                                .fill(modeBackground(mode))
                                                .frame(height: 56)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: HLRadius.md)
                                                        .stroke(
                                                            themeManager.appearanceMode == mode
                                                                ? themeManager.accentTheme.primary
                                                                : Color.hlDivider,
                                                            lineWidth: themeManager.appearanceMode == mode ? 2.5 : 1
                                                        )
                                                )

                                            Image(systemName: mode.icon)
                                                .font(.system(size: min(previewIconSize, 24)))
                                                .foregroundStyle(modeForeground(mode))
                                        }

                                        Text(mode.title)
                                            .font(HLFont.caption(.medium))
                                            .foregroundStyle(
                                                themeManager.appearanceMode == mode
                                                    ? themeManager.accentTheme.primary
                                                    : Color.hlTextSecondary
                                            )
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(HLSpacing.md)
                    .background(Color.hlSurface)
                    .cornerRadius(HLRadius.xl)
                    .hlShadow(HLShadow.sm)

                    // Accent Color
                    VStack(alignment: .leading, spacing: HLSpacing.sm) {
                        Text("Accent Color")
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlTextPrimary)
                            .padding(.horizontal, HLSpacing.xs)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: HLSpacing.md) {
                            ForEach(AccentTheme.allCases) { theme in
                                Button {
                                    withAnimation(HLAnimation.quick) {
                                        themeManager.accentTheme = theme
                                    }
                                    HLHaptics.selection()
                                } label: {
                                    VStack(spacing: HLSpacing.xs) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [theme.primary, theme.primaryDark],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 48, height: 48)

                                            Image(systemName: theme.icon)
                                                .font(.system(size: min(smallThemeIconSize, 22), weight: .semibold))
                                                .foregroundStyle(.white)
                                        }
                                        .overlay {
                                            if themeManager.accentTheme == theme {
                                                Circle()
                                                    .stroke(theme.primary, lineWidth: 3)
                                                    .frame(width: 58, height: 58)
                                            }
                                        }

                                        Text(theme.rawValue)
                                            .font(HLFont.caption(.medium))
                                            .foregroundStyle(
                                                themeManager.accentTheme == theme
                                                    ? theme.primary
                                                    : Color.hlTextSecondary
                                            )
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(HLSpacing.md)
                    .background(Color.hlSurface)
                    .cornerRadius(HLRadius.xl)
                    .hlShadow(HLShadow.sm)
                }
                .padding(.horizontal, HLSpacing.lg)
                .padding(.bottom, HLSpacing.xl)
            }

            // Continue button
            HLButton(
                "Continue",
                icon: "arrow.right",
                style: .primary,
                size: .lg,
                isFullWidth: true
            ) {
                themeManager.save()
                onContinue()
            }
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
    }

    private func modeBackground(_ mode: AppearanceMode) -> Color {
        switch mode {
        case .light: return Color(red: 0.97, green: 0.97, blue: 0.98)
        case .dark: return Color(red: 0.11, green: 0.11, blue: 0.13)
        case .system: return Color.hlSurface
        }
    }

    private func modeForeground(_ mode: AppearanceMode) -> Color {
        switch mode {
        case .light: return Color(red: 0.10, green: 0.10, blue: 0.12)
        case .dark: return .white
        case .system: return Color.hlTextPrimary
        }
    }
}

#Preview {
    ThemeOnboardingView()
}
