import SwiftUI
import SwiftData

// MARK: - FriendProfileView

struct FriendProfileView: View {
    @ScaledMetric(relativeTo: .caption) private var starIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var actionIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .footnote) private var statIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var challengeIconSize: CGFloat = 18
    let friend: Friend

    @Query(sort: \Challenge.name) private var challenges: [Challenge]
    @Query(sort: \Achievement.name) private var achievements: [Achievement]
    @StateObject private var cloudKit = CloudKitManager.shared

    @State private var showNudgeSent = false
    @State private var showChallengeCreate = false

    private var sharedChallenges: [Challenge] {
        challenges.filter(\.isActive)
    }

    private var unlockedAchievements: [Achievement] {
        achievements.filter(\.isUnlocked)
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    profileHeader
                    statsRow
                    activityStatus
                    actionButtons

                    if !sharedChallenges.isEmpty {
                        sharedChallengesSection
                    }
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.top, HLSpacing.sm)
                .padding(.bottom, HLSpacing.xxxl)
            }
        }
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if showNudgeSent {
                nudgeSentOverlay
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: HLSpacing.sm) {
            AvatarView(name: friend.name, size: 100, avatarType: friend.avatarType)

            Text(friend.name)
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text(friend.username)
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)

            levelBadge
        }
        .frame(maxWidth: .infinity)
        .hlCard()
    }

    private var levelBadge: some View {
        HStack(spacing: HLSpacing.xxs) {
            Image(systemName: HLIcon.star)
                .font(.system(size: min(starIconSize, 16)))
            Text("Level \(friend.level) \(levelTitle)")
                .font(HLFont.caption(.bold))
        }
        .foregroundColor(.hlPrimary)
        .padding(.horizontal, HLSpacing.sm)
        .padding(.vertical, HLSpacing.xxs)
        .background(Color.hlPrimaryLight)
        .cornerRadius(HLRadius.full)
    }

    private var levelTitle: String {
        switch friend.level {
        case 1...5: return "Seedling"
        case 6...10: return "Sprout"
        case 11...20: return "Sapling"
        case 21...35: return "Tree"
        case 36...50: return "Forest"
        default: return "Legend"
        }
    }

    // MARK: - Stats Row

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var statsRow: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: HLSpacing.sm) {
                    statItem(value: "\(friend.currentStreak)", label: "Day Streak", icon: HLIcon.flame, color: .hlFlame)
                    statItem(value: "\(friend.totalCompletions)", label: "Completions", icon: HLIcon.checkmark, color: .hlSuccess)
                    statItem(value: "Lvl \(friend.level)", label: "Level", icon: HLIcon.star, color: .hlPrimary)
                }
            } else {
                HStack(spacing: 0) {
                    statItem(value: "\(friend.currentStreak)", label: "Day Streak", icon: HLIcon.flame, color: .hlFlame)
                    divider
                    statItem(value: "\(friend.totalCompletions)", label: "Completions", icon: HLIcon.checkmark, color: .hlSuccess)
                    divider
                    statItem(value: "Lvl \(friend.level)", label: "Level", icon: HLIcon.star, color: .hlPrimary)
                }
            }
        }
        .hlCard()
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: min(statIconSize, 20), weight: .semibold))
                .foregroundColor(color)
                .accessibilityHidden(true)
            Text(value)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(HLFont.caption2())
                .foregroundColor(.hlTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.hlDivider)
            .frame(width: 1, height: 44)
    }

    // MARK: - Activity Status

    private var activityStatus: some View {
        HStack(spacing: HLSpacing.sm) {
            Circle()
                .fill(isActiveRecently ? Color.hlSuccess : Color.hlTextTertiary)
                .frame(width: 8, height: 8)

            if let lastActive = friend.lastActive {
                if isActiveRecently {
                    Text("Active today \u{2022} \(friend.habitsCompletedToday) habits done")
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlSuccess)
                } else {
                    Text("Last active \(lastActive, style: .relative) ago")
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlTextSecondary)
                }
            } else {
                Text("No recent activity")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, HLSpacing.sm)
        .padding(.vertical, HLSpacing.xs)
        .background(Color.hlSurface)
        .cornerRadius(HLRadius.md)
    }

    private var isActiveRecently: Bool {
        guard let lastActive = friend.lastActive else { return false }
        return Calendar.current.isDateInToday(lastActive)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: HLSpacing.sm) {
            // Nudge button
            Button {
                sendNudge()
            } label: {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: min(actionIconSize, 18), weight: .semibold))
                    Text("Nudge")
                        .font(HLFont.headline())
                }
                .foregroundColor(.hlPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.sm)
                .background(Color.hlPrimaryLight)
                .cornerRadius(HLRadius.md)
            }

            // Challenge button
            Button {
                showChallengeCreate = true
            } label: {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: HLIcon.challenge)
                        .font(.system(size: min(actionIconSize, 18), weight: .semibold))
                    Text("Challenge")
                        .font(HLFont.headline())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.sm)
                .background(Color.hlPrimary)
                .cornerRadius(HLRadius.md)
            }
        }
        .sheet(isPresented: $showChallengeCreate) {
            CreateChallengeView(inviteFriend: friend)
                .hlSheetContent()
        }
    }

    // MARK: - Shared Challenges

    private var sharedChallengesSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Shared Challenges")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(sharedChallenges) { challenge in
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: challenge.icon)
                        .font(.system(size: min(challengeIconSize, 22)))
                        .foregroundColor(.hlPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.hlPrimaryLight)
                        .cornerRadius(HLRadius.sm)

                    VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                        Text(challenge.name)
                            .font(HLFont.subheadline(.medium))
                            .foregroundColor(.hlTextPrimary)

                        ProgressView(value: challenge.progress)
                            .tint(.hlPrimary)
                    }

                    Text("\(challenge.daysRemaining)d left")
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlTextSecondary)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Nudge

    private func sendNudge() {
        guard let recordName = friend.cloudKitRecordName else { return }
        Task {
            let success = await cloudKit.sendNudge(
                to: recordName,
                message: "Hey! Don't forget your habits today! You got this!"
            )
            if success {
                HLHaptics.success()
                withAnimation(HLAnimation.spring) {
                    showNudgeSent = true
                }
                try? await Task.sleep(for: .seconds(2))
                withAnimation(HLAnimation.spring) {
                    showNudgeSent = false
                }
            }
        }
    }

    private var nudgeSentOverlay: some View {
        VStack {
            Spacer()

            HStack(spacing: HLSpacing.sm) {
                Image(systemName: "hand.wave.fill")
                    .foregroundStyle(Color.hlPrimary)
                Text("Nudge sent to \(friend.name)!")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
            }
            .padding(HLSpacing.md)
            .background(.ultraThinMaterial)
            .cornerRadius(HLRadius.lg)
            .hlShadow(HLShadow.md)
            .padding(.bottom, HLSpacing.xxxl)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FriendProfileView(
            friend: {
                let f = Friend(name: "Alex Rivera", username: "@alexr", avatarEmoji: "🦊", level: 12, currentStreak: 23)
                f.totalCompletions = 156
                f.habitsCompletedToday = 3
                f.lastActive = Date()
                return f
            }()
        )
    }
    .modelContainer(for: [Challenge.self, Achievement.self], inMemory: true)
}
