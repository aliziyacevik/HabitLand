import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @ScaledMetric(relativeTo: .caption) private var dismissIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var bannerIconSize: CGFloat = 18
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Binding var quickAction: HabitLandApp.QuickAction?
    @State private var selectedTab: HLTab = .home
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var proManager = ProManager.shared
    @State private var showQuickAddHabit = false
    @State private var showQuickDailyOverview = false
    @State private var showTrialExpiryPaywall = false
    @State private var showTrialWelcomeBanner = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
                    .transition(.opacity)
                    .onAppear {
                        // Check if trial expired and show soft paywall
                        if proManager.shouldShowTrialExpiryPaywall {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                showTrialExpiryPaywall = true
                            }
                        }
                    }
                    .sheet(isPresented: $showTrialExpiryPaywall) {
                        TrialExpiryPaywallView {
                            showTrialExpiryPaywall = false
                            proManager.hasTrialExpiryPaywallBeenShown = true
                        }
                        .hlSheetContent()
                    }
                    .overlay {
                        if showTrialWelcomeBanner {
                            trialWelcomeBanner
                        }
                    }
            } else {
                OnboardingView {
                    withAnimation(HLAnimation.gentleSpring) {
                        hasCompletedOnboarding = true
                    }
                    // Trial start is now handled by OnboardingView's "Maybe Later" button
                    // Show welcome banner if trial was just started
                    if proManager.hasTrialBeenOffered && !proManager.isPro {
                        showTrialWelcomeBanner = true
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
                .hlSheetContent()
        }
        .sheet(isPresented: $showQuickDailyOverview) {
            DailyHabitsOverview()
                .hlSheetContent()
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
                .blurredPremiumGate(feature: "Sleep Tracking", icon: "moon.fill", context: .sleepTracking)
                .tag(HLTab.sleep)
                .tabItem {
                    Label(HLTab.sleep.title, systemImage: HLTab.sleep.icon)
                }

            SocialHubView()
                .blurredPremiumGate(feature: "Social Features", icon: "person.2.fill", context: .socialFeatures)
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await HealthKitManager.shared.syncHealthHabits(context: modelContext)
                }
            }
        }
    }

    // MARK: - Trial Welcome Banner

    private var trialWelcomeBanner: some View {
        VStack {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: min(bannerIconSize, 22), weight: .semibold))
                    .foregroundStyle(Color.hlGold)
                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("7 Days of Pro — Free!")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                    Text("All features unlocked. Explore everything!")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary)
                }
                Spacer()
                Button {
                    withAnimation(HLAnimation.spring) {
                        showTrialWelcomeBanner = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: min(dismissIconSize, 16), weight: .bold))
                        .foregroundStyle(Color.hlTextTertiary)
                }
                .accessibilityLabel("Dismiss")
            }
            .padding(HLSpacing.md)
            .background(.ultraThinMaterial)
            .cornerRadius(HLRadius.lg)
            .hlShadow(HLShadow.md)
            .padding(.horizontal, HLSpacing.md)
            .padding(.top, HLSpacing.sm)

            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(HLAnimation.spring) {
                    showTrialWelcomeBanner = false
                }
            }
        }
    }
}

// MARK: - Trial Expiry Paywall

struct TrialExpiryPaywallView: View {
    @ScaledMetric(relativeTo: .largeTitle) private var crownIconSize: CGFloat = 48
    @ScaledMetric(relativeTo: .footnote) private var loseItemIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .title3) private var statIconSize: CGFloat = 24
    @Query private var habits: [Habit]
    @Query private var sleepLogs: [SleepLog]
    var onDismiss: () -> Void

    private var habitCount: Int { habits.filter { !$0.isArchived }.count }
    private var completionCount: Int { habits.flatMap(\.safeCompletions).filter(\.isCompleted).count }
    private var sleepNights: Int { sleepLogs.count }
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HLSpacing.xl) {
                    // Header
                    VStack(spacing: HLSpacing.sm) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: min(crownIconSize, 56)))
                            .foregroundStyle(Color.hlGold)

                        Text("Your Pro Trial Ended")
                            .font(HLFont.title2())
                            .foregroundStyle(Color.hlTextPrimary)

                        Text("Here's what you accomplished in 7 days:")
                            .font(HLFont.subheadline())
                            .foregroundStyle(Color.hlTextSecondary)
                    }
                    .padding(.top, HLSpacing.xl)

                    // Stats
                    HStack(spacing: HLSpacing.md) {
                        trialStat(value: "\(habitCount)", label: "Habits\nCreated", icon: "checkmark.circle.fill", color: .hlPrimary)
                        trialStat(value: "\(completionCount)", label: "Times\nCompleted", icon: "flame.fill", color: .hlFlame)
                        trialStat(value: "\(sleepNights)", label: "Nights\nTracked", icon: "moon.fill", color: .hlSleep)
                    }

                    // What you'll lose
                    VStack(alignment: .leading, spacing: HLSpacing.sm) {
                        Text("With Free plan:")
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlTextPrimary)

                        loseItem(icon: "xmark.circle", text: "Limited to \(ProManager.freeHabitLimit) habits (you have \(habitCount))", isWarning: habitCount > ProManager.freeHabitLimit)
                        loseItem(icon: "xmark.circle", text: "Sleep tracking locked", isWarning: sleepNights > 0)
                        loseItem(icon: "xmark.circle", text: "Social features locked", isWarning: false)
                        loseItem(icon: "xmark.circle", text: "Premium themes locked", isWarning: false)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(HLSpacing.md)
                    .background(Color.hlSurface)
                    .cornerRadius(HLRadius.lg)

                    // CTA
                    VStack(spacing: HLSpacing.sm) {
                        Button {
                            showPaywall = true
                        } label: {
                            Text("Upgrade to Pro — $19.99/year")
                                .font(HLFont.headline())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, HLSpacing.md)
                                .background(Color.hlPrimary)
                                .cornerRadius(HLRadius.lg)
                        }

                        Button {
                            onDismiss()
                        } label: {
                            Text("Continue with Free Plan")
                                .font(HLFont.subheadline())
                                .foregroundStyle(Color.hlTextSecondary)
                        }
                    }
                }
                .padding(.horizontal, HLSpacing.lg)
                .padding(.bottom, HLSpacing.xxxl)
            }
            .background(Color.hlBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .hlSheetContent()
            }
        }
    }

    private func trialStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: HLSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: min(statIconSize, 28)))
                .foregroundStyle(color)
            Text(value)
                .font(HLFont.title2())
                .foregroundStyle(Color.hlTextPrimary)
            Text(label)
                .font(HLFont.caption2())
                .foregroundStyle(Color.hlTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.sm)
        .background(Color.hlSurface)
        .cornerRadius(HLRadius.md)
    }

    private func loseItem(icon: String, text: String, isWarning: Bool) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: min(loseItemIconSize, 18)))
                .foregroundStyle(isWarning ? Color.hlError : Color.hlTextTertiary)
            Text(text)
                .font(HLFont.subheadline())
                .foregroundStyle(isWarning ? Color.hlError : Color.hlTextSecondary)
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
