import SwiftUI
import SwiftData

struct GeneralSettingsView: View {
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }

    @ObservedObject private var proManager = ProManager.shared
    @ObservedObject private var healthKitManager = HealthKitManager.shared
    @State private var showPaywall = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showReferralEntry = false

    var body: some View {
        List {
            if !proManager.isPro {
                Section {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: HLSpacing.sm) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
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
                        .font(.system(size: 14))
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

                // Referral code entry — only shown if user hasn't redeemed a code yet
                if let profile = profile, profile.referredByCode == nil {
                    Button {
                        showReferralEntry = true
                    } label: {
                        settingsRow(icon: "gift.fill", color: .hlGold, title: "Enter Referral Code")
                    }
                }
            } header: {
                Text("Account")
            }

            Section {
                // iCloud Sync status (D-08)
                HStack {
                    settingsRow(icon: "icloud.fill", color: .blue, title: "iCloud Sync")
                    Spacer()
                    Text("Enabled")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary)
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }

                // HealthKit connection status (D-09)
                HStack {
                    settingsRow(icon: "heart.fill", color: .red, title: "Apple Health")
                    Spacer()
                    if healthKitManager.isAuthorized {
                        Text("Connected")
                            .font(HLFont.caption())
                            .foregroundStyle(Color.hlTextSecondary)
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    } else if healthKitManager.isAvailable {
                        Text("Not Connected")
                            .font(HLFont.caption())
                            .foregroundStyle(Color.hlTextTertiary)
                        Circle()
                            .fill(Color.hlTextTertiary)
                            .frame(width: 8, height: 8)
                    } else {
                        Text("Unavailable")
                            .font(HLFont.caption())
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                }
            } header: {
                Text("Connected Services")
            }

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
                NavigationLink(destination: PrivacySettingsView()) {
                    settingsRow(icon: "lock.fill", color: .hlInfo, title: "Privacy")
                }
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
                Button { showTerms = true } label: {
                    settingsRow(icon: "doc.text.fill", color: .hlTextSecondary, title: "Terms of Use")
                }
            } header: {
                Text("Legal")
            }

            Section {
                settingsRow(icon: "questionmark.circle", color: .hlTextSecondary, title: "Help Center")
                settingsRow(icon: "envelope", color: .hlTextSecondary, title: "Contact Support")
                settingsRow(icon: "star", color: .hlGold, title: "Rate HabitLand")
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
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTerms) {
            TermsOfUseView()
        }
        .sheet(isPresented: $showReferralEntry) {
            if let profile = profile {
                NavigationStack {
                    VStack(spacing: HLSpacing.lg) {
                        Spacer()
                        ReferralCodeEntryView(profile: profile) {
                            showReferralEntry = false
                        }
                        .padding(.horizontal, HLSpacing.md)
                        Spacer()
                    }
                    .background(Color.hlBackground.ignoresSafeArea())
                    .navigationTitle("Referral Code")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showReferralEntry = false
                            }
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlPrimary)
                        }
                    }
                }
            }
        }
    }

    private func settingsRow(icon: String, color: Color, title: String) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
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
