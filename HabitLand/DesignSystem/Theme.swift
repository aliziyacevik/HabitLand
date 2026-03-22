import SwiftUI
import UIKit

// MARK: - Active Accent (thread-safe, no actor isolation)

enum ActiveAccent {
    /// Updated from ThemeManager on main thread; read from anywhere for colors.
    nonisolated(unsafe) static var current: AccentTheme = {
        let saved = UserDefaults.standard.string(forKey: "accent_theme") ?? "Emerald"
        return AccentTheme(rawValue: saved) ?? .emerald
    }()
}

// MARK: - Color Palette

extension Color {
    // Primary (dynamic — driven by ActiveAccent.current)
    static var hlPrimary: Color { ActiveAccent.current.primary }
    static var hlPrimaryDark: Color { ActiveAccent.current.primaryDark }
    static var hlPrimaryLight: Color { ActiveAccent.current.primaryLight }

    // Neutrals (adaptive for dark mode)
    static let hlBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1)   // #121217
            : UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)   // #F8F8FA
    })
    static let hlSurface = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)   // #1C1C1E
            : UIColor.white
    })
    static let hlTextPrimary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)   // #F5F5F7
            : UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)   // #1A1A1F
    })
    static let hlTextSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.63, green: 0.63, blue: 0.65, alpha: 1)   // #A1A1A6
            : UIColor(red: 0.45, green: 0.45, blue: 0.50, alpha: 1)   // #737380
    })
    static let hlTextTertiary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1)   // #6E6E73
            : UIColor(red: 0.45, green: 0.45, blue: 0.50, alpha: 1)   // #737380
    })
    static let hlDivider = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)   // #2C2C2E
            : UIColor(red: 0.92, green: 0.92, blue: 0.93, alpha: 1)   // #EBEBEE
    })
    static let hlCardBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.23, green: 0.23, blue: 0.24, alpha: 1)   // #3A3A3C
            : UIColor(red: 0.94, green: 0.94, blue: 0.95, alpha: 1)
    })

    // Status
    static let hlSuccess = Color(red: 0.20, green: 0.78, blue: 0.55)
    static let hlWarning = Color(red: 1.00, green: 0.76, blue: 0.03)        // #FFC207
    static let hlError = Color(red: 0.95, green: 0.30, blue: 0.30)          // #F24D4D
    static let hlInfo = Color(red: 0.20, green: 0.56, blue: 1.00)           // #338FFF

    // Gamification
    static let hlFlame = Color(red: 1.00, green: 0.55, blue: 0.10)          // Orange flame
    static let hlGold = Color(red: 1.00, green: 0.84, blue: 0.00)           // Gold
    static let hlSilver = Color(red: 0.75, green: 0.75, blue: 0.78)
    static let hlBronze = Color(red: 0.80, green: 0.50, blue: 0.20)

    // Category Colors
    static let hlHealth = Color(red: 0.95, green: 0.30, blue: 0.40)
    static let hlFitness = Color(red: 0.20, green: 0.56, blue: 1.00)
    static let hlMindfulness = Color(red: 0.60, green: 0.40, blue: 0.90)
    static let hlProductivity = Color(red: 1.00, green: 0.60, blue: 0.10)
    static let hlSleep = Color(red: 0.40, green: 0.35, blue: 0.80)
    static let hlSocial = Color(red: 0.95, green: 0.45, blue: 0.55)
}

// MARK: - Typography

struct HLFont {
    static func largeTitle(_ weight: Font.Weight = .bold) -> Font {
        .system(.largeTitle, design: .rounded, weight: weight)
    }
    static func title1(_ weight: Font.Weight = .bold) -> Font {
        .system(.title, design: .rounded, weight: weight)
    }
    static func title2(_ weight: Font.Weight = .semibold) -> Font {
        .system(.title2, design: .rounded, weight: weight)
    }
    static func title3(_ weight: Font.Weight = .semibold) -> Font {
        .system(.title3, design: .rounded, weight: weight)
    }
    static func headline(_ weight: Font.Weight = .semibold) -> Font {
        .system(.headline, design: .rounded, weight: weight)
    }
    static func body(_ weight: Font.Weight = .regular) -> Font {
        .system(.body, design: .rounded, weight: weight)
    }
    static func callout(_ weight: Font.Weight = .regular) -> Font {
        .system(.callout, design: .rounded, weight: weight)
    }
    static func subheadline(_ weight: Font.Weight = .regular) -> Font {
        .system(.subheadline, design: .rounded, weight: weight)
    }
    static func footnote(_ weight: Font.Weight = .regular) -> Font {
        .system(.footnote, design: .rounded, weight: weight)
    }
    static func caption(_ weight: Font.Weight = .regular) -> Font {
        .system(.caption, design: .rounded, weight: weight)
    }
    static func caption2(_ weight: Font.Weight = .regular) -> Font {
        .system(.caption2, design: .rounded, weight: weight)
    }

