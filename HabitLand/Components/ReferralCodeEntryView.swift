import SwiftUI
import SwiftData

// MARK: - Referral Code Entry View

struct ReferralCodeEntryView: View {
    @Bindable var profile: UserProfile
    var onRedeemed: (() -> Void)?

    @ObservedObject private var cloudKit = CloudKitManager.shared
    @ObservedObject private var proManager = ProManager.shared

    @State private var codeInput = ""
    @State private var isRedeeming = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: HLSpacing.md) {
            if showSuccess {
                successView
            } else {
                codeEntryView
            }
        }
        .animation(HLAnimation.quick, value: showSuccess)
    }

    // MARK: - Code Entry

    private var codeEntryView: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "gift.fill")
                    .foregroundStyle(Color.hlPrimary)
                Text("Davet Kodu Gir") // Enter Referral Code
                    .font(HLFont.headline())
            }

            TextField("HBT-XXXXXX", text: $codeInput)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(HLFont.title3(.bold))
                .multilineTextAlignment(.center)
                .padding(HLSpacing.sm)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: HLRadius.md))
                .focused($isFocused)

            if let error = errorMessage {
                Text(error)
                    .font(HLFont.footnote())
                    .foregroundStyle(Color.hlError)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Button {
                Task { await redeemCode() }
            } label: {
                HStack(spacing: HLSpacing.xs) {
                    if isRedeeming {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    Text("Kodu Kullan") // Redeem Code
                        .font(HLFont.headline())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.sm)
                .background(codeInput.count >= 6 ? Color.hlPrimary : Color.gray.opacity(0.3))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: HLRadius.md))
            }
            .disabled(isRedeeming || codeInput.count < 6)

            if profile.referredByCode != nil {
                Text("Zaten bir davet kodu kullandiniz") // Already used a referral code
                    .font(HLFont.caption())
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.hlPrimary)

            Text("Tebrikler!") // Congratulations!
                .font(HLFont.title2())

            Text("7 gun ucretsiz Pro kazandiniz!") // You earned 7 days free Pro!
                .font(HLFont.body())
                .foregroundStyle(.secondary)

            Button {
                onRedeemed?()
            } label: {
                Text("Tamam") // OK
                    .font(HLFont.headline())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.sm)
                    .background(Color.hlPrimary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: HLRadius.md))
            }
        }
        .padding(HLSpacing.md)
    }

    // MARK: - Redeem Logic

    private func redeemCode() async {
        errorMessage = nil

        // Strip prefix and uppercase
        var code = codeInput.uppercased()
        if code.hasPrefix("HBT-") {
            code = String(code.dropFirst(4))
        }

        // Validate length
        guard code.count == 6 else {
            errorMessage = "Gecersiz kod" // Invalid code
            return
        }

        // Self-referral check
        if code == profile.referralCode {
            errorMessage = "Kendi kodunuzu kullanamazsiniz" // Can't use own code
            return
        }

        // One-redemption check (local)
        if profile.referredByCode != nil {
            errorMessage = "Bu kodu zaten kullandiniz" // Already redeemed
            return
        }

        // iCloud availability check
        guard cloudKit.iCloudAvailable else {
            errorMessage = "iCloud baglantisi gerekli" // iCloud connection required
            return
        }

        isRedeeming = true
        defer { isRedeeming = false }

        // One-redemption check (CloudKit)
        guard let userID = cloudKit.currentUserRecordID else {
            errorMessage = "iCloud baglantisi gerekli"
            return
        }

        let alreadyRedeemed = await cloudKit.hasUserRedeemedReferral(userID: userID.recordName)
        if alreadyRedeemed {
            errorMessage = "Bu kodu zaten kullandiniz"
            return
        }

        // Save redemption to CloudKit
        let saved = await cloudKit.saveReferralRedemption(
            referrerCode: code,
            redeemerUserID: userID.recordName
        )

        guard saved else {
            errorMessage = "Bir hata olustu, tekrar deneyin" // An error occurred, try again
            return
        }

        // Grant Pro to redeemer
        profile.referredByCode = code
        proManager.extendReferralPro()

        // Haptic & success state
        HLHaptics.success()
        withAnimation(HLAnimation.celebration) {
            showSuccess = true
        }
    }
}
