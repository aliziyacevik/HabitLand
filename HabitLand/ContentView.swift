import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @Binding var quickAction: HabitLandApp.QuickAction?
    @State private var selectedTab: HLTab = .home
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showQuickAddHabit = false
    @State private var showQuickDailyOverview = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
                    .transition(.opacity)
            } else {
                OnboardingView {
                    withAnimation(HLAnimation.gentleSpring) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .tint(.hlPrimary)
        .onChange(of: quickAction) { _, action in
            handleQuickAction(action)
        }
        .onAppear {
            // Handle shortcut from cold launch
            if let pending = AppDelegate.pendingShortcut {
                AppDelegate.pendingShortcut = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    quickAction = pending
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .quickActionTriggered)) { notification in
            if let action = notification.object as? HabitLandApp.QuickAction {
                quickAction = action
            }
        }
        .sheet(isPresented: $showQuickAddHabit) {
            CreateHabitView()
        }
        .sheet(isPresented: $showQuickDailyOverview) {
            DailyHabitsOverview()
        }
    }

    private func handleQuickAction(_ action: HabitLandApp.QuickAction?) {
        guard let action else { return }
        switch action {
        case .addHabit:
            selectedTab = .home
            showQuickAddHabit = true
        case .todayProgress:
            selectedTab = .home
            showQuickDailyOverview = true
        case .logSleep:
            selectedTab = .sleep
        }
        quickAction = nil
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeDashboardView()
                .tag(HLTab.home)
                .tabItem {
                    Label(HLTab.home.title, systemImage: HLTab.home.icon)
                }

            HabitListView()
                .tag(HLTab.habits)
                .tabItem {
                    Label(HLTab.habits.title, systemImage: HLTab.habits.icon)
                }

            SleepDashboardView()
                .premiumGated(feature: "Sleep Tracking", icon: "moon.fill")
                .tag(HLTab.sleep)
                .tabItem {
                    Label(HLTab.sleep.title, systemImage: HLTab.sleep.icon)
                }

            SocialHubView()
                .premiumGated(feature: "Social Features", icon: "person.2.fill")
                .tag(HLTab.social)
                .tabItem {
                    Label(HLTab.social.title, systemImage: HLTab.social.icon)
                }

            UserProfileView()
                .tag(HLTab.profile)
                .tabItem {
                    Label(HLTab.profile.title, systemImage: HLTab.profile.icon)
                }
        }
        .tint(.hlPrimary)
        .onChange(of: selectedTab) { _, _ in
            HLHaptics.selection()
        }
    }
}

#Preview {
    ContentView(quickAction: .constant(nil))
        .modelContainer(for: [
            Habit.self,
            HabitCompletion.self,
            SleepLog.self,
            UserProfile.self,
            Achievement.self,
            Friend.self,
            Challenge.self,
            AppNotification.self,
        ], inMemory: true)
}
