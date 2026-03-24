import SwiftUI
import SwiftData

struct DataExportView: View {
    @ScaledMetric(relativeTo: .footnote) private var chevronSize: CGFloat = 14
    @ScaledMetric(relativeTo: .footnote) private var iconSize: CGFloat = 16
    @Environment(\.modelContext) private var modelContext
    @State private var exportFormat = 0 // 0=JSON, 1=CSV
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showDeleteConfirmation = false
    @State private var shareItem: ExportShareItem?

    var body: some View {
        List {
            Section {
                Picker("Format", selection: $exportFormat) {
                    Text("JSON").tag(0)
                    Text("CSV").tag(1)
                }
                .font(HLFont.body())
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            } header: {
                Text("Export Format")
            }

            Section {
                DatePicker("From", selection: $startDate, displayedComponents: .date)
                    .font(HLFont.body())
                    .tint(.hlPrimary)
                DatePicker("To", selection: $endDate, displayedComponents: .date)
                    .font(HLFont.body())
                    .tint(.hlPrimary)
            } header: {
                Text("Date Range")
            }

            Section {
                exportButton(icon: "checkmark.circle.fill", title: "Export Habits", subtitle: "Habits, completions, and streaks", color: .hlPrimary) {
                    exportHabits()
                }
                exportButton(icon: "moon.fill", title: "Export Sleep Data", subtitle: "Sleep logs, quality, and analytics", color: .hlSleep) {
                    exportSleepData()
                }
                exportButton(icon: "person.fill", title: "Export Profile", subtitle: "Profile, achievements, and settings", color: .hlInfo) {
                    exportProfile()
                }
                exportButton(icon: "square.and.arrow.down.fill", title: "Export All Data", subtitle: "Complete data package", color: .hlMindfulness) {
                    exportAllData()
                }
            } header: {
                Text("Export")
            } footer: {
                Text("Data will be exported as \(exportFormat == 0 ? "JSON" : "CSV") files")
            }

            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete Account")
                    }
                    .font(HLFont.body(.medium))
                    .foregroundColor(.hlError)
                    .frame(maxWidth: .infinity)
                }
            } footer: {
                Text("This will permanently delete all your data. This action cannot be undone.")
            }
        }
        .navigationTitle("Data & Export")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteAllData() }
        } message: {
            Text("This will permanently delete your account and all associated data. This cannot be undone.")
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
                .hlSheetContent()
        }
    }

    private func exportButton(icon: String, title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: min(iconSize, 20)))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.12))
                    .cornerRadius(HLRadius.sm)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text(title)
                        .font(HLFont.body())
                        .foregroundColor(.hlTextPrimary)
                    Text(subtitle)
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextTertiary)
                }

                Spacer()

                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: min(chevronSize, 18)))
                    .foregroundColor(.hlTextTertiary)
            }
        }
    }

    // MARK: - Export Functions

    private var isJSON: Bool { exportFormat == 0 }
    private var fileExtension: String { isJSON ? "json" : "csv" }
    private let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private func exportHabits() {
        let habits = (try? modelContext.fetch(FetchDescriptor<Habit>())) ?? []
        let filtered = habits.filter { habit in
            habit.createdAt >= startDate && habit.createdAt <= endDate
        }

        let content: String
        if isJSON {
            let data = filtered.map { habit in
                [
                    "name": habit.name,
                    "icon": habit.icon,
                    "category": habit.category.rawValue,
                    "frequency": habit.frequency.rawValue,
                    "goalCount": "\(habit.goalCount)",
                    "unit": habit.unit,
                    "currentStreak": "\(habit.currentStreak)",
                    "bestStreak": "\(habit.bestStreak)",
                    "totalCompletions": "\(habit.totalCompletions)",
                    "createdAt": dateFormatter.string(from: habit.createdAt),
                    "isArchived": "\(habit.isArchived)",
                ] as [String: String]
            }
            content = jsonString(from: data)
        } else {
            var csv = "Name,Icon,Category,Frequency,Goal,Unit,Current Streak,Best Streak,Total Completions,Created,Archived\n"
            for h in filtered {
                csv += "\"\(h.name)\",\(h.icon),\(h.category.rawValue),\(h.frequency.rawValue),\(h.goalCount),\(h.unit),\(h.currentStreak),\(h.bestStreak),\(h.totalCompletions),\(dateFormatter.string(from: h.createdAt)),\(h.isArchived)\n"
            }
            content = csv
        }
        shareFile(content: content, name: "habitland_habits.\(fileExtension)")
    }

    private func exportSleepData() {
        let logs = (try? modelContext.fetch(FetchDescriptor<SleepLog>())) ?? []
        let filtered = logs.filter { $0.createdAt >= startDate && $0.createdAt <= endDate }

        let content: String
        if isJSON {
            let data = filtered.map { log in
                [
                    "bedTime": dateFormatter.string(from: log.bedTime),
                    "wakeTime": dateFormatter.string(from: log.wakeTime),
                    "quality": log.quality.rawValue,
                    "durationHours": String(format: "%.1f", log.durationHours),
                    "mood": "\(log.mood)",
                    "notes": log.notes,
                ] as [String: String]
            }
            content = jsonString(from: data)
        } else {
            var csv = "Bed Time,Wake Time,Quality,Duration (h),Mood,Notes\n"
            for l in filtered {
                csv += "\(dateFormatter.string(from: l.bedTime)),\(dateFormatter.string(from: l.wakeTime)),\(l.quality.rawValue),\(String(format: "%.1f", l.durationHours)),\(l.mood),\"\(l.notes)\"\n"
            }
            content = csv
        }
        shareFile(content: content, name: "habitland_sleep.\(fileExtension)")
    }

    private func exportProfile() {
        let profiles = (try? modelContext.fetch(FetchDescriptor<UserProfile>())) ?? []
        let achievements = (try? modelContext.fetch(FetchDescriptor<Achievement>())) ?? []

        let content: String
        if isJSON {
            let profile = profiles.first
            let data: [String: Any] = [
                "name": profile?.name ?? "",
                "username": profile?.username ?? "",
                "level": profile?.level ?? 1,
                "xp": profile?.xp ?? 0,
                "joinedAt": dateFormatter.string(from: profile?.joinedAt ?? Date()),
                "achievements": achievements.filter(\.isUnlocked).map { $0.name },
            ]
            content = jsonStringFromDict(data)
        } else {
            var csv = "Field,Value\n"
            if let p = profiles.first {
                csv += "Name,\"\(p.name)\"\nUsername,\(p.username)\nLevel,\(p.level)\nXP,\(p.xp)\nJoined,\(dateFormatter.string(from: p.joinedAt))\n"
            }
            csv += "\nUnlocked Achievements\n"
            for a in achievements where a.isUnlocked {
                csv += "\(a.name),\"\(a.descriptionText)\"\n"
            }
            content = csv
        }
        shareFile(content: content, name: "habitland_profile.\(fileExtension)")
    }

    private func exportAllData() {
        // Export all as a combined JSON/CSV
        let habits = (try? modelContext.fetch(FetchDescriptor<Habit>())) ?? []
        let logs = (try? modelContext.fetch(FetchDescriptor<SleepLog>())) ?? []
        let profiles = (try? modelContext.fetch(FetchDescriptor<UserProfile>())) ?? []
        let achievements = (try? modelContext.fetch(FetchDescriptor<Achievement>())) ?? []

        if isJSON {
            let profile = profiles.first
            let combined: [String: Any] = [
                "exportDate": dateFormatter.string(from: Date()),
                "profile": [
                    "name": profile?.name ?? "",
                    "username": profile?.username ?? "",
                    "level": profile?.level ?? 1,
                    "xp": profile?.xp ?? 0,
                ],
                "habits": habits.map { ["name": $0.name, "category": $0.category.rawValue, "streak": $0.currentStreak, "completions": $0.totalCompletions] as [String: Any] },
                "sleepLogs": logs.map { ["bedTime": dateFormatter.string(from: $0.bedTime), "wakeTime": dateFormatter.string(from: $0.wakeTime), "quality": $0.quality.rawValue] },
                "achievements": achievements.filter(\.isUnlocked).map { $0.name },
            ]
            let content = jsonStringFromDict(combined)
            shareFile(content: content, name: "habitland_all_data.json")
        } else {
            var csv = "=== PROFILE ===\n"
            if let p = profiles.first {
                csv += "Name,\"\(p.name)\"\nLevel,\(p.level)\nXP,\(p.xp)\n"
            }
            csv += "\n=== HABITS ===\nName,Category,Streak,Completions\n"
            for h in habits {
                csv += "\"\(h.name)\",\(h.category.rawValue),\(h.currentStreak),\(h.totalCompletions)\n"
            }
            csv += "\n=== SLEEP LOGS ===\nBed Time,Wake Time,Quality,Duration\n"
            for l in logs {
                csv += "\(dateFormatter.string(from: l.bedTime)),\(dateFormatter.string(from: l.wakeTime)),\(l.quality.rawValue),\(String(format: "%.1f", l.durationHours))\n"
            }
            csv += "\n=== ACHIEVEMENTS ===\n"
            for a in achievements where a.isUnlocked {
                csv += "\(a.name)\n"
            }
            shareFile(content: csv, name: "habitland_all_data.csv")
        }
    }

    private func deleteAllData() {
        try? modelContext.delete(model: HabitCompletion.self)
        try? modelContext.delete(model: Habit.self)
        try? modelContext.delete(model: SleepLog.self)
        try? modelContext.delete(model: Achievement.self)
        try? modelContext.delete(model: UserProfile.self)
        try? modelContext.delete(model: Friend.self)
        try? modelContext.delete(model: Challenge.self)
        try? modelContext.delete(model: AppNotification.self)
        try? modelContext.save()
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }

    // MARK: - Helpers

    private func shareFile(content: String, name: String) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? content.write(to: url, atomically: true, encoding: .utf8)
        shareItem = ExportShareItem(url: url)
        HLHaptics.success()
    }

    private func jsonString(from array: [[String: String]]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    private func jsonStringFromDict(_ dict: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]) else { return "{}" }
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}

// MARK: - Share Sheet

struct ExportShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        DataExportView()
    }
}
