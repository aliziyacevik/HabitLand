import SwiftUI
import SwiftData

struct PrivacySettingsView: View {
    @AppStorage("privacy_visibility") private var profileVisibility = 1
    @AppStorage("privacy_leaderboard") private var showOnLeaderboard = true
    @AppStorage("privacy_shareStreaks") private var shareStreaks = true
    @AppStorage("privacy_shareAchievements") private var shareAchievements = true
    @AppStorage("privacy_analytics") private var analyticsCollection = true

    @Environment(\.modelContext) private var modelContext
    @State private var showExportSheet = false
    @State private var exportURL: URL?
    @State private var isExporting = false
    @State private var exportFormat: ExportFormat = .csv

    private enum ExportFormat: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
    }

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
            Section {
                Picker("Format", selection: $exportFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .font(HLFont.body())
                .tint(.hlPrimary)

                Button {
                    exportData()
                } label: {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.hlPrimary)
                        }
                        Text("Export All Data")
                            .font(HLFont.body())
                            .foregroundColor(.hlPrimary)
                    }
                }
                .disabled(isExporting)

                Button(role: .destructive) {
                    // Handled by alert
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete All Data")
                            .font(HLFont.body())
                    }
                    .foregroundColor(.hlError)
                }
            } header: {
                Text("Your Data")
            } footer: {
                Text("Your data belongs to you. Export it anytime as CSV or JSON.")
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                ShareSheetView(url: url)
            }
        }
    }

    // MARK: - Export

    private func exportData() {
        isExporting = true

        Task {
            let habitsDescriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.name)])
            let sleepDescriptor = FetchDescriptor<SleepLog>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let profileDescriptor = FetchDescriptor<UserProfile>()

            let habits = (try? modelContext.fetch(habitsDescriptor)) ?? []
            let sleepLogs = (try? modelContext.fetch(sleepDescriptor)) ?? []
            let profile = try? modelContext.fetch(profileDescriptor).first

            let url: URL?
            switch exportFormat {
            case .csv:
                url = exportCSV(habits: habits, sleepLogs: sleepLogs, profile: profile)
            case .json:
                url = exportJSON(habits: habits, sleepLogs: sleepLogs, profile: profile)
            }

            await MainActor.run {
                exportURL = url
                isExporting = false
                if url != nil {
                    showExportSheet = true
                }
            }
        }
    }

    private func csvEscape(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    private func exportCSV(habits: [Habit], sleepLogs: [SleepLog], profile: UserProfile?) -> URL? {
        let dateFormatter = ISO8601DateFormatter()
        var csv = "Type,Name,Date,Value,Details\n"

        // Profile
        if let p = profile {
            csv += "Profile,\(csvEscape(p.name)),\(dateFormatter.string(from: p.joinedAt)),Level \(p.level),XP: \(p.xp)\n"
        }

        // Habits & completions
        for habit in habits {
            csv += "Habit,\(csvEscape(habit.name)),\(dateFormatter.string(from: habit.createdAt)),\(habit.currentStreak) streak,\(csvEscape(habit.category.rawValue))\n"

            for completion in habit.safeCompletions.sorted(by: { $0.date > $1.date }) {
                csv += "Completion,\(csvEscape(habit.name)),\(dateFormatter.string(from: completion.date)),\(completion.isCompleted ? "Done" : "Skipped"),\(completion.count)\n"
            }
        }

        // Sleep logs
        for log in sleepLogs {
            csv += "Sleep,,\(dateFormatter.string(from: log.bedTime)),\(log.durationFormatted),\(csvEscape(log.quality.rawValue))\n"
        }

        return writeToTempFile(content: csv, filename: "HabitLand_Export.csv")
    }

    private func exportJSON(habits: [Habit], sleepLogs: [SleepLog], profile: UserProfile?) -> URL? {
        let dateFormatter = ISO8601DateFormatter()

        var data: [String: Any] = [
            "exportDate": dateFormatter.string(from: Date()),
            "app": "HabitLand"
        ]

        if let p = profile {
            data["profile"] = [
                "name": p.name,
                "username": p.username,
                "level": p.level,
                "xp": p.xp,
                "joinedAt": dateFormatter.string(from: p.joinedAt)
            ]
        }

        data["habits"] = habits.map { habit in
            [
                "name": habit.name,
                "icon": habit.icon,
                "category": habit.category.rawValue,
                "frequency": habit.frequency.rawValue,
                "currentStreak": habit.currentStreak,
                "bestStreak": habit.bestStreak,
                "totalCompletions": habit.totalCompletions,
                "createdAt": dateFormatter.string(from: habit.createdAt),
                "completions": habit.safeCompletions.sorted(by: { $0.date > $1.date }).map { c in
                    [
                        "date": dateFormatter.string(from: c.date),
                        "completed": c.isCompleted,
                        "count": c.count
                    ] as [String: Any]
                }
            ] as [String: Any]
        }

        data["sleepLogs"] = sleepLogs.map { log in
            [
                "bedTime": dateFormatter.string(from: log.bedTime),
                "wakeTime": dateFormatter.string(from: log.wakeTime),
                "durationHours": log.durationHours,
                "quality": log.quality.rawValue,
                "mood": log.mood
            ] as [String: Any]
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys]) else {
            return nil
        }

        return writeToTempFile(data: jsonData, filename: "HabitLand_Export.json")
    }

    private func writeToTempFile(content: String, filename: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private func writeToTempFile(data: Data, filename: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}

// MARK: - Share Sheet

struct ShareSheetView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        PrivacySettingsView()
    }
}
