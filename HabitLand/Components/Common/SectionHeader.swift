import SwiftUI

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let seeAllAction: (() -> Void)?

    let actionTitle: String

    init(_ title: String, actionTitle: String = "See All", seeAllAction: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.seeAllAction = seeAllAction
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            Spacer()

            if let seeAllAction {
                Button(action: seeAllAction) {
                    Text(actionTitle)
                        .font(HLFont.subheadline(.medium))
                        .foregroundColor(.hlPrimary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HLSpacing.md)
        .padding(.vertical, HLSpacing.xs)
    }
}

// MARK: - Previews

#Preview("Without action") {
    SectionHeader("Today's Habits")
}

#Preview("With See All") {
    SectionHeader("Achievements") {
        // see all action
    }
}
