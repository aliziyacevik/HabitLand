import SwiftUI

// MARK: - Floating Action Button

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    @State private var isPressed = false

    init(
        icon: String = HLIcon.add,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.hlPrimary)
                .clipShape(Circle())
                .hlShadow(HLShadow.lg)
        }
        .buttonStyle(FABButtonStyle())
        .accessibilityLabel("Add")
    }
}

// MARK: - FAB Button Style

private struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(HLAnimation.spring, value: configuration.isPressed)
    }
}

// MARK: - View Extension

extension View {
    /// Overlays a floating action button in the bottom-trailing corner.
    func floatingActionButton(
        icon: String = HLIcon.add,
        action: @escaping () -> Void
    ) -> some View {
        self.overlay(alignment: .bottomTrailing) {
            FloatingActionButton(icon: icon, action: action)
                .padding(.trailing, HLSpacing.lg)
                .padding(.bottom, HLSpacing.lg)
        }
    }
}

// MARK: - Preview

#Preview {
    Color.hlBackground
        .ignoresSafeArea()
        .floatingActionButton {
            // action
        }
}
