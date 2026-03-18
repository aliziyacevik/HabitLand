import SwiftUI

struct HLTimePicker: View {
    let label: String
    @Binding var selection: Date

    var body: some View {
        DatePicker(selection: $selection, displayedComponents: .hourAndMinute) {
            Text(label)
                .font(HLFont.body(.medium))
                .foregroundStyle(Color.hlTextPrimary)
        }
        .tint(Color.hlPrimary)
    }
}

#Preview {
    VStack(spacing: HLSpacing.lg) {
        HLTimePicker(
            label: "Reminder Time",
            selection: .constant(Date())
        )

        HLTimePicker(
            label: "Bedtime",
            selection: .constant(Date())
        )
    }
    .padding()
}
