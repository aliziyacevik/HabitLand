import SwiftUI

// MARK: - Button Style Variant

enum HLButtonStyle {
    case primary
    case secondary
    case outline
}

// MARK: - Button Size

enum HLButtonSize {
    case sm, md, lg

    var verticalPadding: CGFloat {
        switch self {
        case .sm: return HLSpacing.xs
        case .md: return HLSpacing.sm
        case .lg: return HLSpacing.md
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .sm: return HLSpacing.sm
        case .md: return HLSpacing.md
        case .lg: return HLSpacing.lg
        }
    }

    var font: Font {
        switch self {
        case .sm: return HLFont.footnote(.semibold)
        case .md: return HLFont.callout(.semibold)
        case .lg: return HLFont.body(.semibold)
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .sm: return HLRadius.sm
        case .md: return HLRadius.md
        case .lg: return HLRadius.lg
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .sm: return 14
        case .md: return 16
        case .lg: return 18
        }
    }
}

// MARK: - HLButton

struct HLButton: View {
    let title: String
    let icon: String?
    let style: HLButtonStyle
    let size: HLButtonSize
    let isFullWidth: Bool
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        style: HLButtonStyle = .primary,
        size: HLButtonSize = .md,
        isFullWidth: Bool = false,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: HLSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: min(size.iconSize, 22), weight: .semibold))
                }

                Text(title)
                    .font(size.font)
            }
            .foregroundColor(foregroundColor)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(backgroundColor)
            .cornerRadius(size.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .strokeBorder(borderColor, lineWidth: style == .outline ? 1.5 : 0)
            )
        }
        .buttonStyle(HLButtonPressStyle())
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Computed Colors

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .hlPrimary
        case .outline: return .hlPrimary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return .hlPrimary
        case .secondary: return .hlPrimaryLight
        case .outline: return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .secondary: return .clear
        case .outline: return .hlPrimary
        }
    }
}

// MARK: - Press Style

private struct HLButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(HLAnimation.microSpring, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HLHaptics.light() }
            }
    }
}

// MARK: - Previews

#Preview("Primary") {
    VStack(spacing: HLSpacing.md) {
        HLButton("Small", style: .primary, size: .sm) {}
        HLButton("Medium", style: .primary, size: .md) {}
        HLButton("Large", style: .primary, size: .lg) {}
        HLButton("Full Width", style: .primary, size: .lg, isFullWidth: true) {}
        HLButton("With Icon", icon: HLIcon.add, style: .primary) {}
        HLButton("Loading", style: .primary, isLoading: true) {}
        HLButton("Disabled", style: .primary, isDisabled: true) {}
    }
    .padding()
}

#Preview("Secondary") {
    VStack(spacing: HLSpacing.md) {
        HLButton("Secondary SM", style: .secondary, size: .sm) {}
        HLButton("Secondary MD", style: .secondary, size: .md) {}
        HLButton("Secondary LG", style: .secondary, size: .lg) {}
    }
    .padding()
}

#Preview("Outline") {
    VStack(spacing: HLSpacing.md) {
        HLButton("Outline SM", style: .outline, size: .sm) {}
        HLButton("Outline MD", style: .outline, size: .md) {}
        HLButton("Outline LG", style: .outline, size: .lg) {}
    }
    .padding()
}
