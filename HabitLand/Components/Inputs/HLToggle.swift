import SwiftUI

struct HLToggle: View {
    let label: String
    var description: String?
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(label)
                    .font(HLFont.body(.medium))
                    .foregroundStyle(Color.hlTextPrimary)

                if let description {
                    Text(description)
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary)
                }
            }
        }
        .tint(Color.hlPrimary)
    }
}

#Preview {
    VStack(spacing: HLSpacing.lg) {
        HLToggle(
            label: "Enable Reminders",
            description: "Get notified when it's time for your habit",
            isOn: .constant(true)
        )

        HLToggle(
            label: "Archive Habit",
            isOn: .constant(false)
        )
    }
    .padding()
}
