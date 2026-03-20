import SwiftUI
import CloudKit

struct InviteFriendsView: View {
    @State private var searchText = ""
    @State private var searchResults: [CKRecord] = []
    @State private var sentRequests: Set<String> = []
    @State private var isSearching = false
    @StateObject private var cloudKit = CloudKitManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    searchSection
                    if !searchResults.isEmpty {
                        resultsSection
                    }
                    if searchResults.isEmpty && !isSearching && searchText.isEmpty {
                        shareLinkSection
                        benefitsSection
                    }
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.md)
            }
            .background(Color.hlBackground)
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlPrimary)
                }
            }
        }
    }

    // MARK: - Search Section

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Find by Username")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            HStack(spacing: HLSpacing.xs) {
                Image(systemName: HLIcon.search)
                    .foregroundColor(.hlTextTertiary)
                TextField("Enter username...", text: $searchText)
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
                            .font(.system(size: 12, weight: .bold))
                    }
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
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 48, height: 48)
                .background(Color.hlPrimaryLight)
                .cornerRadius(HLRadius.full)

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

    // MARK: - Share Link

    private var shareLinkSection: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: HLIcon.personAdd)
                .font(.system(size: 40))
                .foregroundColor(.hlPrimary)
                .frame(width: 80, height: 80)
                .background(Color.hlPrimaryLight)
                .clipShape(Circle())

            Text("Invite Your Friends")
                .font(HLFont.title3())
                .foregroundColor(.hlTextPrimary)

            Text("Build habits together and hold each other accountable")
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)

            ShareLink(
                item: URL(string: "https://apps.apple.com/app/habitland/id000000000")!,
                subject: Text("Join me on HabitLand!"),
                message: Text("Let's build habits together! Download HabitLand and add me as a friend.")
            ) {
                HStack {
                    Image(systemName: HLIcon.share)
                    Text("Share Invite Link")
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

    // MARK: - Benefits

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Why Add Friends?")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            benefitRow(icon: "chart.line.uptrend.xyaxis", color: .hlPrimary, title: "65% More Consistent", subtitle: "Accountability partners boost habit success rates")
            benefitRow(icon: "trophy.fill", color: .hlGold, title: "Shared Challenges", subtitle: "Compete and motivate each other with challenges")
            benefitRow(icon: "hand.wave.fill", color: .hlFlame, title: "Nudge Support", subtitle: "Give friends a friendly push when they're falling behind")
            benefitRow(icon: "star.fill", color: .hlInfo, title: "Bonus XP", subtitle: "Earn extra XP for completing habits with friends")
        }
        .hlCard()
    }

    private func benefitRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
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
}
