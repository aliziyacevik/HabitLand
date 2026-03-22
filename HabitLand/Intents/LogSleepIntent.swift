import AppIntents
import SwiftData
import Foundation

// MARK: - Log Sleep Intent

struct LogSleepIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("Log Sleep", table: "AppIntents")
    static var description: IntentDescription = IntentDescription(
        LocalizedStringResource("Log your sleep from last night", table: "AppIntents"),
        categoryName: LocalizedStringResource("Sleep", table: "AppIntents")
    )

    static var openAppWhenRun: Bool = false

    @Parameter(
        title: LocalizedStringResource("Hours Slept", table: "AppIntents"),
        description: LocalizedStringResource("How many hours you slept", table: "AppIntents"),
        requestValueDialog: IntentDialog(LocalizedStringResource("How many hours did you sleep?", table: "AppIntents"))
    )
    var hoursSlept: Double

    @Parameter(
        title: LocalizedStringResource("Quality", table: "AppIntents"),
        description: LocalizedStringResource("How was your sleep quality?", table: "AppIntents"),
        requestValueDialog: IntentDialog(LocalizedStringResource("How was your sleep quality?", table: "AppIntents"))
    )
    var quality: SleepQualityAppEnum

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: SleepLog.self, UserProfile.self)
        let context = container.mainContext

        // Calculate bed/wake times from hours slept
        let now = Date()
        let wakeTime = now
        let bedTime = now.addingTimeInterval(-hoursSlept * 3600)

        let sleepQuality: SleepQuality
        switch quality {
        case .terrible: sleepQuality = .terrible
        case .poor: sleepQuality = .poor
        case .fair: sleepQuality = .fair
        case .good: sleepQuality = .good
        case .excellent: sleepQuality = .excellent
        }

        let log = SleepLog(bedTime: bedTime, wakeTime: wakeTime, quality: sleepQuality)
        context.insert(log)

        // Award XP for logging sleep
        let profileDescriptor = FetchDescriptor<UserProfile>()
        if let profile = try context.fetch(profileDescriptor).first {
            profile.xp += 5
            if profile.xp >= profile.xpForNextLevel {
                profile.xp -= profile.xpForNextLevel
                profile.level += 1
            }
        }

        try context.save()

        let hours = Int(hoursSlept)
        let minutes = Int((hoursSlept - Double(hours)) * 60)
        let msg = LocalizedStringResource("Sleep logged: \(hours)h \(minutes)m of \(quality.localizedStringResource) sleep. Sweet dreams!", table: "AppIntents")
        return .result(dialog: IntentDialog(msg))
    }
}

// MARK: - Sleep Quality App Enum

enum SleepQualityAppEnum: String, AppEnum {
    case terrible
    case poor
    case fair
    case good
    case excellent

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: LocalizedStringResource("Sleep Quality", table: "AppIntents"))
    }

    static var caseDisplayRepresentations: [SleepQualityAppEnum: DisplayRepresentation] {
        [
            .terrible: DisplayRepresentation(title: LocalizedStringResource("Terrible", table: "AppIntents")),
            .poor: DisplayRepresentation(title: LocalizedStringResource("Poor", table: "AppIntents")),
            .fair: DisplayRepresentation(title: LocalizedStringResource("Fair", table: "AppIntents")),
            .good: DisplayRepresentation(title: LocalizedStringResource("Good", table: "AppIntents")),
            .excellent: DisplayRepresentation(title: LocalizedStringResource("Excellent", table: "AppIntents")),
        ]
    }
}
