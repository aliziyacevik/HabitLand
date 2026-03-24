import SwiftUI
import SwiftData

struct SocialFeedView: View {
    @ScaledMetric(relativeTo: .caption) private var smallIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var feedIconSize: CGFloat = 14
    @Query(sort: \Friend.name) private var friends: [Friend]
    @StateObject private var cloudKit = CloudKitManager.shared
    @State private var likedItems: Set<UUID> = []
    @State private var nudgedItems: Set<UUID> = []

    private var feedEntries: [FeedEntry] {
        friends.map { friend in
            let hash = abs(friend.id.hashValue)
            let likes = (hash % 20) + 1

            let message: String
            let detail: String?
            let detailIcon: String
            let typeIcon: String
            let typeColor: Color
            let isInactive: Bool

            // Use real data if available
            if let lastActive = friend.lastActive, Calendar.current.isDateInToday(lastActive) {
                if friend.habitsCompletedToday > 0 {
                    message = "\(friend.name) completed \(friend.habitsCompletedToday) habit\(friend.habitsCompletedToday == 1 ? "" : "s") today!"
                    detail = "\(friend.currentStreak) Day Streak"
                    detailIcon = "flame.fill"
                    typeIcon = "checkmark.circle.fill"
                    typeColor = .hlSuccess
                } else {
                    message = "\(friend.name) hasn't started their habits yet today"
                    detail = nil
                    detailIcon = ""
                    typeIcon = "clock.fill"
                    typeColor = .hlWarning
                }
                isInactive = false
            } else if friend.currentStreak > 0 {
                message = "\(friend.name) is on a \(friend.currentStreak)-day streak!"
                detail = "\(friend.currentStreak) Day Streak"
                detailIcon = "flame.fill"
                typeIcon = "flame.fill"
                typeColor = .hlFlame
                isInactive = false
            } else if friend.level >= 10 {
                message = "\(friend.name) reached Level \(friend.level)!"
                detail = "Level \(friend.level)"
                detailIcon = "star.fill"
                typeIcon = "bolt.fill"
                typeColor = .hlGold
                isInactive = false
            } else {
                message = "\(friend.name) is building great habits"
                detail = nil
                detailIcon = ""
                typeIcon = "plus.circle.fill"
                typeColor = .hlPrimary
                isInactive = friend.lastActive.map { !Calendar.current.isDateInToday($0) } ?? true
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
                streak: friend.currentStreak,
                isInactive: isInactive,
                cloudKitRecordName: friend.cloudKitRecordName
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
                AvatarView(name: item.userName, size: 40)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text(item.userName)
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)
                }

                Spacer()

                Image(systemName: item.typeIcon)
                    .font(.system(size: min(feedIconSize, 18)))
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
                        .font(.system(size: min(smallIconSize, 16)))
                        .foregroundColor(.hlPrimary)
                        .accessibilityHidden(true)
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
                            HLHaptics.light()
                        }
                    }
                } label: {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: likedItems.contains(item.id) ? "heart.fill" : "heart")
                            .foregroundColor(likedItems.contains(item.id) ? .hlError : .hlTextTertiary)
                            .scaleEffect(likedItems.contains(item.id) ? 1.2 : 1.0)
                            .animation(HLAnimation.spring, value: likedItems.contains(item.id))
                        Text(likedItems.contains(item.id) ? "\(item.likes + 1)" : "\(item.likes)")
                            .font(HLFont.caption())
                            .foregroundColor(likedItems.contains(item.id) ? .hlError : .hlTextSecondary)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(likedItems.contains(item.id) ? "Unlike, \(item.likes + 1) likes" : "Like, \(item.likes) likes")

                // Nudge button for inactive friends
                if item.isInactive, let recordName = item.cloudKitRecordName {
                    Button {
                        sendNudge(to: recordName, itemID: item.id)
                    } label: {
                        HStack(spacing: HLSpacing.xxs) {
                            Image(systemName: nudgedItems.contains(item.id) ? "hand.wave.fill" : "hand.wave")
                                .foregroundColor(nudgedItems.contains(item.id) ? .hlPrimary : .hlTextTertiary)
                            Text(nudgedItems.contains(item.id) ? "Nudged!" : "Nudge")
                                .font(HLFont.caption())
                                .foregroundColor(nudgedItems.contains(item.id) ? .hlPrimary : .hlTextSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(nudgedItems.contains(item.id))
                }

                Spacer()
            }
        }
        .hlCard()
    }

    private func sendNudge(to recordName: String, itemID: UUID) {
        Task {
            let success = await cloudKit.sendNudge(
                to: recordName,
                message: "Your friend is cheering you on! Don't break your streak!"
            )
            if success {
                withAnimation {
                    nudgedItems.insert(itemID)
                }
                HLHaptics.success()
            }
        }
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
    let isInactive: Bool
    let cloudKitRecordName: String?
}

#Preview {
    NavigationStack {
        SocialFeedView()
    }
    .modelContainer(for: Friend.self, inMemory: true)
}
