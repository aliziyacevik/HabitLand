import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var onLogin: (String, String) -> Void = { _, _ in }
    var onForgotPassword: () -> Void = {}
    var onSignUp: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.xl) {
                Spacer()
                    .frame(height: HLSpacing.xxxxl)

                // Logo area
                VStack(spacing: HLSpacing.xs) {
                    Text("🌱")
                        .font(.system(size: 64))

                    Text("HabitLand")
                        .font(HLFont.largeTitle())
                        .foregroundColor(.hlTextPrimary)
                }

                Spacer()
                    .frame(height: HLSpacing.lg)

                // Input fields
                VStack(spacing: HLSpacing.md) {
                    AuthTextField(
                        placeholder: "Email",
                        text: $email,
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .never
                    )

                    AuthTextField(
                        placeholder: "Password",
                        text: $password,
                        icon: "lock",
                        isSecure: true,
                        textContentType: .password
                    )
                }

                // Forgot password
                HStack {
                    Spacer()
                    Button {
                        onForgotPassword()
                    } label: {
                        Text("Forgot Password?")
                            .font(HLFont.footnote(.medium))
                            .foregroundColor(.hlPrimary)
                    }
                }

                // Sign In button
                HLButton(
                    "Sign In",
                    style: .primary,
                    size: .lg,
                    isFullWidth: true,
                    isLoading: isLoading,
                    isDisabled: email.isEmpty || password.isEmpty
                ) {
                    isLoading = true
                    onLogin(email, password)
                }

                Spacer()
                    .frame(height: HLSpacing.xl)

                // Sign up link
                HStack(spacing: HLSpacing.xxs) {
                    Text("Don't have an account?")
                        .font(HLFont.footnote())
                        .foregroundColor(.hlTextSecondary)

                    Button {
                        onSignUp()
                    } label: {
                        Text("Sign Up")
                            .font(HLFont.footnote(.semibold))
                            .foregroundColor(.hlPrimary)
                    }
                }
            }
            .padding(.horizontal, HLSpacing.lg)
        }
        .background(Color.hlBackground.ignoresSafeArea())
    }
}

// MARK: - Auth Text Field

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences

    @State private var isSecureVisible = false

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.hlTextTertiary)
                    .frame(width: 20)
            }

            if isSecure && !isSecureVisible {
                SecureField(placeholder, text: $text)
                    .font(HLFont.body())
                    .textContentType(textContentType)
                    .textInputAutocapitalization(autocapitalization)
            } else {
                TextField(placeholder, text: $text)
                    .font(HLFont.body())
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .textInputAutocapitalization(autocapitalization)
            }

            if isSecure {
                Button {
                    isSecureVisible.toggle()
                } label: {
                    Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.hlTextTertiary)
                }
            }
        }
        .padding(.horizontal, HLSpacing.md)
        .padding(.vertical, HLSpacing.sm)
        .background(Color.hlSurface)
        .cornerRadius(HLRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .strokeBorder(Color.hlCardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    LoginView()
}
