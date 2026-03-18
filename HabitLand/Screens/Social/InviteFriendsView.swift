import SwiftUI

struct InviteFriendsView: View {
    @State private var searchText = ""
    @State private var invitedUsernames: Set<String> = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.lg) {
                shareLinkSection
                searchSection
                benefitsSection
                invitedSection
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.md)
        }
        .background(Color.hlBackground)
        .navigationTitle("Invite Friends")
        .navigationBarTitleDisplayMode(.inline)
    }

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

            VStack(spacing: HLSpacing.sm) {
                HStack {
                    Text("habitland.app/invite/abc123")
                        .font(HLFont.footnote(.medium))
                        .foregroundColor(.hlTextSecondary)
                        .lineLimit(1)

                    Spacer()

                    Button("Copy") {
                        // Copy link
                    }
                    .font(HLFont.footnote(.semibold))
                    .foregroundColor(.hlPrimary)
                }
                .padding(HLSpacing.sm)
                .background(Color.hlBackground)
                .cornerRadius(HLRadius.sm)

                Button {
                    // Share sheet
                } label: {
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
        }
        .hlCard()
    }

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

                if !searchText.isEmpty {
                    Button {
                        withAnimation {
                            invitedUsernames.insert(searchText)
                            searchText = ""
                        }
                    } label: {
                        Text("Send")
                            .font(HLFont.footnote(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, HLSpacing.sm)
                            .padding(.vertical, HLSpacing.xxs)
                            .background(Color.hlPrimary)
                            .cornerRadius(HLRadius.full)
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

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Why Invite Friends?")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            benefitRow(icon: "chart.line.uptrend.xyaxis", color: .hlPrimary, title: "65% More Consistent", subtitle: "Accountability partners boost habit success rates")
            benefitRow(icon: "trophy.fill", color: .hlGold, title: "Shared Challenges", subtitle: "Compete and motivate each other with challenges")
            benefitRow(icon: "flame.fill", color: .hlFlame, title: "Streak Support", subtitle: "Friends can encourage you when streaks are at risk")
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

    private var invitedSection: some View {
        Group {
            if !invitedUsernames.isEmpty {
                VStack(alignment: .leading, spacing: HLSpacing.sm) {
                    Text("Invitations Sent")
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)

                    ForEach(Array(invitedUsernames), id: \.self) { username in
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.hlPrimary)
                                .font(.system(size: 14))
                            Text("@\(username)")
                                .font(HLFont.subheadline())
                                .foregroundColor(.hlTextPrimary)
                            Spacer()
                            Text("Pending")
                                .font(HLFont.caption(.medium))
                                .foregroundColor(.hlWarning)
                                .padding(.horizontal, HLSpacing.xs)
                                .padding(.vertical, HLSpacing.xxxs)
                                .background(Color.hlWarning.opacity(0.12))
                                .cornerRadius(HLRadius.xs)
                        }
                        .padding(.vertical, HLSpacing.xxs)
                    }
                }
                .hlCard()
            }
        }
    }
}

#Preview {
    NavigationStack {
        InviteFriendsView()
    }
}
