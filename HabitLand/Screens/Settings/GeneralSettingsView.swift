import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject private var proManager = ProManager.shared
    @ObservedObject private var healthKitManager = HealthKitManager.shared
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
                NavigationLink(destination: EditProfileView()) {
                    settingsRow(icon: "person.fill", color: .hlPrimary, title: "Edit Profile")
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
