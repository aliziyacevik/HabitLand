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
            Spacer()

            VStack(spacing: HLSpacing.xl) {
                // Header
                ZStack {
                    Circle()
                        .fill(themeManager.accentTheme.primary.opacity(0.12))
                        .frame(width: min(themeCircleSize, 110), height: min(themeCircleSize, 110))

                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: min(themeIconSize, 50), weight: .medium))
                        .foregroundStyle(themeManager.accentTheme.primary)
                }
                .animation(HLAnimation.standard, value: themeManager.accentTheme)

                VStack(spacing: HLSpacing.xs) {
                    Text("Pick a Color")
                        .font(HLFont.largeTitle())
                        .foregroundColor(.hlTextPrimary)

                    Text("You can always change this in Settings.")
                        .font(HLFont.body())
                        .foregroundColor(.hlTextSecondary)
                }

                // Color palette — 2 rows grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: AccentTheme.allCases.count / 2), spacing: HLSpacing.md) {
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
                .padding(.horizontal, HLSpacing.lg)
            }

            Spacer()

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
