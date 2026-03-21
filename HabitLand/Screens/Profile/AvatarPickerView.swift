import SwiftUI

struct AvatarPickerView: View {
    @Binding var selectedAvatarType: AvatarType
    let userName: String
    let userLevel: Int

    @ObservedObject private var avatarStore = AvatarStoreManager.shared
    @State private var showAnimalsPurchase = false
    @State private var showFramesPurchase = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: HLSpacing.sm), count: 4)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    previewSection
                    defaultSection
                    animalsSection
                    framesSection
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.md)
            }
            .background(Color.hlBackground)
            .navigationTitle("Choose Avatar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Preview

    private var previewSection: some View {
        VStack(spacing: HLSpacing.sm) {
            AvatarView(name: userName, size: 96, avatarType: selectedAvatarType)

            Text(userName)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            Text(selectedAvatarType.displayName)
                .font(HLFont.caption())
                .foregroundColor(.hlTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .hlCard()
    }

    // MARK: - Default Section

    private var defaultSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Default")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            avatarCell(type: .initial, name: "Initial")
                .frame(width: 72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hlCard()
    }

    // MARK: - Animals Section

    private var animalsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("Animals")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                Spacer()
                Text("Pack")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            LazyVGrid(columns: columns, spacing: HLSpacing.sm) {
                ForEach(AnimalAvatar.allCases, id: \.self) { animal in
                    let type = AvatarType.animal(animal)
                    avatarCell(type: type, name: animal.displayName)
                }
            }

            if showAnimalsPurchase {
                purchaseButton(for: AvatarStoreManager.animalsPackID, label: "Unlock Animals Pack", fallbackPrice: "$0.99")
            }
        }
        .hlCard()
    }

    // MARK: - Frames Section

    private var framesSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("Frames")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                Spacer()
                Text("Pack")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            LazyVGrid(columns: columns, spacing: HLSpacing.sm) {
                ForEach(AvatarFrame.allCases, id: \.self) { frame in
                    let type = AvatarType.frame(frame)
                    avatarCell(type: type, name: frame.displayName)
                }
            }

            if showFramesPurchase {
                purchaseButton(for: AvatarStoreManager.framesPackID, label: "Unlock Frames Pack", fallbackPrice: "$1.99")
            }
        }
        .hlCard()
    }

    // MARK: - Avatar Cell

    private func avatarCell(type: AvatarType, name: String) -> some View {
        let isUnlocked = avatarStore.isAvatarUnlocked(type, userLevel: userLevel)
        let isSelected = selectedAvatarType == type

        return Button {
            if isUnlocked {
                withAnimation(HLAnimation.quick) {
                    selectedAvatarType = type
                }
            } else {
                // Show purchase prompt for the appropriate pack
                switch type {
                case .animal:
                    if let reason = avatarStore.unlockReason(type, userLevel: userLevel),
                       !reason.hasPrefix("Level") {
                        withAnimation(HLAnimation.quick) {
                            showAnimalsPurchase = true
                        }
                    }
                case .frame:
                    if let reason = avatarStore.unlockReason(type, userLevel: userLevel),
                       !reason.hasPrefix("Level") {
                        withAnimation(HLAnimation.quick) {
                            showFramesPurchase = true
                        }
                    }
                default:
                    break
                }
            }
        } label: {
            VStack(spacing: HLSpacing.xxs) {
                ZStack {
                    AvatarView(name: userName, size: 56, avatarType: type)
                        .grayscale(isUnlocked ? 0 : 1.0)

                    if !isUnlocked {
                        Circle()
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 56, height: 56)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    if isSelected && isUnlocked {
                        Circle()
                            .fill(Color.hlSuccess)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 18, y: 18)
                    }
                }

                Text(name)
                    .font(HLFont.caption2())
                    .foregroundColor(isUnlocked ? .hlTextPrimary : .hlTextTertiary)
                    .lineLimit(1)

                if !isUnlocked, let reason = avatarStore.unlockReason(type, userLevel: userLevel) {
                    Text(reason)
                        .font(HLFont.caption2(.medium))
                        .foregroundColor(.hlTextTertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Purchase Button

    private func purchaseButton(for productID: String, label: String, fallbackPrice: String) -> some View {
        let product = avatarStore.products.first { $0.id == productID }
        let price = product?.displayPrice ?? fallbackPrice

        return Button {
            guard let product else { return }
            Task {
                try? await avatarStore.purchase(product)
            }
        } label: {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text("\(label) \u{2014} \(price)")
                    .font(HLFont.headline())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.sm)
            .background(Color.hlPrimary)
            .cornerRadius(HLRadius.md)
        }
        .disabled(avatarStore.isLoading || product == nil)
        .opacity(product == nil ? 0.6 : 1.0)
    }
}

#Preview {
    AvatarPickerView(
        selectedAvatarType: .constant(.initial),
        userName: "Alex",
        userLevel: 8
    )
}
