import SwiftUI

// MARK: - Privacy Policy View

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HLSpacing.lg) {
                    legalSection(title: "Privacy Policy", content: """
                    Last updated: March 2026

                    HabitLand ("we", "our", or "the app") respects your privacy. This policy explains what data we collect, how we use it, and your rights.
                    """)

                    legalSection(title: "Data We Collect", content: """
                    HabitLand stores all your data locally on your device using Apple's SwiftData framework. We do not collect, transmit, or store any personal data on external servers.

                    The data stored on your device includes:
                    • Habit names, schedules, and completion records
                    • Sleep logs and quality ratings
                    • User profile information (name, avatar)
                    • Achievement progress
                    • App preferences and settings
                    """)

                    legalSection(title: "Data We Do NOT Collect", content: """
                    • We do not collect analytics or usage data
                    • We do not use advertising trackers
                    • We do not share any data with third parties
                    • We do not use cookies or web tracking
                    • We do not collect location data
                    """)

                    legalSection(title: "In-App Purchases", content: """
                    HabitLand Pro subscriptions and purchases are processed entirely by Apple through the App Store. We do not have access to your payment information, credit card details, or Apple ID.
                    """)

                    legalSection(title: "Notifications", content: """
                    If you enable notifications, they are scheduled locally on your device. No notification data is sent to external servers.
                    """)

                    legalSection(title: "Data Deletion", content: """
                    Since all data is stored locally on your device, you can delete all app data by uninstalling HabitLand. No data remains on any server after deletion.
                    """)

                    legalSection(title: "Children's Privacy", content: """
                    HabitLand does not knowingly collect data from children under 13. The app is suitable for all ages as it stores data only on the user's device.
                    """)

                    legalSection(title: "Changes to This Policy", content: """
                    We may update this privacy policy from time to time. Changes will be reflected in the app with an updated date.
                    """)

                    legalSection(title: "Contact", content: """
                    If you have questions about this privacy policy, please contact us through the App Store.
                    """)
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.md)
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.hlPrimary)
                }
            }
        }
    }
}

// MARK: - Terms of Use View

struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HLSpacing.lg) {
                    legalSection(title: "Terms of Use", content: """
                    Last updated: March 2026

                    By downloading or using HabitLand, you agree to these terms. Please read them carefully.
                    """)

                    legalSection(title: "License", content: """
                    HabitLand grants you a limited, non-exclusive, non-transferable license to use the app on Apple devices that you own or control, subject to the Apple Media Services Terms and Conditions.
                    """)

                    legalSection(title: "Subscriptions & Purchases", content: """
                    HabitLand offers optional in-app purchases:

                    • HabitLand Pro Yearly ($19.99/year): Auto-renewing annual subscription that unlocks all premium features. Automatically renews unless cancelled at least 24 hours before the end of the current period.

                    • HabitLand Pro Lifetime ($39.99): One-time purchase that permanently unlocks all premium features.

                    Payment is charged to your Apple ID account at confirmation of purchase. You can manage and cancel subscriptions in your device's Settings > Apple ID > Subscriptions.
                    """)

                    legalSection(title: "Free Features", content: """
                    The free version of HabitLand includes:
                    • Up to 3 habits
                    • Basic daily tracking and streaks
                    • Weekly progress overview
                    • Basic reminders
                    """)

                    legalSection(title: "Acceptable Use", content: """
                    You agree to use HabitLand only for its intended purpose of personal habit tracking. You may not reverse engineer, decompile, or disassemble the app.
                    """)

                    legalSection(title: "Disclaimer", content: """
                    HabitLand is provided "as is" without warranty of any kind. We do not guarantee that the app will be error-free or uninterrupted. HabitLand is not a medical, health, or fitness device and should not be used as a substitute for professional advice.
                    """)

                    legalSection(title: "Limitation of Liability", content: """
                    To the maximum extent permitted by law, HabitLand shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the app.
                    """)

                    legalSection(title: "Changes to Terms", content: """
                    We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.
                    """)

                    legalSection(title: "Contact", content: """
                    For questions about these terms, please contact us through the App Store.
                    """)
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.md)
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .navigationTitle("Terms of Use")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.hlPrimary)
                }
            }
        }
    }
}

// MARK: - Shared Section Helper

private func legalSection(title: String, content: String) -> some View {
    VStack(alignment: .leading, spacing: HLSpacing.xs) {
        Text(title)
            .font(HLFont.headline())
            .foregroundStyle(Color.hlTextPrimary)
        Text(content)
            .font(HLFont.subheadline())
            .foregroundStyle(Color.hlTextSecondary)
            .lineSpacing(4)
    }
}

#Preview("Privacy") {
    PrivacyPolicyView()
}

#Preview("Terms") {
    TermsOfUseView()
}
