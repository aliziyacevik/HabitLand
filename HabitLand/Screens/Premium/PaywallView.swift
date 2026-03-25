import SwiftUI
import SwiftData
import StoreKit

struct PaywallView: View {
    @ScaledMetric(relativeTo: .body) private var featureIconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var checkIconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var giftIconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .title) private var headerIconSize: CGFloat = 36
    var context: PaywallContext? = nil
    @Environment(\.dismiss) private var dismiss
    @StateObject private var proManager = ProManager.shared
    @State private var selectedPlan: String = ProManager.lifetimeID
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var showReferralEntry = false
    @Query private var profiles: [UserProfile]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    headerSection
                    featuresSection
                    if proManager.isTrialEligible {
                        trialBanner
                    }
                    plansSection
                    purchaseButton
                    promoCodeButton
                    referralButton
                    restoreButton
                    legalSection
                }
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .task {
                await proManager.checkTrialEligibility()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .alert("Purchase Failed", isPresented: $showError) {
                Button("Try Again") {
                    Task { await handlePurchase() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(errorMessage.isEmpty ? "Check your internet connection and try again." : errorMessage)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: HLSpacing.md) {
            if let context {
                // Contextual header per D-04
                ZStack {
                    Circle()
                        .fill(Color.hlPrimary.opacity(0.12))
                        .frame(width: 80, height: 80)
                    Image(systemName: context.icon)
                        .font(.system(size: min(headerIconSize, 40)))
                        .foregroundStyle(Color.hlPrimary)
                }
                .padding(.top, HLSpacing.xl)

                Text(context.title)
                    .font(HLFont.title1(.bold))
                    .foregroundStyle(Color.hlTextPrimary)
                Text(context.description)
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HLSpacing.lg)
            } else {
                // Generic header (existing design)
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimary.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: "crown.fill")
                        .font(.system(size: min(headerIconSize, 40)))
                        .foregroundStyle(.white)
                }
                .padding(.top, HLSpacing.xl)

                Text("HabitLand Pro")
                    .font(HLFont.title1(.bold))
                    .foregroundStyle(Color.hlTextPrimary)

                Text("Build habits that actually stick")
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
            }
        }
        .padding(.bottom, HLSpacing.xl)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureRow(icon: "infinity", color: .hlPrimary, title: "Unlimited Habits", subtitle: "No limits on your growth")
            featureRow(icon: "chart.bar.fill", color: .hlInfo, title: "Advanced Analytics", subtitle: "See what's working and improve")
            featureRow(icon: "person.2.fill", color: .hlSocial, title: "Social Features", subtitle: "Stay accountable with friends")
            featureRow(icon: "moon.fill", color: .hlSleep, title: "Sleep Tracking", subtitle: "Wake up feeling your best")
            featureRow(icon: "trophy.fill", color: .hlFlame, title: "All Achievements", subtitle: "Celebrate every milestone")
            featureRow(icon: "paintpalette.fill", color: .hlMindfulness, title: "Custom Themes", subtitle: "Make the app truly yours")
        }
        .hlCard()
        .padding(.horizontal, HLSpacing.md)
        .padding(.bottom, HLSpacing.xl)
    }

    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: min(featureIconSize, 22), weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: HLRadius.sm))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HLFont.subheadline(.semibold))
                    .foregroundStyle(Color.hlTextPrimary)
                Text(subtitle)
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hlPrimary)
                .font(.system(size: min(checkIconSize, 22)))
        }
        .padding(.vertical, HLSpacing.sm)
        .padding(.horizontal, HLSpacing.md)
    }

    // MARK: - Trial Banner

    private var trialBanner: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: "gift.fill")
                .font(.system(size: min(giftIconSize, 24)))
                .foregroundStyle(Color.hlPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text(proManager.trialOfferText ?? "7-day free trial")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Text("Try all Pro features free. Cancel anytime.")
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextSecondary)
            }

            Spacer()
        }
        .padding(HLSpacing.md)
        .background(Color.hlPrimaryLight)
        .cornerRadius(HLRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .stroke(Color.hlPrimary.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, HLSpacing.md)
        .padding(.bottom, HLSpacing.md)
    }

    // MARK: - Plans

    private var plansSection: some View {
        VStack(spacing: HLSpacing.sm) {
            // Yearly — with trial if eligible
            planCard(
                id: ProManager.yearlyID,
                title: "Yearly",
                price: proManager.yearlyProduct?.displayPrice ?? "$19.99",
                subtitle: proManager.isTrialEligible
                    ? (proManager.trialOfferText ?? "7-day free trial") + ", then per year"
                    : "per year",
                badge: proManager.isTrialEligible ? "FREE TRIAL" : nil,
                isSelected: selectedPlan == ProManager.yearlyID
            )

            // Lifetime — Best Deal
            planCard(
                id: ProManager.lifetimeID,
                title: "Lifetime",
                price: proManager.lifetimeProduct?.displayPrice ?? "$39.99",
                subtitle: "One-time purchase",
                badge: "BEST DEAL",
                isSelected: selectedPlan == ProManager.lifetimeID
            )
        }
        .padding(.horizontal, HLSpacing.md)
        .padding(.bottom, HLSpacing.lg)
        .onAppear {
            // Default to yearly when trial eligible
            if proManager.isTrialEligible {
                selectedPlan = ProManager.yearlyID
            }
        }
    }

    private func planCard(id: String, title: String, price: String, subtitle: String, badge: String?, isSelected: Bool) -> some View {
        Button {
            withAnimation(HLAnimation.standard) {
                selectedPlan = id
            }
            HLHaptics.selection()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: HLSpacing.xs) {
                        Text(title)
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlTextPrimary)

                        if let badge {
                            Text(badge)
                                .font(HLFont.caption2(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, HLSpacing.xs)
                                .padding(.vertical, 2)
                                .background(
                                    LinearGradient(
                                        colors: [Color.hlFlame, Color.hlWarning],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                        }
                    }

                    Text(subtitle)
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary)
                }

                Spacer()

                Text(price)
                    .font(HLFont.title3(.bold))
                    .foregroundStyle(isSelected ? Color.hlPrimary : Color.hlTextPrimary)
            }
            .padding(HLSpacing.md)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .stroke(isSelected ? Color.hlPrimary : Color.hlCardBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            Task { await handlePurchase() }
        } label: {
            HStack(spacing: HLSpacing.xs) {
                if proManager.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(proManager.isTrialEligible && selectedPlan == ProManager.yearlyID
                         ? "Start Free Trial"
                         : "Continue")
                        .font(HLFont.headline())
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.md)
            .background(
                LinearGradient(
                    colors: [Color.hlPrimary, Color.hlPrimaryDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(HLRadius.lg)
        }
        .disabled(proManager.isLoading)
        .padding(.horizontal, HLSpacing.md)
        .padding(.bottom, HLSpacing.sm)
    }

    // MARK: - Promo Code

    private var promoCodeButton: some View {
        Button {
            Task { await proManager.redeemPromoCode() }
        } label: {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "ticket.fill")
                Text("Redeem Promo Code")
            }
            .font(HLFont.subheadline(.medium))
            .foregroundStyle(Color.hlPrimary)
        }
        .padding(.bottom, HLSpacing.xxs)
    }

    // MARK: - Referral

    private var referralButton: some View {
        Button {
            showReferralEntry = true
        } label: {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "gift.fill")
                    .accessibilityHidden(true)
                Text("Got a referral?")
            }
            .font(HLFont.subheadline())
            .foregroundStyle(Color.hlTextSecondary)
        }
        .padding(.bottom, HLSpacing.xxs)
        .sheet(isPresented: $showReferralEntry) {
            if let profile = profiles.first {
                NavigationStack {
                    ReferralCodeEntryView(profile: profile) {
                        showReferralEntry = false
                    }
                    .padding(HLSpacing.lg)
                    .navigationTitle("Enter Referral Code")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .hlSheetContent()
            }
        }
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button {
            Task { await proManager.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
        }
        .padding(.bottom, HLSpacing.md)
    }

    // MARK: - Legal

    private var legalSection: some View {
        VStack(spacing: HLSpacing.xxs) {
            Text("Payment will be charged to your Apple ID account. Yearly subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                .font(HLFont.caption2())
                .foregroundStyle(Color.hlTextTertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: HLSpacing.md) {
                Button("Terms of Use") { showTerms = true }
                    .font(HLFont.caption2())
                    .foregroundStyle(Color.hlTextSecondary)
                Button("Privacy Policy") { showPrivacy = true }
                    .font(HLFont.caption2())
                    .foregroundStyle(Color.hlTextSecondary)
            }
        }
        .padding(.horizontal, HLSpacing.lg)
        .padding(.bottom, HLSpacing.xl)
        .sheet(isPresented: $showTerms) {
            TermsOfUseView()
                .hlSheetContent()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
                .hlSheetContent()
        }
    }

    // MARK: - Actions

    private func handlePurchase() async {
        guard let product = proManager.products.first(where: { $0.id == selectedPlan }) else {
            errorMessage = "Product not available. Please try again."
            showError = true
            return
        }

        do {
            let success = try await proManager.purchase(product)
            if success {
                HLHaptics.success()
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    PaywallView()
}
