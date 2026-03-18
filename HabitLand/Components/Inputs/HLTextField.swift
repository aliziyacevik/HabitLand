import SwiftUI

struct HLTextField: View {
    let label: String
    let placeholder: String
    var icon: String?
    var errorMessage: String?

    @Binding var text: String
    @FocusState private var isFocused: Bool

    private var hasError: Bool {
        errorMessage != nil && !(errorMessage?.isEmpty ?? true)
    }

    private var borderColor: Color {
        if hasError { return .hlError }
        if isFocused { return .hlPrimary }
        return .hlCardBorder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xxs) {
            Text(label)
                .font(HLFont.subheadline(.medium))
                .foregroundStyle(Color.hlTextPrimary)

            HStack(spacing: HLSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isFocused ? Color.hlPrimary : Color.hlTextTertiary)
                        .frame(width: 20)
                }

                TextField(placeholder, text: $text)
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextPrimary)
                    .focused($isFocused)
            }
            .padding(.horizontal, HLSpacing.sm)
            .padding(.vertical, HLSpacing.sm)
            .background(Color.hlSurface)
            .clipShape(RoundedRectangle(cornerRadius: HLRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .stroke(borderColor, lineWidth: isFocused || hasError ? 1.5 : 1)
            )
            .animation(HLAnimation.quick, value: isFocused)
            .animation(HLAnimation.quick, value: hasError)

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlError)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(HLAnimation.quick, value: errorMessage)
    }
}

#Preview {
    VStack(spacing: HLSpacing.lg) {
        HLTextField(
            label: "Habit Name",
            placeholder: "e.g. Morning Meditation",
            icon: "pencil",
            text: .constant("")
        )

        HLTextField(
            label: "Email",
            placeholder: "you@example.com",
            icon: "envelope",
            errorMessage: "Please enter a valid email",
            text: .constant("bad-email")
        )

        HLTextField(
            label: "Notes",
            placeholder: "Optional notes...",
            text: .constant("Some text here")
        )
    }
    .padding()
    .background(Color.hlBackground)
}
