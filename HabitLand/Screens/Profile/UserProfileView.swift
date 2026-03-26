import SwiftUI
import SwiftData

struct UserProfileView: View {
    @ScaledMetric(relativeTo: .caption) private var xpStarSize: CGFloat = 10
    @ScaledMetric(relativeTo: .caption) private var starIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .caption) private var chevronSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var linkIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var achievementIconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .title3) private var shieldIconSize: CGFloat = 24
    @Query private var profiles: [UserProfile]
    @Query(filter: #Predicate<Achievement> { $0.isUnlocked }) private var unlockedAchievements: [Achievement]
    @Query private var habits: [Habit]

    @State private var showEditProfile = false

    private var profile: UserProfile? { profiles.first }

    private var daysActive: Int {
        let allDates = Set(habits.flatMap { habit in
            habit.safeCompletions.filter(\.isCompleted).map { Calendar.current.startOfDay(for: $0.date) }
        })
        return allDates.count
    }

    private var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.totalCompletions }
    }

    private var longestStreak: Int {
        habits.map(\.bestStreak).max() ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HLSpacing.md) {
                    profileHeader
                        .hlStaggeredAppear(index: 0)
                    statsRow
                        .hlStaggeredAppear(index: 1)
                    achievementsSection
                        .hlStaggeredAppear(index: 2)
                    quickLinksSection
                        .hlStaggeredAppear(index: 3)
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.md)
                .hlAdaptiveWidth()
            }
            .refreshable {
                try? await Task.sleep(for: .milliseconds(300))
            }
            .background(Color.hlBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: GeneralSettingsView()) {
                        Image(systemName: HLIcon.settings)
                            .foregroundColor(.hlTextSecondary)
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: HLSpacing.md) {
            AvatarView(name: profile?.name ?? "User", size: 96, avatarType: profile?.avatarType ?? .initial)

            VStack(spacing: HLSpacing.xxs) {
                Text(profile?.name ?? "New User")
                    .font(HLFont.title2())
                    .foregroundColor(.hlTextPrimary)

                Text("@\(profile?.username ?? "user")")
                    .font(HLFont.subheadline())
                    .foregroundColor(.hlTextSecondary)

                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: HLIcon.star)
                        .font(.system(size: min(starIconSize, 16)))
                        .foregroundColor(.hlPrimary)
                        .accessibilityHidden(true)
                    Text("Level \(profile?.level ?? 1) · \(profile?.levelTitle ?? "Seedling")")
                        .font(HLFont.caption(.semibold))
                        .foregroundColor(.hlPrimary)
                }
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xxs)
                .background(Color.hlPrimaryLight)
                .cornerRadius(HLRadius.full)
            }

            NavigationLink(destination: EditProfileView()) {
                Text("Edit Profile")
                    .font(HLFont.subheadline(.medium))
                    .foregroundColor(.hlPrimary)
                    .padding(.horizontal, HLSpacing.lg)
                    .padding(.vertical, HLSpacing.xs)
                    .overlay(
                        RoundedRectangle(cornerRadius: HLRadius.full)
                            .stroke(Color.hlPrimary, lineWidth: 1.5)
                    )
            }
        }
        .hlCard()
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var statsRow: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: HLSpacing.sm))
            : AnyLayout(HStackLayout(spacing: HLSpacing.sm))

        return layout {
            statCard(value: "\(daysActive)", label: "Days Active", icon: HLIcon.calendar)
            statCard(value: "\(totalCompletions)", label: "Completions", icon: HLIcon.checkmark)
            statCard(value: "\(longestStreak)", label: "Streak", icon: HLIcon.flame)
            statCard(value: "\(profile?.level ?? 1)", label: "Level", icon: HLIcon.star)
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: HLSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: min(linkIconSize, 20)))
                .foregroundColor(.hlPrimary)
                .accessibilityHidden(true)

            Text(value)
                .font(HLFont.title3())
                .foregroundColor(.hlTextPrimary)
                .minimumScaleFactor(0.75)

            Text(label)
                .font(HLFont.caption2())
                .foregroundColor(.hlTextTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
        .hlCard(padding: HLSpacing.sm)
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            SectionHeader("Achievements", actionTitle: "See All") {
                // Navigate to all achievements
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.sm) {
                    ForEach(unlockedAchievements) { achievement in
                        achievementItem(
                            icon: achievement.icon,
                            name: achievement.name,
                            color: colorForCategory(achievement.category),
                            unlocked: true
                        )
                    }
                }
            }
        }
        .hlCard()
    }

    private func colorForCategory(_ category: AchievementCategory) -> Color {
        switch category {
        case .streak: return .hlFlame
        case .completion: return .hlGold
        case .social: return .hlInfo
        case .sleep: return .hlSleep
        case .special: return .hlGold
        }
    }

    private func achievementItem(icon: String, name: String, color: Color, unlocked: Bool) -> some View {
        VStack(spacing: HLSpacing.xs) {
            Image(systemName: unlocked ? icon : "lock.fill")
                .font(.system(size: min(achievementIconSize, 24)))
                .foregroundColor(unlocked ? color : .hlTextTertiary)
                .frame(width: 48, height: 48)
                .background(unlocked ? color.opacity(0.12) : Color.hlDivider)
                .clipShape(Circle())

            Text(name)
                .font(HLFont.caption2(.medium))
                .foregroundColor(unlocked ? .hlTextPrimary : .hlTextTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(width: 72)
    }

    // MARK: - Streak Freeze Card

    @State private var showFreezePurchaseSuccess = false

    private var streakFreezeCard: some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: "shield.fill")
                .font(.system(size: min(shieldIconSize, 28), weight: .semibold))
                .foregroundStyle(Color.hlInfo)
                .frame(width: 40)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text("Streak Shields")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Text("\(profile?.streakFreezeCount ?? 0) shields — You have \(profile?.xp ?? 0) XP")
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextSecondary)
            }

            Spacer()

            Button {
                if let profile = profile {
                    if StreakFreezeManager.shared.purchaseFreeze(profile: profile) {
                        showFreezePurchaseSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showFreezePurchaseSuccess = false
                        }
                    }
                }
            } label: {
                if showFreezePurchaseSuccess {
                    Image(systemName: "checkmark")
                        .font(HLFont.caption(.bold))
                        .foregroundStyle(Color.hlSuccess)
                } else {
                    HStack(spacing: HLSpacing.xxxs) {
                        Image(systemName: "star.fill")
                            .font(.system(size: min(xpStarSize, 14)))
                        Text("\(StreakFreezeManager.freezeCostXP)")
                    }
                    .font(HLFont.caption(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, HLSpacing.sm)
                    .padding(.vertical, HLSpacing.xxs)
                    .background(
                        (profile?.xp ?? 0) >= StreakFreezeManager.freezeCostXP
                            ? Color.hlPrimary
                            : Color.hlTextTertiary
                    )
                    .cornerRadius(HLRadius.full)
                }
            }
            .disabled((profile?.xp ?? 0) < StreakFreezeManager.freezeCostXP || (profile?.streakFreezeCount ?? 0) >= StreakFreezeManager.maxFreezeStock)
        }
        .hlCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Streak Shields, \(profile?.streakFreezeCount ?? 0) available. Costs \(StreakFreezeManager.freezeCostXP) XP to buy.")
    }

    @State private var showStatisticsPaywall = false

    private var quickLinksSection: some View {
        VStack(spacing: HLSpacing.xs) {
            if ProManager.shared.canAccessAnalytics {
                quickLink(icon: "chart.bar.fill", title: "Personal Statistics", destination: AnyView(PersonalStatisticsView()))
            } else {
                Button {
                    showStatisticsPaywall = true
                } label: {
                    HStack(spacing: HLSpacing.sm) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: min(linkIconSize, 20)))
                            .foregroundColor(.hlPrimary)
                            .frame(width: 32, height: 32)
                            .background(Color.hlPrimaryLight)
                            .cornerRadius(HLRadius.sm)
                            .accessibilityHidden(true)

                        Text("Personal Statistics")
                            .font(HLFont.body())
                            .foregroundColor(.hlTextPrimary)

                        Spacer()

                        ProBadge()

                        Image(systemName: "chevron.right")
                            .font(.system(size: min(chevronSize, 16)))
                            .foregroundColor(.hlTextTertiary)
                            .accessibilityHidden(true)
                    }
                    .hlCard(padding: HLSpacing.sm)
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showStatisticsPaywall) {
                    PaywallView(context: .analytics)
                        .hlSheetContent()
                }
            }
            quickLink(icon: "trophy.fill", title: "Achievements", destination: AnyView(AchievementsShowcaseView()))
            ShareLink(item: "Check out my profile on HabitLand! I'm Level \(profile?.level ?? 1) with a \(profile?.xp ?? 0) XP streak. Download: https://apps.apple.com/app/habitland/id6744066498") {
                quickLinkContent(icon: "square.and.arrow.up", title: "Share Profile")
            }
            .buttonStyle(.plain)
        }
    }

    private func quickLink(icon: String, title: String, destination: AnyView?) -> some View {
        Group {
            if let destination = destination {
                NavigationLink(destination: destination) {
                    quickLinkContent(icon: icon, title: title)
                }
            } else {
                Button { } label: {
                    quickLinkContent(icon: icon, title: title)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func quickLinkContent(icon: String, title: String) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: min(linkIconSize, 20)))
                .foregroundColor(.hlPrimary)
                .frame(width: 32, height: 32)
                .background(Color.hlPrimaryLight)
                .cornerRadius(HLRadius.sm)
                .accessibilityHidden(true)

            Text(title)
                .font(HLFont.body())
                .foregroundColor(.hlTextPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: min(chevronSize, 16)))
                .foregroundColor(.hlTextTertiary)
                .accessibilityHidden(true)
        }
        .hlCard(padding: HLSpacing.sm)
    }
}

#Preview {
    NavigationStack {
        UserProfileView()
            .modelContainer(for: [UserProfile.self, Achievement.self, Habit.self], inMemory: true)
    }
}
