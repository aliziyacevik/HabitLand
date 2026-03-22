import Foundation
import os
import StoreKit
import SwiftUI

@MainActor
final class ProManager: ObservableObject {
    static let shared = ProManager()

    // Product IDs — must match App Store Connect / StoreKit config
    static let yearlyID = "com.habitland.pro.yearly"
    static let lifetimeID = "com.habitland.pro.lifetime"

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false

    // MARK: - Referral Pro
    @Published var referralProExpiresAt: Date?

    /// Debug override — only works in DEBUG builds
    #if DEBUG
    @Published var debugProEnabled = false
    #endif

    var isPro: Bool {
        #if DEBUG
        if debugProEnabled { return true }
        if ProcessInfo.processInfo.arguments.contains("-screenshotMode") { return true }
        #endif
        if let expiresAt = referralProExpiresAt, expiresAt > Date.now {
            return true
        }
        return !purchasedProductIDs.isEmpty
    }

    var currentPlanDisplay: (name: String, icon: String) {
        if purchasedProductIDs.contains(Self.lifetimeID) {
            return ("Pro (Lifetime)", "crown.fill")
        } else if purchasedProductIDs.contains(Self.yearlyID) {
            return ("Pro (Yearly)", "crown.fill")
        } else if let expiresAt = referralProExpiresAt, expiresAt > Date.now {
            let days = Calendar.current.dateComponents([.day], from: Date.now, to: expiresAt).day ?? 0
            return ("Pro (Referral - \(days)d left)", "gift.fill")
        }
        #if DEBUG
        if debugProEnabled || ProcessInfo.processInfo.arguments.contains("-screenshotMode") {
            return ("Pro (Debug)", "crown.fill")
        }
        #endif
        return ("Free Plan", "person.fill")
    }

    var yearlyProduct: Product? {
        products.first { $0.id == Self.yearlyID }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == Self.lifetimeID }
    }

    // MARK: - Free Trial

    @Published private(set) var isTrialEligible = false
    @Published private(set) var trialDaysRemaining: Int = 0

    /// Check if user is eligible for the free trial (never subscribed before)
    func checkTrialEligibility() async {
        guard let yearly = yearlyProduct else { return }
        if let subscription = yearly.subscription {
            isTrialEligible = await subscription.isEligibleForIntroOffer
        }
    }

    /// Free trial period text from the subscription offer
    var trialOfferText: String? {
        guard let yearly = yearlyProduct,
              let subscription = yearly.subscription,
              let introOffer = subscription.introductoryOffer else { return nil }

        switch introOffer.period.unit {
        case .day: return "\(introOffer.period.value)-day free trial"
        case .week: return "\(introOffer.period.value)-week free trial"
        case .month: return "\(introOffer.period.value)-month free trial"
        case .year: return "\(introOffer.period.value)-year free trial"
        @unknown default: return "Free trial"
        }
    }

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        referralProExpiresAt = UserDefaults.standard.object(forKey: "referralProExpiresAt") as? Date
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
    }

    // MARK: - Referral Pro Extension

    static let maxReferralStacks = 4

    func canReceiveReferralReward(currentCount: Int) -> Bool {
        currentCount < Self.maxReferralStacks
    }

    func extendReferralPro(days: Int = 7, referralCount: Int = 0) {
        if referralCount >= Self.maxReferralStacks { return }
        let baseDate = referralProExpiresAt ?? Date.now
        let startDate = max(baseDate, Date.now)
        referralProExpiresAt = Calendar.current.date(byAdding: .day, value: days, to: startDate)
        UserDefaults.standard.set(referralProExpiresAt, forKey: "referralProExpiresAt")
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        guard products.isEmpty else { return }
        do {
            let storeProducts = try await Product.products(for: [Self.yearlyID, Self.lifetimeID])
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            HLLogger.storekit.error("Failed to load products: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }

    // MARK: - Promo Code

    @discardableResult
    func redeemPromoCode() async -> Bool {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first else { return false }
        do {
            try await AppStore.presentOfferCodeRedeemSheet(in: windowScene)
            await updatePurchasedProducts()
            return true
        } catch {
            HLLogger.storekit.error("Promo code redemption failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    // MARK: - Transaction Updates

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerifiedAsync(result)
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                } catch {
                    HLLogger.storekit.error("Transaction verification failed: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    nonisolated private func checkVerifiedAsync<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let value):
            return value
        }
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            }
        }

        purchasedProductIDs = purchased
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let value):
            return value
        }
    }

    // MARK: - Free Tier Limits

    static let freeHabitLimit = 5
    static let freeAchievementLimit = 5

    func canCreateHabit(currentCount: Int) -> Bool {
        isPro || currentCount < Self.freeHabitLimit
    }
}

// MARK: - Paywall Context

enum PaywallContext {
    case habitLimit
    case sleepTracking
    case socialFeatures
    case achievements

    var title: String {
        switch self {
        case .habitLimit: return "Unlock Unlimited Habits"
        case .sleepTracking: return "Unlock Sleep Tracking"
        case .socialFeatures: return "Unlock Social Features"
        case .achievements: return "Unlock All Achievements"
        }
    }

    var icon: String {
        switch self {
        case .habitLimit: return "infinity"
        case .sleepTracking: return "moon.fill"
        case .socialFeatures: return "person.2.fill"
        case .achievements: return "trophy.fill"
        }
    }

    var description: String {
        switch self {
        case .habitLimit: return "You've been tracking 3 habits — unlock unlimited to keep growing"
        case .sleepTracking: return "Track and improve your sleep patterns with detailed analytics"
        case .socialFeatures: return "Connect with friends, join challenges, and climb the leaderboard"
        case .achievements: return "Unlock all 20+ achievements and showcase your progress"
        }
    }
}

enum StoreError: Error {
    case verificationFailed
}
