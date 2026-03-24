import os
import SwiftUI
import SwiftData
import UIKit

// MARK: - App Delegate for Quick Actions

class AppDelegate: NSObject, UIApplicationDelegate {
    static var pendingShortcut: HabitLandApp.QuickAction?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Register for remote push notifications (D-10)
        // Local notifications remain primary; APNs registration prepares for future server-triggered notifications
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Token received — will be used when server push is implemented in v2
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        HLLogger.app.debug("APNs device token: \(token, privacy: .private)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        HLLogger.app.error("APNs registration failed: \(error.localizedDescription, privacy: .public)")
    }

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

    var sharedModelContainer: ModelContainer = SharedModelContainer.container

    private var isScreenshotMode: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-screenshotMode")
        #else
        return false
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView(quickAction: $quickAction)
                .onAppear {
                    if isScreenshotMode {
                        seedScreenshotData()
                    } else {
                        seedDataIfNeeded()
                    }
                    if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                        requestNotificationsIfNeeded()
                    }
                    setupQuickActions()
                    Task { await checkReferralRewards() }
                    syncHealthKitHabits()
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
        let profileCount: Int
        do {
            profileCount = try context.fetchCount(profileDescriptor)
        } catch {
            HLLogger.data.error("Failed to fetch profile count: \(error.localizedDescription, privacy: .public)")
            return
        }
        if profileCount == 0 {
            let profile = UserProfile(name: "User", username: "@user", avatarEmoji: "🌱")
            context.insert(profile)
        }

        // Seed achievements — adds any missing ones (supports adding new achievements to existing users)
        let existingAchievements: [Achievement]
        do {
            existingAchievements = try context.fetch(FetchDescriptor<Achievement>())
        } catch {
            HLLogger.data.error("Failed to fetch achievements for seeding: \(error.localizedDescription, privacy: .public)")
            existingAchievements = []
        }
        let existingNames = Set(existingAchievements.map(\.name))
        for a in SampleData.achievements where !existingNames.contains(a.name) {
            let achievement = Achievement(
                name: a.name,
                descriptionText: a.description,
                icon: a.icon,
                category: a.category
            )
            context.insert(achievement)
        }

        do {
            try context.save()
        } catch {
            HLLogger.data.error("Failed to save seeded data: \(error.localizedDescription, privacy: .public)")
        }

