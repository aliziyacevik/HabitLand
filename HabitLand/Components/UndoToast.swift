import SwiftUI

struct UndoToast: View {
    @ScaledMetric(relativeTo: .body) private var toastIconSize: CGFloat = 18
    let message: String
    let onUndo: () -> Void
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: min(toastIconSize, 22)))
                    .foregroundStyle(Color.hlPrimary)

                Text(message)
                    .font(HLFont.subheadline(.medium))
                    .foregroundStyle(Color.hlTextPrimary)

                Spacer()

                Button {
                    onUndo()
                    withAnimation(HLAnimation.quick) {
                        isVisible = false
                    }
                    HLHaptics.light()
                } label: {
                    Text("Undo")
                        .font(HLFont.subheadline(.semibold))
                        .foregroundStyle(Color.hlPrimary)
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.sm)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: HLRadius.lg))
            .hlShadow(HLShadow.md)
            .padding(.horizontal, HLSpacing.md)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(HLAnimation.quick) {
                        isVisible = false
                    }
                }
            }
        }
    }
}
