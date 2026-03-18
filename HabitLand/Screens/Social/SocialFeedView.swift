import SwiftUI
import SwiftData

struct SocialFeedView: View {
    @Query(sort: \Friend.name) private var friends: [Friend]
    @State private var likedItems: Set<UUID> = []

    private var feedEntries: [FeedEntry] {
        friends.map { friend in
            let hash = abs(friend.id.hashValue)
            let likes = (hash % 20) + 1

            let message: String
            let detail: String?
            let detailIcon: String
            let typeIcon: String
            let typeColor: Color

            if friend.currentStreak > 0 {
                message = "\(friend.name) is on a \(friend.currentStreak)-day streak!"
                detail = "\(friend.currentStreak) Day Streak"
                detailIcon = "flame.fill"
                typeIcon = "flame.fill"
                typeColor = .hlFlame
            } else if friend.level >= 10 {
                message = "\(friend.name) reached Level \(friend.level)!"
                detail = "Level \(friend.level)"
                detailIcon = "star.fill"
                typeIcon = "bolt.fill"
                typeColor = .hlGold
            } else {
                message = "\(friend.name) is building great habits"
                detail = nil
                detailIcon = ""
                typeIcon = "plus.circle.fill"
                typeColor = .hlPrimary
            }

            return FeedEntry(
                id: friend.id,
                avatarEmoji: friend.avatarEmoji,
                userName: friend.name,
                message: message,
                detail: detail,
                detailIcon: detailIcon,
                typeIcon: typeIcon,
                typeColor: typeColor,
                likes: likes,
                streak: friend.currentStreak
            )
        }
        .sorted { $0.streak > $1.streak }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.md) {
                headerSection

                if friends.isEmpty {
                    EmptyStateView(
                        icon: HLIcon.social,
                        title: "No Activity Yet",
                        subtitle: "Add friends to see their achievements and progress here"
                    )
                    .padding(.top, HLSpacing.xxxl)
                } else {
                    LazyVStack(spacing: HLSpacing.sm) {
                        ForEach(feedEntries) { entry in
                            feedItemCard(entry)
                        }
                    }
                    .padding(.horizontal, HLSpacing.md)
                }
            }
            .padding(.bottom, HLSpacing.xxxl)
        }
        .background(Color.hlBackground)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Activity Feed")
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text("See what your friends are up to")
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, HLSpacing.md)
        .padding(.top, HLSpacing.md)
    }

    private func feedItemCard(_ item: FeedEntry) -> some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.sm) {
                Text(item.avatarEmoji)
                    .font(.system(size: 28))
                    .frame(width: 40, height: 40)
                    .background(Color.hlPrimaryLight)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text(item.userName)
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)
                }

                Spacer()

                Image(systemName: item.typeIcon)
                    .font(.system(size: 14))
                    .foregroundColor(item.typeColor)
                    .padding(HLSpacing.xs)
                    .background(item.typeColor.opacity(0.12))
                    .clipShape(Circle())
            }

            Text(item.message)
                .font(HLFont.body())
                .foregroundColor(.hlTextPrimary)
                .lineLimit(3)

            if let detail = item.detail {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: item.detailIcon)
                        .font(.system(size: 12))
                        .foregroundColor(.hlPrimary)
                    Text(detail)
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlPrimary)
                }
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xxs)
                .background(Color.hlPrimaryLight)
                .cornerRadius(HLRadius.sm)
            }

            HStack(spacing: HLSpacing.lg) {
                Button {
                    withAnimation(HLAnimation.spring) {
                        if likedItems.contains(item.id) {
                            likedItems.remove(item.id)
                        } else {
                            likedItems.insert(item.id)
                        }
                    }
                } label: {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: likedItems.contains(item.id) ? "heart.fill" : "heart")
                            .foregroundColor(likedItems.contains(item.id) ? .hlError : .hlTextTertiary)
                        Text(likedItems.contains(item.id) ? "\(item.likes + 1)" : "\(item.likes)")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextSecondary)
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.hlTextTertiary)
                    Text("Congrats!")
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextSecondary)
                }

                Spacer()
            }
        }
        .hlCard()
    }
}

private struct FeedEntry: Identifiable {
    let id: UUID
    let avatarEmoji: String
    let userName: String
    let message: String
    let detail: String?
    let detailIcon: String
    let typeIcon: String
    let typeColor: Color
    let likes: Int
    let streak: Int
}

#Preview {
    NavigationStack {
        SocialFeedView()
    }
    .modelContainer(for: Friend.self, inMemory: true)
}
