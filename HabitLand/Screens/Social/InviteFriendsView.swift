import SwiftUI
import SwiftData
import CloudKit

struct InviteFriendsView: View {
    @ScaledMetric(relativeTo: .title) private var giftIconSize: CGFloat = 40
    @ScaledMetric(relativeTo: .caption) private var closeIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var chevronSize: CGFloat = 14
    @ScaledMetric(relativeTo: .footnote) private var iconSize: CGFloat = 16
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }

    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var searchResults: [CKRecord] = []
    @State private var sentRequests: Set<String> = []
    @State private var isSearching = false
    @State private var referralStats: (count: Int, weeksEarned: Int) = (0, 0)
    @State private var showCopiedToast = false
    @StateObject private var cloudKit = CloudKitManager.shared
    @Environment(\.dismiss) private var dismiss

    private let appStoreURL = "https://apps.apple.com/app/habitland/id6744066498"
    private static let fallbackURL: URL = {
        guard let url = URL(string: "https://apps.apple.com") else {
            return URL(fileURLWithPath: "/")
        }
        return url
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    referralCodeSection
                    referralStatsSection
                    searchSection
                    if !searchResults.isEmpty {
                        resultsSection
                    }
                    if searchResults.isEmpty && !isSearching && searchText.isEmpty {
                        if let profile = profile, profile.referredByCode == nil {
                            redeemCodeSection
                        }
                        benefitsSection
                    }
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.md)
            }
            .background(Color.hlBackground)
            .navigationTitle("Invite Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlPrimary)
                }
            }
            .overlay(alignment: .top) {
                if showCopiedToast {
                    Text(isTurkish ? "Kopyalandı!" : "Copied!")
                        .font(HLFont.caption(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, HLSpacing.md)
                        .padding(.vertical, HLSpacing.xs)
                        .background(Color.hlSuccess)
                        .clipShape(Capsule())
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, HLSpacing.sm)
                }
            }
            .task {
                await ensureReferralCode()
                await loadReferralStats()
            }
        }
    }

    // MARK: - Referral Code Section

    private var referralCodeSection: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: HLIcon.gift)
                .font(.system(size: min(giftIconSize, 48)))
                .foregroundColor(.hlPrimary)
                .frame(width: 80, height: 80)
                .background(Color.hlPrimaryLight)
                .clipShape(Circle())

            Text("Invite Friends")
                .font(HLFont.title3())
                .foregroundColor(.hlTextPrimary)

            Text(isTurkish ? "Kodunu paylaş, ikimiz de 1 hafta Pro kazanalım!" : "Share your code, we both get 1 week of Pro!")
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)

            // Referral code display — tap to copy
            if let profile = profile, !profile.displayReferralCode.isEmpty {
                Button {
                    UIPasteboard.general.string = profile.displayReferralCode
                    HLHaptics.success()
                    withAnimation(HLAnimation.quick) {
                        showCopiedToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(HLAnimation.quick) {
                            showCopiedToast = false
                        }
                    }
                } label: {
                    HStack(spacing: HLSpacing.xs) {
                        Text(profile.displayReferralCode)
                            .font(HLFont.title1(.bold))
                            .foregroundColor(.hlPrimary)
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: min(iconSize, 20)))
                            .foregroundColor(.hlTextTertiary)
                    }
                    .padding(.vertical, HLSpacing.sm)
                    .padding(.horizontal, HLSpacing.lg)
                    .background(Color.hlPrimaryLight)
                    .cornerRadius(HLRadius.md)
                }
            }

            // ShareLink with localized message
            ShareLink(
                item: URL(string: appStoreURL) ?? Self.fallbackURL,
                subject: Text(isTurkish ? "HabitLand'e Katil!" : "Join HabitLand!"),
                message: Text(shareMessage)
            ) {
                HStack {
                    Image(systemName: HLIcon.share)
                    Text(isTurkish ? "Davet Linkini Paylas" : "Share Invite Link")
                }
                .font(HLFont.headline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.sm)
                .background(Color.hlPrimary)
                .cornerRadius(HLRadius.md)
            }
        }
        .hlCard()
    }

    // MARK: - Referral Stats Section

    private var referralStatsSection: some View {
        HStack(spacing: HLSpacing.md) {
            statItem(
                icon: "person.2.fill",
                value: "\(referralStats.count)",
                label: isTurkish ? "Davet Edilen" : "Friends Invited"
            )

            Divider()
                .frame(height: 40)

            statItem(
                icon: "crown.fill",
                value: "\(referralStats.weeksEarned)",
                label: isTurkish ? "Hafta Pro" : "Weeks Pro"
            )
        }
        .hlCard()
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            HStack(spacing: HLSpacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: min(chevronSize, 18)))
                    .foregroundColor(.hlPrimary)
                Text(value)
                    .font(HLFont.title2(.bold))
                    .foregroundColor(.hlTextPrimary)
            }
            Text(label)
                .font(HLFont.caption())
                .foregroundColor(.hlTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Redeem Code Section

    private var redeemCodeSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "gift.fill")
                    .foregroundStyle(Color.hlGold)
                Text(isTurkish ? "Davet Kodun Var Mi?" : "Got an Invite Code?")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
            }

            if let profile = profile {
                ReferralCodeEntryView(profile: profile) {
                    HLHaptics.success()
                }
            }
        }
        .hlCard()
    }

    // MARK: - Search Section

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text(isTurkish ? "Kullanici Ara" : "Find by Username")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            HStack(spacing: HLSpacing.xs) {
                Image(systemName: HLIcon.search)
                    .foregroundColor(.hlTextTertiary)
                TextField(isTurkish ? "Kullanici adi girin..." : "Enter username...", text: $searchText)
                    .font(HLFont.body())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit { performSearch() }
                    .onChange(of: searchText) { _, newValue in
                        if newValue.count >= 2 {
                            performSearch()
                        } else {
                            searchResults = []
                        }
                    }

                if isSearching {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                    } label: {
                        Image(systemName: HLIcon.close)
                            .foregroundColor(.hlTextTertiary)
                            .font(.system(size: min(closeIconSize, 16), weight: .bold))
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(HLSpacing.sm)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .stroke(Color.hlDivider, lineWidth: 1)
            )
        }
        .hlCard()
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")")
                .font(HLFont.caption())
                .foregroundColor(.hlTextTertiary)

            ForEach(searchResults, id: \.recordID) { record in
                userResultRow(record)
            }
        }
    }

    private func userResultRow(_ record: CKRecord) -> some View {
        let name = record["name"] as? String ?? "Unknown"
        let username = record["username"] as? String ?? ""
        let emoji = record["avatarEmoji"] as? String ?? "😊"
        let level = record["level"] as? Int ?? 1
        let recordName = record.recordID.recordName
        let alreadySent = sentRequests.contains(recordName)

        return HStack(spacing: HLSpacing.sm) {
            AvatarView(name: name, size: 48)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                HStack(spacing: HLSpacing.xs) {
                    Text(name)
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)

                    Text("Lv.\(level)")
                        .font(HLFont.caption2(.bold))
                        .foregroundColor(.hlPrimary)
                        .padding(.horizontal, HLSpacing.xs)
                        .padding(.vertical, HLSpacing.xxxs)
                        .background(Color.hlPrimaryLight)
                        .cornerRadius(HLRadius.full)
                }

                Text(username)
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            Spacer()

            Button {
                Task {
                    let success = await cloudKit.sendFriendRequest(to: recordName)
                    if success {
                        sentRequests.insert(recordName)
                        HLHaptics.success()
                    }
                }
            } label: {
                if alreadySent {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: "checkmark")
                        Text("Sent")
                    }
                    .font(HLFont.caption(.semibold))
                    .foregroundStyle(Color.hlSuccess)
                    .padding(.horizontal, HLSpacing.sm)
                    .padding(.vertical, HLSpacing.xxs)
                    .background(Color.hlSuccess.opacity(0.12))
                    .cornerRadius(HLRadius.full)
                } else {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: HLIcon.personAdd)
                        Text("Add")
                    }
                    .font(HLFont.caption(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, HLSpacing.sm)
                    .padding(.vertical, HLSpacing.xxs)
                    .background(Color.hlPrimary)
                    .cornerRadius(HLRadius.full)
                }
            }
            .disabled(alreadySent)
        }
        .hlCard()
    }

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text(isTurkish ? "Neden Arkadaslarini Davet Et?" : "Why Invite Friends?")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            benefitRow(icon: "crown.fill", color: .hlGold, title: isTurkish ? "Ucretsiz Pro Kazan" : "Earn Free Pro", subtitle: isTurkish ? "Her davet icin 1 hafta Pro kazan" : "Get 1 week of Pro for each invite")
            benefitRow(icon: "chart.line.uptrend.xyaxis", color: .hlPrimary, title: isTurkish ? "%65 Daha Tutarli" : "65% More Consistent", subtitle: isTurkish ? "Birlikte takip etmek basariyi arttirir" : "Accountability partners boost habit success rates")
            benefitRow(icon: "trophy.fill", color: .hlFlame, title: isTurkish ? "Ortak Challenge'lar" : "Shared Challenges", subtitle: isTurkish ? "Arkadaslarinla yarismaya basla" : "Compete and motivate each other with challenges")
            benefitRow(icon: "hand.wave.fill", color: .hlInfo, title: isTurkish ? "Durtme Destegi" : "Nudge Support", subtitle: isTurkish ? "Geride kalanlar icin dost eli uzat" : "Give friends a friendly push when they're falling behind")
        }
        .hlCard()
    }

    private func benefitRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: min(iconSize, 20)))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(title)
                    .font(HLFont.subheadline(.semibold))
                    .foregroundColor(.hlTextPrimary)
                Text(subtitle)
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }
        }
    }

    // MARK: - Helpers

    private var isTurkish: Bool {
        Locale.current.language.languageCode == .turkish
    }

    private var shareMessage: String {
        let displayCode = profile?.displayReferralCode ?? "HBT-XXXXXX"
        if isTurkish {
            return "Aliskanliklarini birlikte takip edelim! HabitLand'i indir ve kodumu gir: \(displayCode) -- ikimiz de 1 hafta Pro kazanalim! \(appStoreURL)"
        } else {
            return "Let's track habits together! Download HabitLand and enter my code: \(displayCode) -- we both get 1 week of Pro! \(appStoreURL)"
        }
    }

    // MARK: - Data Loading

    private func ensureReferralCode() async {
        guard let profile = profile, profile.referralCode == nil else { return }
        profile.referralCode = UserProfile.generateReferralCode(from: profile.id)
        try? modelContext.save()
    }

    private func loadReferralStats() async {
        guard let code = profile?.referralCode else { return }
        let count = await cloudKit.fetchReferralCount(forCode: code)
        await MainActor.run {
            referralStats = (count: count, weeksEarned: count)
        }
    }

    // MARK: - Search

    private func performSearch() {
        isSearching = true
        Task {
            searchResults = await cloudKit.searchUsers(username: searchText)
            isSearching = false
        }
    }
}

#Preview {
    InviteFriendsView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
