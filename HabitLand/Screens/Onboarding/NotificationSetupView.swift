import SwiftUI

struct NotificationSetupView: View {
    @State private var isAnimating = false
    var onEnable: () -> Void = {}
    var onSkip: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Illustration
            ZStack {
                Circle()
                    .fill(Color.hlPrimary.opacity(0.08))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)

                Circle()
                    .fill(Color.hlPrimary.opacity(0.12))
                    .frame(width: 140, height: 140)

                Image(systemName: HLIcon.notification)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundColor(.hlPrimary)
                    .offset(y: isAnimating ? -4 : 4)
            }
            .animation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }

            Spacer()
                .frame(height: HLSpacing.xxxl)

            // Text content
            VStack(spacing: HLSpacing.sm) {
                Text("Never Miss a Habit")
                    .font(HLFont.title1())
                    .foregroundColor(.hlTextPrimary)

                Text("Get gentle reminders to stay on track with your habits and maintain your streaks.")
                    .font(HLFont.body())
                    .foregroundColor(.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, HLSpacing.xl)
            }

            Spacer()

            // Buttons
            VStack(spacing: HLSpacing.md) {
                HLButton(
                    "Enable Notifications",
                    icon: HLIcon.bell,
                    style: .primary,
                    size: .lg,
                    isFullWidth: true
                ) {
                    onEnable()
                }

                Button {
                    onSkip()
                } label: {
                    Text("Maybe Later")
                        .font(HLFont.callout(.medium))
                        .foregroundColor(.hlTextSecondary)
                }
            }
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
    }
}

#Preview {
    NotificationSetupView()
}
