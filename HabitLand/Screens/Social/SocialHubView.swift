import SwiftUI
import SwiftData

// MARK: - Social Hub (Tab Container)

struct SocialHubView: View {
    @State private var selectedSection: SocialSection = .friends
    @StateObject private var cloudKit = CloudKitManager.shared
    @Query(sort: \Friend.name) private var friends: [Friend]
    @Environment(\.modelContext) private var modelContext
    @State private var nudges: [NudgeMessage] = []
    @State private var showNudges = false

    enum SocialSection: String, CaseIterable {
        case friends = "Friends"
        case leaderboard = "Leaderboard"
        case challenges = "Challenges"
        case feed = "Feed"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hlBackground.ignoresSafeArea()

                #if DEBUG
                let isScreenshotMode = ProcessInfo.processInfo.arguments.contains("-screenshotMode")
                #else
                let isScreenshotMode = false
                #endif
                if !cloudKit.iCloudAvailable && !isScreenshotMode {
                    iCloudUnavailableView
                } else {
                    VStack(spacing: HLSpacing.xs) {
                        sectionPicker
                            .padding(.horizontal, HLSpacing.md)
                            .padding(.top, HLSpacing.xs)

                        Group {
                            switch selectedSection {
                            case .friends:
                                FriendsListView()
                            case .leaderboard:
                                LeaderboardView()
                            case .challenges:
                                SharedChallengesView()
                            case .feed:
                                SocialFeedView()
                            }
                        }
                        .animation(HLAnimation.quick, value: selectedSection)
                    }
                }
            }
            .navigationTitle("Social")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: HLSpacing.sm) {
                        if !nudges.isEmpty {
                            Button {
                                showNudges = true
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.hlPrimary)

                                    Text("\(nudges.count)")
                                        .font(HLFont.caption2(.bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Color.hlError)
                                        .clipShape(Circle())
                                        .offset(x: 6, y: -6)
                                }
                            }
                            .accessibilityLabel("Nudges, \(nudges.count) new")
                        }
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    if !cloudKit.pendingRequests.isEmpty {
                        NavigationLink {
                            PendingRequestsView()
                        } label: {
                            HStack(spacing: HLSpacing.xxs) {
                                Image(systemName: "person.badge.clock")
                                    .font(.system(size: 14))
                                Text("\(cloudKit.pendingRequests.count)")
                                    .font(HLFont.caption(.bold))
                            }
                            .foregroundStyle(Color.hlPrimary)
                        }
                        .accessibilityLabel("Pending friend requests, \(cloudKit.pendingRequests.count)")
                    }
                }
            }
            .sheet(isPresented: $showNudges) {
                NudgesSheetView(nudges: $nudges)
                    .hlSheetContent()
            }
            .task {
                await refreshSocialData()
            }
            .refreshable {
                await refreshSocialData()
            }
        }
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(SocialSection.allCases, id: \.self) { section in
                Button {
                    withAnimation(HLAnimation.quick) {
                        selectedSection = section
                    }
                } label: {
                    Text(section.rawValue)
                        .font(HLFont.caption(.semibold))
                        .foregroundColor(selectedSection == section ? .white : .hlTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HLSpacing.xs)
                        .background(selectedSection == section ? Color.hlPrimary : Color.clear)
                        .cornerRadius(HLRadius.sm)
                }
            }
        }
        .padding(HLSpacing.xxs)
        .background(Color.hlSurface)
        .cornerRadius(HLRadius.md)
        .hlShadow(HLShadow.sm)
    }

    // MARK: - iCloud Unavailable

    private var iCloudUnavailableView: some View {
        VStack(spacing: HLSpacing.lg) {
            Image(systemName: "icloud.slash")
                .font(.system(size: 48))
                .foregroundStyle(Color.hlTextTertiary)

            Text("iCloud Required")
                .font(HLFont.title3())
                .foregroundStyle(Color.hlTextPrimary)

            Text("Sign in to iCloud in Settings to use social features.\nYour data stays private and syncs securely.")
                .font(HLFont.body())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await cloudKit.checkiCloudStatus() }
            } label: {
                Text("Retry")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlPrimary)
            }
        }
        .padding(HLSpacing.xl)
    }

    // MARK: - Refresh

    private func refreshSocialData() async {
        await cloudKit.fetchPendingRequests()
        await cloudKit.syncFriendData(friends: friends, context: modelContext)
        nudges = await cloudKit.fetchNudges()

        // Publish own profile/stats
        let profileDescriptor = FetchDescriptor<UserProfile>()
        if let profile = try? modelContext.fetch(profileDescriptor).first {
            await cloudKit.publishProfile(profile)

            let habitDescriptor = FetchDescriptor<Habit>()
            let habits = (try? modelContext.fetch(habitDescriptor)) ?? []
            let maxStreak = habits.map(\.currentStreak).max() ?? 0
            let totalCompletions = habits.reduce(0) { $0 + $1.totalCompletions }
            let todayCount = habits.filter(\.todayCompleted).count
            await cloudKit.publishStats(streak: maxStreak, totalCompletions: totalCompletions, habitsCompletedToday: todayCount)
        }
    }
}

// MARK: - Preview

#Preview {
    SocialHubView()
        .modelContainer(for: [Friend.self, UserProfile.self, Challenge.self, Habit.self], inMemory: true)
}
