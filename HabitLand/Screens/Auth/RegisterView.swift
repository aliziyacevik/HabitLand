import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false

    var onRegister: (String, String, String, String) -> Void = { _, _, _, _ in }
    var onLogin: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.xl) {
                // Header
                VStack(spacing: HLSpacing.xs) {
                    Text("Create Account")
                        .font(HLFont.largeTitle())
                        .foregroundColor(.hlTextPrimary)

                    Text("Start your habit journey today")
                        .font(HLFont.body())
                        .foregroundColor(.hlTextSecondary)
                }
                .padding(.top, HLSpacing.xxl)

                // Fields
                VStack(spacing: HLSpacing.md) {
                    AuthTextField(
                        placeholder: "Full Name",
                        text: $name,
                        icon: "person",
                        textContentType: .name
                    )

                    AuthTextField(
                        placeholder: "Email",
                        text: $email,
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .never
                    )

                    AuthTextField(
                        placeholder: "Username",
                        text: $username,
                        icon: "at",
                        textContentType: .username,
                        autocapitalization: .never
                    )

                    AuthTextField(
                        placeholder: "Password",
                        text: $password,
                        icon: "lock",
                        isSecure: true,
                        textContentType: .newPassword
                    )

                    // Password strength indicator
                    if !password.isEmpty {
                        PasswordStrengthView(password: password)
                    }
                }

                // Create Account button
                HLButton(
                    "Create Account",
                    style: .primary,
                    size: .lg,
                    isFullWidth: true,
                    isLoading: isLoading,
                    isDisabled: !isFormValid
                ) {
                    isLoading = true
                    onRegister(name, email, username, password)
                }

                // Login link
                HStack(spacing: HLSpacing.xxs) {
                    Text("Already have an account?")
                        .font(HLFont.footnote())
                        .foregroundColor(.hlTextSecondary)

                    Button {
                        onLogin()
                    } label: {
                        Text("Sign In")
                            .font(HLFont.footnote(.semibold))
                            .foregroundColor(.hlPrimary)
                    }
                }
                .padding(.bottom, HLSpacing.xxl)
            }
            .padding(.horizontal, HLSpacing.lg)
        }
        .background(Color.hlBackground.ignoresSafeArea())
    }

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !username.isEmpty && password.count >= 6
    }
}

// MARK: - Password Strength

private struct PasswordStrengthView: View {
    let password: String

    private var strength: PasswordStrength {
        if password.count < 6 { return .weak }
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: .punctuationCharacters) != nil ||
           password.rangeOfCharacter(from: .symbols) != nil { score += 1 }

        switch score {
        case 0...1: return .weak
        case 2: return .fair
        case 3: return .good
        default: return .strong
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xxs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.hlDivider)
                        .frame(height: 4)

                    Capsule()
                        .fill(strength.color)
                        .frame(width: geometry.size.width * strength.progress, height: 4)
                        .animation(HLAnimation.standard, value: strength)
                }
            }
            .frame(height: 4)

            Text(strength.label)
                .font(HLFont.caption(.medium))
                .foregroundColor(strength.color)
        }
    }
}

private enum PasswordStrength {
    case weak, fair, good, strong

    var label: String {
        switch self {
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .good: return "Good"
        case .strong: return "Strong"
        }
    }

    var color: Color {
        switch self {
        case .weak: return .hlError
        case .fair: return .hlWarning
        case .good: return .hlInfo
        case .strong: return .hlSuccess
        }
    }

    var progress: CGFloat {
        switch self {
        case .weak: return 0.25
        case .fair: return 0.5
        case .good: return 0.75
        case .strong: return 1.0
        }
    }
}

#Preview {
    RegisterView()
}
