import SwiftUI

// MARK: - Loading View

struct LoadingView: View {
    let message: String?

    init(_ message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: HLSpacing.lg) {
            VStack(spacing: HLSpacing.sm) {
                SkeletonCardView()
                SkeletonCardView()
                SkeletonCardView()
            }
            .padding(.horizontal, HLSpacing.md)

            if let message {
                Text(message)
                    .font(HLFont.subheadline())
                    .foregroundColor(.hlTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - View Extension

extension View {
    /// Overlays a loading indicator when the condition is true.
    func loading(_ isLoading: Bool, message: String? = nil) -> some View {
        self.overlay {
            if isLoading {
                LoadingView(message)
                    .background(Color.hlBackground.opacity(0.8))
                    .transition(.opacity)
            }
        }
        .animation(HLAnimation.quick, value: isLoading)
    }
}

// MARK: - Previews

#Preview("Spinner only") {
    LoadingView()
}

#Preview("With message") {
    LoadingView("Loading habits...")
}
