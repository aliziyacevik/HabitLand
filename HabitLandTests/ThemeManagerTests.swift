import Testing
import Foundation
@testable import HabitLand

// MARK: - ThemeManager Tests

struct ThemeManagerExtendedTests {

    // MARK: - AccentTheme Properties

    @Test func allThemesHavePrimaryColor() {
        for theme in AccentTheme.allCases {
            let _ = theme.primary // Should not crash
        }
    }

    @Test func allThemesHavePrimaryDarkColor() {
        for theme in AccentTheme.allCases {
            let _ = theme.primaryDark
        }
    }

    @Test func allThemesHavePrimaryLightColor() {
        for theme in AccentTheme.allCases {
            let _ = theme.primaryLight
        }
    }

    @Test func allThemesHaveIcon() {
        for theme in AccentTheme.allCases {
            #expect(!theme.icon.isEmpty)
        }
    }

    @Test func allThemesHaveId() {
        for theme in AccentTheme.allCases {
            #expect(theme.id == theme.rawValue)
        }
    }

    // MARK: - Required Levels

    @Test func emeraldAndOceanAreFree() {
        #expect(AccentTheme.emerald.requiredLevel == 0)
        #expect(AccentTheme.ocean.requiredLevel == 0)
    }

    @Test func themeUnlockLevelsAscend() {
        let levels = AccentTheme.allCases.map(\.requiredLevel)
        for i in 1..<levels.count {
            #expect(levels[i] >= levels[i - 1])
        }
    }

    @Test func specificThemeLevels() {
        #expect(AccentTheme.lavender.requiredLevel == 5)
        #expect(AccentTheme.sunset.requiredLevel == 10)
        #expect(AccentTheme.rose.requiredLevel == 15)
        #expect(AccentTheme.sky.requiredLevel == 20)
    }

    // MARK: - AppearanceMode

    @Test func systemModeHasNilColorScheme() {
        #expect(AppearanceMode.system.colorScheme == nil)
    }

    @Test func lightModeHasLightColorScheme() {
        #expect(AppearanceMode.light.colorScheme == .light)
    }

    @Test func darkModeHasDarkColorScheme() {
        #expect(AppearanceMode.dark.colorScheme == .dark)
    }

    @Test func allModesHaveTitle() {
        for mode in AppearanceMode.allCases {
            #expect(!mode.title.isEmpty)
        }
    }

    @Test func allModesHaveIcon() {
        for mode in AppearanceMode.allCases {
            #expect(!mode.icon.isEmpty)
        }
    }

    @Test func allModesHaveId() {
        for mode in AppearanceMode.allCases {
            #expect(mode.id == mode.rawValue)
        }
    }

    @Test func modeRawValues() {
        #expect(AppearanceMode.system.rawValue == 0)
        #expect(AppearanceMode.light.rawValue == 1)
        #expect(AppearanceMode.dark.rawValue == 2)
    }

    // MARK: - ThemeManager Singleton

    @Test @MainActor func themeManagerSaveAndRevert() {
        let manager = ThemeManager.shared
        let originalTheme = manager.accentTheme
        let originalMode = manager.appearanceMode

        // Change
        manager.accentTheme = .sunset
        manager.appearanceMode = .dark
        #expect(manager.hasUnsavedChanges == true)

        // Revert
        manager.revert()
        #expect(manager.accentTheme.rawValue == originalTheme.rawValue || !manager.hasUnsavedChanges)

        // Restore
        manager.accentTheme = originalTheme
        manager.appearanceMode = originalMode
        manager.save()
    }

    @Test @MainActor func themeManagerSavePersists() {
        let manager = ThemeManager.shared
        let originalTheme = manager.accentTheme

        manager.accentTheme = .ocean
        manager.save()

        #expect(manager.hasUnsavedChanges == false)

        // Restore original
        manager.accentTheme = originalTheme
        manager.save()
    }
}
