import SwiftUI
import SwiftData
import StoreKit

struct GeneralSettingsView: View {
    @ScaledMetric(relativeTo: .caption) private var safariIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var settingsIconSize: CGFloat = 14
    // MARK: - Legal URLs
    // Update this base URL with your GitHub Pages domain when deployed
    private static let legalBaseURL = "https://azc.github.io/HabitLand"
    private static let privacyURL = "\(legalBaseURL)/privacy"
    private static let termsURL = "\(legalBaseURL)/terms"

    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }

    @ObservedObject private var proManager = ProManager.shared
    // CloudKit disabled — social features removed
    @State private var showPaywall = false
    @State private var showPrivacy = false
    @State private var showTerms = false

    var body: some View {
        List {
            if !proManager.isPro {
                Section {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: HLSpacing.sm) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: min(settingsIconSize, 18)))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(
                                    LinearGradient(
                                        colors: [Color.hlFlame, Color.hlWarning],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(HLRadius.xs)

                            Text("Upgrade to Pro")
                                .font(HLFont.body(.semibold))
                                .foregroundColor(.hlTextPrimary)

                            Spacer()

                            ProBadge()
                        }
                    }
                }
            }

            Section {
                // Current plan status (D-06)
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: proManager.currentPlanDisplay.icon)
                        .font(.system(size: min(settingsIconSize, 18)))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(
                            proManager.isPro
                                ? LinearGradient(colors: [Color.hlPrimary, Color.hlPrimaryDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.hlTextSecondary, Color.hlTextTertiary], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(HLRadius.xs)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(proManager.currentPlanDisplay.name)
                            .font(HLFont.body(.semibold))
                            .foregroundColor(.hlTextPrimary)
                        if proManager.isPro {
                            Text("All features unlocked")
                                .font(HLFont.caption())
                                .foregroundColor(.hlTextSecondary)
                        }
                    }

                    Spacer()

                    if proManager.isPro {
                        ProBadge()
                    }
                }

                NavigationLink(destination: EditProfileView()) {
                    settingsRow(icon: "person.fill", color: .hlPrimary, title: "Edit Profile")
                }

                // Manage Subscription deep link (D-05) — only for Pro users with yearly subscription
                if proManager.purchasedProductIDs.contains(ProManager.yearlyID) {
                    Button {
                        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        settingsRow(icon: "creditcard.fill", color: .hlPrimary, title: "Manage Subscription")
                    }
                }

            } header: {
                Text("Account")
            }

            // iCloud Sync section removed — CloudKit not active

            Section {
                NavigationLink(destination: AppearanceSettingsView()) {
                    settingsRow(icon: "paintbrush.fill", color: .hlMindfulness, title: "Appearance")
                }
                NavigationLink(destination: HabitSettingsView()) {
                    settingsRow(icon: "checkmark.circle", color: .hlPrimary, title: "Habit Settings")
                }
                NavigationLink(destination: NotificationSettingsView()) {
                    settingsRow(icon: "bell.fill", color: .hlFlame, title: "Notifications")
                }
            } header: {
                Text("Preferences")
            }

            Section {
                NavigationLink(destination: DataExportView()) {
                    settingsRow(icon: "square.and.arrow.down", color: .hlMindfulness, title: "Data & Export")
                }
            } header: {
                Text("Data & Privacy")
            }

            Section {
                Button { showPrivacy = true } label: {
                    settingsRow(icon: "hand.raised.fill", color: .hlInfo, title: "Privacy Policy")
                }
                if let url = URL(string: Self.privacyURL) {
                    Link(destination: url) {
                        HStack(spacing: HLSpacing.sm) {
                            Color.clear
                                .frame(width: 28, height: 28)
                            Text("View Online")
                                .font(HLFont.caption())
                                .foregroundColor(.hlPrimary)
                            Spacer()
                            Image(systemName: "safari")
                                .font(.system(size: min(safariIconSize, 16)))
                                .foregroundColor(.hlTextTertiary)
                        }
                    }
                }
                Button { showTerms = true } label: {
                    settingsRow(icon: "doc.text.fill", color: .hlTextSecondary, title: "Terms of Use")
                }
                if let url = URL(string: Self.termsURL) {
                    Link(destination: url) {
                        HStack(spacing: HLSpacing.sm) {
                            Color.clear
                                .frame(width: 28, height: 28)
                            Text("View Online")
                                .font(HLFont.caption())
                                .foregroundColor(.hlPrimary)
                            Spacer()
                            Image(systemName: "safari")
                                .font(.system(size: min(safariIconSize, 16)))
                                .foregroundColor(.hlTextTertiary)
                        }
                    }
                }
            } header: {
                Text("Legal")
            }

            Section {
                Button {
                    if let url = URL(string: "https://azc.github.io/HabitLand/help") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    settingsRow(icon: "questionmark.circle", color: .hlTextSecondary, title: "Help Center")
                }

                Button {
                    if let url = URL(string: "mailto:support@habitland.app?subject=HabitLand%20Support") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    settingsRow(icon: "envelope", color: .hlTextSecondary, title: "Contact Support")
                }

                Button {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                } label: {
                    settingsRow(icon: "star", color: .hlGold, title: "Rate HabitLand")
                }
            } header: {
                Text("Support")
            }

            if !proManager.isPro {
                Section {
                    Button {
                        Task { await proManager.redeemPromoCode() }
                    } label: {
                        settingsRow(icon: "ticket.fill", color: .hlGold, title: "Redeem Promo Code")
                    }
                } header: {
                    Text("Promo")
                }
            }

            #if DEBUG
            Section {
                Toggle(isOn: $proManager.debugProEnabled) {
                    settingsRow(icon: "ladybug.fill", color: .hlError, title: "Debug Pro")
                }
                .tint(.hlPrimary)
            } header: {
                Text("Developer")
            } footer: {
                Text("Toggle Pro access for testing. Only visible in debug builds.")
            }
            #endif

            Section {
                VStack(spacing: HLSpacing.xxs) {
                    Text("HabitLand")
                        .font(HLFont.subheadline(.semibold))
                        .foregroundColor(.hlTextPrimary)
                    Text("Version 1.0.0 (Build 1)")
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)
                    Text("Made with 💚")
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .hlSheetContent()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
                .hlSheetContent()
        }
        .sheet(isPresented: $showTerms) {
            TermsOfUseView()
                .hlSheetContent()
        }
    }

    private func settingsRow(icon: String, color: Color, title: String) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: min(settingsIconSize, 18)))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(color)
                .cornerRadius(HLRadius.xs)

            Text(title)
                .font(HLFont.body())
                .foregroundColor(.hlTextPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        GeneralSettingsView()
    }
}
