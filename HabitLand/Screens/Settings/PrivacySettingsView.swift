import SwiftUI

struct PrivacySettingsView: View {
    @AppStorage("privacy_visibility") private var profileVisibility = 1
    @AppStorage("privacy_leaderboard") private var showOnLeaderboard = true
    @AppStorage("privacy_shareStreaks") private var shareStreaks = true
    @AppStorage("privacy_shareAchievements") private var shareAchievements = true
    @AppStorage("privacy_analytics") private var analyticsCollection = true

    private let visibilityOptions = ["Public", "Friends Only", "Private"]

    var body: some View {
        List {
            Section {
                Picker("Profile Visibility", selection: $profileVisibility) {
                    ForEach(0..<visibilityOptions.count, id: \.self) { i in
                        Text(visibilityOptions[i]).tag(i)
                    }
                }
                .font(HLFont.body())
                .tint(.hlPrimary)
            } header: {
                Text("Profile")
            } footer: {
                Text("Controls who can see your profile, habits, and progress")
            }

            Section {
                Toggle(isOn: $showOnLeaderboard) {
                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text("Show on Leaderboard")
                            .font(HLFont.body())
                        Text("Appear in friend and global leaderboards")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextTertiary)
                    }
                }
                .tint(.hlPrimary)

                Toggle(isOn: $shareStreaks) {
                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text("Share Streaks")
                            .font(HLFont.body())
                        Text("Friends can see your active streaks")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextTertiary)
                    }
                }
                .tint(.hlPrimary)

                Toggle(isOn: $shareAchievements) {
                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text("Share Achievements")
                            .font(HLFont.body())
                        Text("Post achievements to the social feed")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextTertiary)
                    }
                }
                .tint(.hlPrimary)
            } header: {
                Text("Social Sharing")
            }

            Section {
                Toggle(isOn: $analyticsCollection) {
                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text("Usage Analytics")
                            .font(HLFont.body())
                        Text("Help us improve HabitLand with anonymous usage data")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextTertiary)
                    }
                }
                .tint(.hlPrimary)
            } header: {
                Text("Data Collection")
            } footer: {
                Text("We never sell your data. Analytics are fully anonymized.")
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacySettingsView()
    }
}
