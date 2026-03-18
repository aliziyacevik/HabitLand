import SwiftUI
import SwiftData
import UIKit

// MARK: - App Delegate for Quick Actions

class AppDelegate: NSObject, UIApplicationDelegate {
    static var pendingShortcut: HabitLandApp.QuickAction?

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem,
           let action = HabitLandApp.QuickAction(rawValue: shortcutItem.type) {
            AppDelegate.pendingShortcut = action
        }
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if let action = HabitLandApp.QuickAction(rawValue: shortcutItem.type) {
            AppDelegate.pendingShortcut = action
            NotificationCenter.default.post(name: .quickActionTriggered, object: action)
        }
        completionHandler(true)
    }
}

extension Notification.Name {
    static let quickActionTriggered = Notification.Name("quickActionTriggered")
}

@main
struct HabitLandApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var quickAction: QuickAction?

    enum QuickAction: String {
        case addHabit = "AddHabitAction"
        case todayProgress = "TodayProgressAction"
        case logSleep = "LogSleepAction"
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitCompletion.self,
            SleepLog.self,
            UserProfile.self,
            Achievement.self,
            Friend.self,
            Challenge.self,
            AppNotification.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(quickAction: $quickAction)
                .onAppear {
                    seedDataIfNeeded()
                    requestNotificationsIfNeeded()
                    setupQuickActions()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func setupQuickActions() {
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(
                type: QuickAction.addHabit.rawValue,
                localizedTitle: "Add Habit",
                localizedSubtitle: "Create a new habit",
                icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill")
            ),
            UIApplicationShortcutItem(
                type: QuickAction.todayProgress.rawValue,
                localizedTitle: "Today's Progress",
                localizedSubtitle: "View daily habits",
                icon: UIApplicationShortcutIcon(systemImageName: "checkmark.circle.fill")
            ),
            UIApplicationShortcutItem(
                type: QuickAction.logSleep.rawValue,
                localizedTitle: "Log Sleep",
                localizedSubtitle: "Record last night's sleep",
                icon: UIApplicationShortcutIcon(systemImageName: "moon.fill")
            ),
        ]
    }

    private func seedDataIfNeeded() {
        let context = sharedModelContainer.mainContext

        // Create default UserProfile if none exists
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let profileCount = (try? context.fetchCount(profileDescriptor)) ?? 0
        if profileCount == 0 {
            let profile = UserProfile(name: "User", username: "@user", avatarEmoji: "🌱")
            context.insert(profile)
        }

        // Create default Achievements if none exist
        let achievementDescriptor = FetchDescriptor<Achievement>()
        let achievementCount = (try? context.fetchCount(achievementDescriptor)) ?? 0
        if achievementCount == 0 {
            for a in SampleData.achievements {
                let achievement = Achievement(
                    name: a.name,
                    descriptionText: a.description,
                    icon: a.icon,
                    category: a.category
                )
                context.insert(achievement)
            }
        }

        try? context.save()

        // Check achievements on launch
        AchievementManager.checkAll(context: context)
    }

    private func requestNotificationsIfNeeded() {
        Task {
            let manager = NotificationManager.shared
            if !manager.isAuthorized {
                _ = await manager.requestPermission()
            }
            // Schedule weekly summary if enabled
            let weeklySummaryEnabled = UserDefaults.standard.object(forKey: "notif_weeklySummary") == nil
                || UserDefaults.standard.bool(forKey: "notif_weeklySummary")
            if weeklySummaryEnabled {
                manager.scheduleWeeklySummary()
            }
        }
    }
}
