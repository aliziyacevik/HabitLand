import SwiftUI
import SwiftData

struct AppearanceSettingsView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @Query private var profiles: [UserProfile]
    private var userLevel: Int { profiles.first?.level ?? 1 }

    var body: some View {
        List {
            appearanceModeSection
            accentColorSection
            previewSection
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if themeManager.hasUnsavedChanges {
                    Button {
                        themeManager.save()
                        HLHaptics.success()
                    } label: {
                        Text("Save")
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlPrimary)
                    }
                }
            }
        }
        .onDisappear {
            if themeManager.hasUnsavedChanges {
                themeManager.revert()
            }
        }
    }

    // MARK: - Appearance Mode

    private var appearanceModeSection: some View {
        Section {
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
                                    .fill(modePreviewBackground(mode))
                                    .frame(height: 64)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: HLRadius.md)
                                            .stroke(
                                                themeManager.appearanceMode == mode
                                                    ? Color.hlPrimary
                                                    : Color.hlDivider,
                                                lineWidth: themeManager.appearanceMode == mode ? 2.5 : 1
                                            )
                                    )

                                Image(systemName: mode.icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(modePreviewForeground(mode))
                            }

                            Text(mode.title)
                                .font(HLFont.caption(.medium))
                                .foregroundStyle(
                                    themeManager.appearanceMode == mode
                                        ? Color.hlPrimary
                                        : Color.hlTextSecondary
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, HLSpacing.xxs)
        } header: {
            Text("Appearance")
        }
    }

    private func modePreviewBackground(_ mode: AppearanceMode) -> Color {
        switch mode {
        case .light: return Color(red: 0.97, green: 0.97, blue: 0.98)
        case .dark: return Color(red: 0.11, green: 0.11, blue: 0.13)
        case .system: return Color.hlSurface
        }
    }

    private func modePreviewForeground(_ mode: AppearanceMode) -> Color {
        switch mode {
        case .light: return Color(red: 0.10, green: 0.10, blue: 0.12)
        case .dark: return .white
        case .system: return Color.hlTextPrimary
        }
    }

    // MARK: - Accent Color

    private var accentColorSection: some View {
        Section {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: HLSpacing.sm) {
                ForEach(AccentTheme.allCases) { theme in
                    let locked = !theme.isUnlocked(at: userLevel)
                    Button {
                        guard !locked else {
                            HLHaptics.warning()
                            return
                        }
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
                                    .opacity(locked ? 0.4 : 1.0)

                                if locked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                } else {
                                    Image(systemName: theme.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .overlay {
                                if themeManager.accentTheme == theme {
                                    Circle()
                                        .stroke(theme.primary, lineWidth: 3)
                                        .frame(width: 58, height: 58)
                                }
                            }

                            Text(locked ? "Lv.\(theme.requiredLevel)" : theme.rawValue)
                                .font(HLFont.caption(.medium))
                                .foregroundStyle(
                                    locked ? Color.hlTextTertiary :
                                    themeManager.accentTheme == theme
                                        ? theme.primary
                                        : Color.hlTextSecondary
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, HLSpacing.xs)
        } header: {
            Text("Accent Color")
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        Section {
            VStack(spacing: HLSpacing.sm) {
                // Mock habit card
                HStack(spacing: HLSpacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: HLRadius.sm)
                            .fill(themeManager.accentTheme.primary.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: "figure.run")
                            .font(.system(size: 20))
                            .foregroundStyle(themeManager.accentTheme.primary)
                    }

                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text("Morning Run")
                            .font(HLFont.callout(.medium))
                            .foregroundStyle(Color.hlTextPrimary)
                        Text("Fitness")
                            .font(HLFont.caption())
                            .foregroundStyle(Color.hlTextTertiary)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(themeManager.accentTheme.primary)
                }
                .padding(HLSpacing.sm)
                .background(Color.hlSurface)
                .cornerRadius(HLRadius.lg)

                // Mock progress bar
                HStack {
                    Text("3 of 5 completed")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary)
                    Spacer()
                    Text("60%")
                        .font(HLFont.caption(.bold))
                        .foregroundStyle(themeManager.accentTheme.primary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: HLRadius.full)
                            .fill(Color.hlDivider)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: HLRadius.full)
                            .fill(themeManager.accentTheme.primary)
                            .frame(width: geo.size.width * 0.6, height: 6)
                    }
                }
                .frame(height: 6)

                // Mock button
                Text("Complete Habit")
                    .font(HLFont.subheadline(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.xs)
                    .background(
                        LinearGradient(
                            colors: [themeManager.accentTheme.primary, themeManager.accentTheme.primaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(HLRadius.md)
            }
            .padding(.vertical, HLSpacing.xxs)
        } header: {
            Text("Preview")
        }
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