        // Check achievements on launch
        AchievementManager.checkAll(context: context)
    }

    private func seedScreenshotData() {
        let context = sharedModelContainer.mainContext
        let calendar = Calendar.current

        // Skip onboarding
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Clear existing data
        do {
            try context.delete(model: Habit.self)
            try context.delete(model: HabitCompletion.self)
            try context.delete(model: SleepLog.self)
            try context.delete(model: UserProfile.self)
            try context.delete(model: Achievement.self)
            try context.delete(model: Friend.self)
        } catch {
            HLLogger.data.error("Failed to clear screenshot data: \(error.localizedDescription, privacy: .public)")
        }

        // Create profile with good XP/level
        let profile = UserProfile(name: "Alex", username: "alexj", avatarEmoji: "🌿", bio: "Building better habits daily")
        profile.level = 8
        profile.xp = 520
        profile.avatarType = .animal(.owl)
        context.insert(profile)

        // Create habits with realistic streaks
        let habitsData: [(name: String, icon: String, color: String, category: HabitCategory, streakDays: Int, completedToday: Bool, sortOrder: Int)] = [
            ("Morning Meditation", "brain.head.profile", "#9966E6", .mindfulness, 32, true, 0),
            ("Drink Water", "drop.fill", "#338FFF", .health, 21, true, 1),
            ("Exercise", "figure.run", "#F24D4D", .fitness, 14, true, 2),
            ("Read 30 min", "book.fill", "#FFC207", .learning, 18, true, 3),
            ("Healthy Eating", "leaf.fill", "#34C759", .nutrition, 7, false, 4),
        ]

        let today = calendar.startOfDay(for: Date())

        for hd in habitsData {
            let habit = Habit(
                name: hd.name,
                icon: hd.icon,
                colorHex: hd.color,
                category: hd.category,
                sortOrder: hd.sortOrder
            )
            context.insert(habit)

            // Create completions for streak
            let totalDays = hd.streakDays + 5 // some extra history
            for dayOffset in 0..<totalDays {
                let baseDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
                if dayOffset == 0 && !hd.completedToday { continue }
                // Skip a few random days beyond the streak for realism
                if dayOffset > hd.streakDays && dayOffset % 3 == 0 { continue }
                // Add realistic time (7-21h range) so detail view shows proper timestamps
                let realisticHour = (hd.sortOrder * 3 + 7) % 14 + 7 // 7am-9pm spread
                let realisticMinute = (dayOffset * 17 + hd.sortOrder * 11) % 60
                let date = calendar.date(bySettingHour: realisticHour, minute: realisticMinute, second: 0, of: baseDate) ?? baseDate
                let completion = HabitCompletion(date: date, isCompleted: true)
                completion.habit = habit
                context.insert(completion)
            }
        }

        // Create sleep logs for the past 10 days
        let sleepData: [(hours: Double, quality: SleepQuality)] = [
            (7.7, .good), (6.8, .fair), (8.2, .excellent), (7.0, .good),
            (6.5, .fair), (9.0, .excellent), (7.5, .good), (7.8, .good),
            (6.2, .poor), (8.0, .good),
        ]

        for (i, sd) in sleepData.enumerated() {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            var bedComponents = calendar.dateComponents([.year, .month, .day], from: date)
            bedComponents.hour = 23
            bedComponents.minute = Int.random(in: 0...30)
            let bedTime = calendar.date(from: bedComponents) ?? date
            let wakeTime = bedTime.addingTimeInterval(sd.hours * 3600)
            let log = SleepLog(bedTime: bedTime, wakeTime: wakeTime, quality: sd.quality, mood: sd.quality == .excellent ? 5 : sd.quality == .good ? 4 : 3)
            context.insert(log)
        }

        // Create achievements (some unlocked)
        for (i, a) in SampleData.achievements.enumerated() {
            let achievement = Achievement(
                name: a.name,
                descriptionText: a.description,
                icon: a.icon,
                category: a.category
            )
            // Unlock first 5 achievements
            if i < 5 {
                achievement.isUnlocked = true
                achievement.unlockedAt = calendar.date(byAdding: .day, value: -(30 - i * 5), to: today)
                achievement.progress = 1.0
            }
            context.insert(achievement)
        }

        // Create friends for leaderboard
        let friends: [(name: String, emoji: String, level: Int, streak: Int)] = [
            ("Sarah", "🦊", 12, 42),
            ("Mike", "🐻", 10, 28),
            ("Emma", "🐼", 7, 14),
            ("James", "🐸", 4, 5),
            ("Lily", "🦋", 3, 3),
        ]

        let avatarTypes: [AvatarType] = [
            .animal(.fox),
            .animal(.bear),
            .animal(.panda),
            .animal(.cat),
            .frame(.stars),
        ]

        let completions = [210, 156, 68, 20, 9]
        let todayDone = [4, 3, 2, 1, 0]

        for (i, f) in friends.enumerated() {
            let friend = Friend(name: f.name, username: "@\(f.name.lowercased())", avatarEmoji: f.emoji, level: f.level, currentStreak: f.streak)
            if i < avatarTypes.count {
                friend.avatarType = avatarTypes[i]
            }
            friend.totalCompletions = completions[i]
            friend.habitsCompletedToday = todayDone[i]
            friend.lastActive = i < 3 ? Date() : calendar.date(byAdding: .day, value: -(i - 1), to: today)
            context.insert(friend)
        }

        do {
            try context.save()
        } catch {
            HLLogger.data.error("Failed to save screenshot data: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func checkReferralRewards() async {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? context.fetch(descriptor).first,
              let referralCode = profile.referralCode else { return }

        let cloudKit = CloudKitManager.shared
        guard cloudKit.iCloudAvailable else { return }

        let cloudCount = await cloudKit.fetchReferralCount(forCode: referralCode)
        let localCount = profile.referralCount

        guard cloudCount > localCount else { return }

        let newRedemptions = cloudCount - localCount
        let proManager = ProManager.shared
        let maxStacks = ProManager.maxReferralStacks

        // Grant Pro for each new redemption, up to the cap
        for i in 0..<newRedemptions {
            let totalAfterThis = localCount + i + 1
            if totalAfterThis > maxStacks { break }
            proManager.extendReferralPro()
        }

        // Update local count to match cloud (even if capped, so we don't re-process)
        profile.referralCount = cloudCount
        do {
            try context.save()
        } catch {
            HLLogger.data.error("Failed to save referral count: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func syncHealthKitHabits() {
        Task {
            await HealthKitManager.shared.syncHealthHabits(context: sharedModelContainer.mainContext)
        }
    }

    private func requestNotificationsIfNeeded() {
        Task {
            let manager = NotificationManager.shared
            if !manager.isAuthorized {
                _ = await manager.requestPermission()
            }
            // Schedule daily notifications (includes weekly recap, streak risk, morning motivation)
            let context = sharedModelContainer.mainContext
            let habits: [Habit]
            do {
                habits = try context.fetch(FetchDescriptor<Habit>())
            } catch {
                HLLogger.data.warning("Failed to fetch habits for notifications: \(error.localizedDescription, privacy: .public)")
                habits = []
            }
            let habitData = habits.filter { !$0.isArchived }.map {
                (id: $0.id, name: $0.name, streak: $0.currentStreak, completed: $0.todayCompleted)
            }
            manager.scheduleDailyNotifications(habits: habitData)
        }
    }
}
