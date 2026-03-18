import SwiftUI

// MARK: - Header View

struct HeaderView<LeadingContent: View, TrailingContent: View>: View {
    let title: String
    let subtitle: String?
    let leadingContent: LeadingContent
    let trailingContent: TrailingContent

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> LeadingContent = { EmptyView() },
        @ViewBuilder trailing: () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingContent = leading()
        self.trailingContent = trailing()
    }

    var body: some View {
        HStack(alignment: .center, spacing: HLSpacing.sm) {
            leadingContent

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(title)
                    .font(HLFont.title2())
                    .foregroundColor(.hlTextPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(HLFont.subheadline())
                        .foregroundColor(.hlTextSecondary)
                }
            }

            Spacer(minLength: 0)

            trailingContent
        }
        .padding(.horizontal, HLSpacing.md)
        .padding(.vertical, HLSpacing.sm)
        .background(Color.hlSurface)
    }
}

// MARK: - Header Action Button

struct HeaderActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.hlTextPrimary)
                .frame(width: 36, height: 36)
                .background(Color.hlBackground)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Title only") {
    HeaderView(title: "Home")
}

#Preview("With subtitle and actions") {
    HeaderView(
        title: "Good Morning",
        subtitle: "Tuesday, March 17"
    ) {
        HeaderActionButton(icon: HLIcon.back) {}
    } trailing: {
        HStack(spacing: HLSpacing.xs) {
            HeaderActionButton(icon: HLIcon.search) {}
            HeaderActionButton(icon: HLIcon.notification) {}
        }
    }
}
