import SwiftUI
import SwiftData

// MARK: - FriendsListView

struct FriendsListView: View {
    @ScaledMetric(relativeTo: .caption) private var flameIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var chevronSize: CGFloat = 14
    @ScaledMetric(relativeTo: .footnote) private var searchIconSize: CGFloat = 16
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
                .refreshable {
                    try? await Task.sleep(for: .milliseconds(300))
                }
            }
        }
        .sheet(isPresented: $showAddFriends) {
            InviteFriendsView()
                .hlSheetContent()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: HLIcon.search)
                .foregroundColor(.hlTextTertiary)
                .font(.system(size: min(searchIconSize, 20)))

            TextField("Search friends...", text: $searchText)
                .font(HLFont.body())
                .foregroundColor(.hlTextPrimary)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: HLIcon.close)
                        .foregroundColor(.hlTextTertiary)
                        .font(.system(size: min(flameIconSize, 16), weight: .bold))
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
                    .font(.system(size: min(searchIconSize, 20), weight: .semibold))
                Text("Add Friends")
                    .font(HLFont.headline())
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: min(chevronSize, 18), weight: .semibold))
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
            AvatarView(name: friend.name, size: 48, avatarType: friend.avatarType)

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
                            .font(.system(size: min(flameIconSize, 16)))
                            .foregroundColor(.hlFlame)
                            .accessibilityHidden(true)
                        Text("\(friend.currentStreak)d")
                            .font(HLFont.caption(.medium))
                            .foregroundColor(.hlTextSecondary)
                    }

                    Text(friendActivityText(friend))
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: min(flameIconSize, 16), weight: .semibold))
                .foregroundColor(.hlTextTertiary)
        }
        .hlCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(friend.name), Level \(friend.level), \(friendActivityText(friend))")
    }

    // MARK: - Friend Activity Text

    private func friendActivityText(_ friend: Friend) -> String {
        if let lastActive = friend.lastActive, Calendar.current.isDateInToday(lastActive) {
            return "Active today"
        } else if friend.currentStreak > 0 {
            return "\(friend.currentStreak)-day streak"
        } else {
            return "@\(friend.username)"
        }
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
        ScrollView {
        VStack(spacing: HLSpacing.lg) {
            Text("\u{1F44B}")
                .font(HLFont.largeTitle(.bold))

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

        // Community stats to show activity even without friends
        communityStatsCard
            .padding(.horizontal, HLSpacing.md)
        }
    }

    // MARK: - Community Stats Card

    private var communityStatsCard: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.xxs) {
                Image(systemName: "globe")
                    .font(.system(size: min(chevronSize, 18)))
                    .foregroundStyle(Color.hlPrimary)
                    .accessibilityHidden(true)
                Text("HabitLand Community")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
            }

            HStack(spacing: HLSpacing.md) {
                communityStat(value: "2,847", label: "Active Users")
                communityStat(value: "14,523", label: "Habits Today")
                communityStat(value: "892", label: "Streaks 30d+")
            }

            Text("Join the community — invite friends and climb the leaderboard together!")
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextTertiary)
                .multilineTextAlignment(.center)
        }
        .hlCard()
    }

    private func communityStat(value: String, label: String) -> some View {
        VStack(spacing: HLSpacing.xxxs) {
            Text(value)
                .font(HLFont.headline())
                .foregroundStyle(Color.hlPrimary)
            Text(label)
                .font(HLFont.caption2())
                .foregroundStyle(Color.hlTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    FriendsListView()
        .modelContainer(for: Friend.self, inMemory: true)
}
