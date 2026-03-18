import SwiftUI

// MARK: - Accent Theme

enum AccentTheme: String, CaseIterable, Identifiable {
    case emerald = "Emerald"
    case ocean = "Ocean"
    case lavender = "Lavender"
    case sunset = "Sunset"
    case rose = "Rose"
    case sky = "Sky"

    var id: String { rawValue }

    var primary: Color {
        switch self {
        case .emerald: return Color(red: 0.20, green: 0.78, blue: 0.55)
        case .ocean: return Color(red: 0.18, green: 0.50, blue: 0.92)
        case .lavender: return Color(red: 0.55, green: 0.36, blue: 0.86)
        case .sunset: return Color(red: 0.98, green: 0.45, blue: 0.25)
        case .rose: return Color(red: 0.90, green: 0.30, blue: 0.45)
        case .sky: return Color(red: 0.20, green: 0.68, blue: 0.90)
        }
    }

    var primaryDark: Color {
        switch self {
        case .emerald: return Color(red: 0.13, green: 0.59, blue: 0.42)
        case .ocean: return Color(red: 0.12, green: 0.35, blue: 0.70)
        case .lavender: return Color(red: 0.40, green: 0.25, blue: 0.70)
        case .sunset: return Color(red: 0.80, green: 0.32, blue: 0.15)
        case .rose: return Color(red: 0.72, green: 0.20, blue: 0.35)
        case .sky: return Color(red: 0.14, green: 0.52, blue: 0.72)
        }
    }

    var primaryLight: Color {
        switch self {
        case .emerald: return Color(red: 0.85, green: 0.96, blue: 0.90)
        case .ocean: return Color(red: 0.85, green: 0.92, blue: 0.98)
        case .lavender: return Color(red: 0.92, green: 0.88, blue: 0.98)
        case .sunset: return Color(red: 0.98, green: 0.90, blue: 0.85)
        case .rose: return Color(red: 0.98, green: 0.88, blue: 0.90)
        case .sky: return Color(red: 0.86, green: 0.94, blue: 0.98)
        }
    }

    var icon: String {
        switch self {
        case .emerald: return "leaf.fill"
        case .ocean: return "water.waves"
        case .lavender: return "sparkles"
        case .sunset: return "sun.horizon.fill"
        case .rose: return "heart.fill"
        case .sky: return "cloud.sun.fill"
        }
    }
}

// MARK: - Appearance Mode

enum AppearanceMode: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Theme Manager

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    /// Saved (Pro) values
    @AppStorage("appearance_mode") private var savedAppearanceMode: Int = 0
    @AppStorage("accent_theme") private var savedAccentTheme: String = "Emerald"

    /// The active appearance mode
    @Published var appearanceMode: AppearanceMode = .system

    /// The active accent theme
    @Published var accentTheme: AccentTheme = .emerald {
        didSet { ActiveAccent.current = accentTheme }
    }

    private init() {
        // Load saved values
        appearanceMode = AppearanceMode(rawValue: savedAppearanceMode) ?? .system
        let theme = AccentTheme(rawValue: savedAccentTheme) ?? .emerald
        accentTheme = theme
        ActiveAccent.current = theme
    }

    var colorScheme: ColorScheme? {
        appearanceMode.colorScheme
    }

    /// Save current selections (Pro only)
    func save() {
        savedAppearanceMode = appearanceMode.rawValue
        savedAccentTheme = accentTheme.rawValue
    }

    /// Revert to saved values (when non-Pro user cancels)
    func revert() {
        appearanceMode = AppearanceMode(rawValue: savedAppearanceMode) ?? .system
        let theme = AccentTheme(rawValue: savedAccentTheme) ?? .emerald
        accentTheme = theme
        ActiveAccent.current = theme
    }

    /// Whether current selections differ from saved
    var hasUnsavedChanges: Bool {
        appearanceMode.rawValue != savedAppearanceMode || accentTheme.rawValue != savedAccentTheme
    }
}
