import Foundation
import os
import StoreKit

@MainActor
final class AvatarStoreManager: ObservableObject {
    static let shared = AvatarStoreManager()

    // Product IDs — must match App Store Connect / StoreKit config
    static let animalsPackID = "com.azc.HabitLand.avatar.animals"
    static let framesPackID = "com.azc.HabitLand.avatar.frames"

    @Published private(set) var products: [Product] = []
    @Published private(set) var animalsUnlocked: Bool
    @Published private(set) var framesUnlocked: Bool
    @Published private(set) var isLoading = false

    #if DEBUG
    @Published var debugAllUnlocked = false
    #endif

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        animalsUnlocked = UserDefaults.standard.bool(forKey: "avatarAnimalsUnlocked")
        framesUnlocked = UserDefaults.standard.bool(forKey: "avatarFramesUnlocked")
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Unlock Checks

    func isAvatarUnlocked(_ type: AvatarType, userLevel: Int) -> Bool {
        #if DEBUG
        if debugAllUnlocked { return true }
        if ProcessInfo.processInfo.arguments.contains("-screenshotMode") { return true }
        #endif

        switch type {
        case .initial:
            return true
        case .animal(let animal):
            if animalsUnlocked { return true }
            switch animal {
            case .fox: return userLevel >= 5
            case .owl: return userLevel >= 10
            default: return false
            }
        case .frame(let frame):
            if framesUnlocked { return true }
            switch frame {
            case .crown: return userLevel >= 15
            default: return false
            }
        }
    }

    func unlockReason(_ type: AvatarType, userLevel: Int) -> String? {
        if isAvatarUnlocked(type, userLevel: userLevel) { return nil }

        switch type {
        case .initial:
            return nil
        case .animal(let animal):
            switch animal {
            case .fox: return "Level 5"
            case .owl: return "Level 10"
            default:
                if let product = products.first(where: { $0.id == Self.animalsPackID }) {
                    return product.displayPrice
                }
                return "$0.99"
            }
        case .frame(let frame):
            switch frame {
            case .crown: return "Level 15"
            default:
                if let product = products.first(where: { $0.id == Self.framesPackID }) {
                    return product.displayPrice
                }
                return "$1.99"
            }
        }
    }

    // MARK: - Load Products

    func loadProducts() async {
        guard products.isEmpty else { return }
        do {
            let storeProducts = try await Product.products(for: [Self.animalsPackID, Self.framesPackID])
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            HLLogger.storekit.error("Failed to load avatar products: \(error.localizedDescription, privacy: .public)")
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

    // MARK: - Transaction Updates

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerifiedAsync(result)
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                } catch {
                    HLLogger.storekit.error("Avatar transaction verification failed: \(error.localizedDescription, privacy: .public)")
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
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.revocationDate == nil {
                    if transaction.productID == Self.animalsPackID {
                        animalsUnlocked = true
                        UserDefaults.standard.set(true, forKey: "avatarAnimalsUnlocked")
                    } else if transaction.productID == Self.framesPackID {
                        framesUnlocked = true
                        UserDefaults.standard.set(true, forKey: "avatarFramesUnlocked")
                    }
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let value):
            return value
        }
    }
}