    /// Display size for large decorative numbers (40pt+). Uses largeTitle as base for Dynamic Type.
    static func display(_ weight: Font.Weight = .bold) -> Font {
        .system(.largeTitle, design: .rounded, weight: weight)
    }
}

// MARK: - Spacing (8-point grid)

struct HLSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48
    static let xxxxl: CGFloat = 64
}

// MARK: - Corner Radius

struct HLRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 999
}

// MARK: - Elevation (Shadows)

struct HLShadow {
    struct Level {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    static let none = Level(color: .clear, radius: 0, x: 0, y: 0)
    static let sm = Level(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    static let md = Level(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    static let lg = Level(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    static let xl = Level(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 12)
}

extension View {
    func hlShadow(_ level: HLShadow.Level) -> some View {
        self.shadow(color: level.color, radius: level.radius, x: level.x, y: level.y)
    }
}

// MARK: - Card Style Modifier

struct HLCardModifier: ViewModifier {
    var padding: CGFloat = HLSpacing.md
    var shadow: HLShadow.Level = HLShadow.sm
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        content
            .padding(padding)
            .background(
                ZStack {
                    Color.hlSurface

                    // Subtle top inner highlight (light reflection) — reduced in dark mode
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isDark ? 0.08 : 0.5),
                            Color.white.opacity(0),
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .opacity(isDark ? 0.08 : 0.15)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: HLRadius.lg))
            // subtle border highlight
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isDark ? 0.1 : 0.4),
                                Color.white.opacity(isDark ? 0.02 : 0.05),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            // ambient shadow — stronger in dark mode for depth
            .shadow(color: Color.black.opacity(isDark ? 0.2 : 0.03), radius: isDark ? 2 : 1, y: 1)
            .hlShadow(shadow)
    }
}

extension View {
    func hlCard(padding: CGFloat = HLSpacing.md, shadow: HLShadow.Level = HLShadow.sm) -> some View {
        self.modifier(HLCardModifier(padding: padding, shadow: shadow))
    }
}

// MARK: - Icon System

struct HLIcon {
    // Tab Bar
    static let home = "house.fill"
    static let habits = "checkmark.circle.fill"
    static let sleep = "moon.fill"
    static let social = "person.2.fill"
    static let profile = "person.fill"

    // Navigation
    static let back = "chevron.left"
    static let close = "xmark"
    static let settings = "gearshape"
    static let more = "ellipsis"
    static let add = "plus"
    static let search = "magnifyingglass"
    static let filter = "line.3.horizontal.decrease"
    static let edit = "pencil"
    static let delete = "trash"
    static let share = "square.and.arrow.up"

    // Habits
    static let checkmark = "checkmark"
    static let clock = "clock"
    static let calendar = "calendar"
    static let repeat_ = "arrow.triangle.2.circlepath"
    static let bell = "bell"
    static let note = "note.text"
    static let archive = "archivebox"
    static let chart = "chart.bar"
    static let target = "target"

    // Gamification
    static let flame = "flame.fill"
    static let trophy = "trophy.fill"
    static let star = "star.fill"
    static let medal = "medal.fill"
    static let crown = "crown.fill"
    static let bolt = "bolt.fill"
    static let gift = "gift.fill"

    // Social
    static let person = "person.fill"
    static let personAdd = "person.badge.plus"
static let leaderboard = "list.number"
    static let challenge = "flag.fill"

    // Sleep
    static let moon = "moon.fill"
    static let sunrise = "sunrise.fill"
    static let bed = "bed.double.fill"
    static let zzz = "zzz"

    // Analytics
    static let trendUp = "arrow.up.right"
    static let trendDown = "arrow.down.right"
    static let pieChart = "chart.pie"
    static let barChart = "chart.bar.fill"
    static let lineChart = "chart.xyaxis.line"

    // Misc
    static let notification = "bell.fill"
    static let privacy = "lock.fill"
    static let export_ = "square.and.arrow.down"
    static let info = "info.circle"
    static let heart = "heart.fill"
    static let lightning = "bolt.fill"
    static let sparkles = "sparkles"
    static let brain = "brain.head.profile"
}

// MARK: - Animation Constants

struct HLAnimation {
    static let quick = Animation.easeInOut(duration: 0.2)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 0.5)
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
}
