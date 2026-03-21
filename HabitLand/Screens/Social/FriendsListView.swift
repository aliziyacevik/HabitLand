import SwiftUI
import SwiftData

// MARK: - FriendsListView

struct FriendsListView: View {
    @Query(sort: \Friend.name) private var friends: [Friend]
    @State private var searchText = ""
    @State private var showAddFriends = false

    private var filteredFriends: [Friend] {
        if searchText.isEmpty { return friends }
        return friends.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hlBackground.ignoresSafeArea()

                if friends.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: HLSpacing.md) {
                            searchBar

                            addFriendsButton

                            LazyVStack(spacing: HLSpacing.sm) {
                                ForEach(Array(filteredFriends.enumerated()), id: \.element.id) { index, friend in
                                    NavigationLink {
                                        FriendProfileView(friend: friend)
                                    } label: {
                                        friendRow(friend)
                                    }
                                    .buttonStyle(HLCardPressStyle())
                                    .hlStaggeredAppear(index: index)
                                }
                            }
                        }
                        .padding(.horizontal, HLSpacing.md)
                        .padding(.top, HLSpacing.sm)
                        .padding(.bottom, HLSpacing.xxxl)
                    }
                }
            }
            .navigationTitle("Friends")
            .sheet(isPresented: $showAddFriends) {
                InviteFriendsView()
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: HLIcon.search)
                .foregroundColor(.hlTextTertiary)
                .font(.system(size: 16))

            TextField("Search friends...", text: $searchText)
                .font(HLFont.body())
                .foregroundColor(.hlTextPrimary)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
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
                .stroke(Color.hlCardBorder, lineWidth: 1)
        )
    }

    // MARK: - Add Friends Button

    private var addFriendsButton: some View {
        Button {
            showAddFriends = true
        } label: {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: HLIcon.personAdd)
                    .font(.system(size: 16, weight: .semibold))
                Text("Add Friends")
                    .font(HLFont.headline())
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.hlTextTertiary)
            }
            .foregroundColor(.hlPrimary)
            .hlCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Friend Row

    private func friendRow(_ friend: Friend) -> some View {
        HStack(spacing: HLSpacing.sm) {
            // Avatar
            AvatarView(name: friend.name, size: 48)

            // Info
            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                HStack(spacing: HLSpacing.xs) {
                    Text(friend.name)
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)

                    levelBadge(friend.level)
                }

                HStack(spacing: HLSpacing.md) {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: HLIcon.flame)
                            .font(.system(size: 12))
                            .foregroundColor(.hlFlame)
                        Text("\(friend.currentStreak)d")
                            .font(HLFont.caption(.medium))
                            .foregroundColor(.hlTextSecondary)
                    }

                    Text(friend.addedAt, style: .relative)
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.hlTextTertiary)
        }
        .hlCard()
    }

    // MARK: - Level Badge

    private func levelBadge(_ level: Int) -> some View {
        Text("Lv.\(level)")
            .font(HLFont.caption2(.bold))
            .foregroundColor(.hlPrimary)
            .padding(.horizontal, HLSpacing.xs)
            .padding(.vertical, HLSpacing.xxxs)
            .background(Color.hlPrimaryLight)
            .cornerRadius(HLRadius.full)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.lg) {
            Text("\u{1F44B}")
                .font(.system(size: 64))

            Text("No Friends Yet")
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text("Add friends to stay motivated together,\nshare challenges, and climb the leaderboard!")
                .font(HLFont.body())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                showAddFriends = true
            } label: {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: HLIcon.personAdd)
                    Text("Add Friends")
                }
                .font(HLFont.headline())
                .foregroundColor(.white)
                .padding(.horizontal, HLSpacing.xl)
                .padding(.vertical, HLSpacing.sm)
                .background(Color.hlPrimary)
                .cornerRadius(HLRadius.full)
            }
        }
        .padding(HLSpacing.xl)
    }
}

// MARK: - Preview

#Preview {
    FriendsListView()
        .modelContainer(for: Friend.self, inMemory: true)
}
