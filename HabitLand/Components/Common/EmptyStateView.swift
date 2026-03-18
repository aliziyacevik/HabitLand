import SwiftUI

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.hlTextTertiary)
                .padding(.bottom, HLSpacing.xs)

            VStack(spacing: HLSpacing.xs) {
                Text(title)
                    .font(HLFont.title3())
                    .foregroundColor(.hlTextPrimary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(HLFont.subheadline())
                    .foregroundColor(.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            if let actionTitle, let action {
                HLButton(actionTitle, style: .primary, size: .md, action: action)
                    .padding(.top, HLSpacing.xs)
            }
        }
        .padding(HLSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

#Preview("Without action") {
    EmptyStateView(
        icon: HLIcon.habits,
        title: "No Habits Yet",
        subtitle: "Start building healthy habits by adding your first one."
    )
}

#Preview("With action") {
    EmptyStateView(
        icon: HLIcon.target,
        title: "No Goals Set",
        subtitle: "Set a goal to stay motivated and track your progress.",
        actionTitle: "Create Goal"
    ) {
        // action
    }
}
