import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var isSent = false

    var onSendReset: (String) -> Void = { _ in }
    var onBackToLogin: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if isSent {
                sentContent
            } else {
                formContent
            }

            Spacer()

            // Back to login
            Button {
                onBackToLogin()
            } label: {
                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: HLIcon.back)
                        .font(.system(size: 13, weight: .semibold))

                    Text("Back to Sign In")
                        .font(HLFont.callout(.medium))
                }
                .foregroundColor(.hlPrimary)
            }
            .padding(.bottom, HLSpacing.xxl)
        }
        .padding(.horizontal, HLSpacing.lg)
        .background(Color.hlBackground.ignoresSafeArea())
    }

    // MARK: - Form Content

    private var formContent: some View {
        VStack(spacing: HLSpacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.hlPrimary.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: "lock.rotation")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.hlPrimary)
            }

            // Text
            VStack(spacing: HLSpacing.xs) {
                Text("Forgot Password?")
                    .font(HLFont.title1())
                    .foregroundColor(.hlTextPrimary)

                Text("Enter your email and we'll send you a link to reset your password.")
                    .font(HLFont.body())
                    .foregroundColor(.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Email field
            AuthTextField(
                placeholder: "Email",
                text: $email,
                icon: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never
            )

            // Send button
            HLButton(
                "Send Reset Link",
                icon: "paperplane",
                style: .primary,
                size: .lg,
                isFullWidth: true,
                isLoading: isLoading,
                isDisabled: email.isEmpty
            ) {
                isLoading = true
                onSendReset(email)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isLoading = false
                    withAnimation(HLAnimation.standard) {
                        isSent = true
                    }
                }
            }
        }
    }

    // MARK: - Sent Confirmation

    private var sentContent: some View {
        VStack(spacing: HLSpacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.hlPrimary.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: "envelope.badge.shield.half.filled")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.hlPrimary)
            }

            VStack(spacing: HLSpacing.xs) {
                Text("Check Your Email")
                    .font(HLFont.title1())
                    .foregroundColor(.hlTextPrimary)

                Text("We've sent a password reset link to **\(email)**. Check your inbox and follow the instructions.")
                    .font(HLFont.body())
                    .foregroundColor(.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            HLButton(
                "Resend Email",
                style: .outline,
                size: .lg,
                isFullWidth: true
            ) {
                onSendReset(email)
            }
        }
    }
}

#Preview("Form") {
    ForgotPasswordView()
}

#Preview("Sent") {
    ForgotPasswordView()
}
