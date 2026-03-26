import SwiftUI
import SwiftData

// MARK: - Onboarding Page Model

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let emoji: String?
    let title: String
    let subtitle: String
    let accentColor: Color
    let isLevelUpPage: Bool
    let isLeaderboardPreview: Bool
    let isStreakPreview: Bool
    let isSleepPreview: Bool

    init(systemImage: String, emoji: String? = nil, title: String, subtitle: String, accentColor: Color, isLevelUpPage: Bool = false, isLeaderboardPreview: Bool = false, isStreakPreview: Bool = false, isSleepPreview: Bool = false) {
        self.systemImage = systemImage
        self.emoji = emoji
        self.title = title
        self.subtitle = subtitle
        self.accentColor = accentColor
        self.isLevelUpPage = isLevelUpPage
        self.isLeaderboardPreview = isLeaderboardPreview
        self.isStreakPreview = isStreakPreview
        self.isSleepPreview = isSleepPreview
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @ScaledMetric(relativeTo: .caption) private var tinyIconSize: CGFloat = 10
    @ScaledMetric(relativeTo: .caption) private var sortIconSize: CGFloat = 11
    @ScaledMetric(relativeTo: .caption) private var smallIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var badgeIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .footnote) private var sectionIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var cardIconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var mediumIconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .title3) private var selectorEmojiSize: CGFloat = 22
    @ScaledMetric(relativeTo: .title3) private var playIconSize: CGFloat = 28
    @ScaledMetric(relativeTo: .largeTitle) private var avatarEmojiSize: CGFloat = 40
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 60
    @ScaledMetric(relativeTo: .body) private var iconButtonSize: CGFloat = 40
    @ScaledMetric(relativeTo: .body) private var avatarPickerSize: CGFloat = 48
    @ScaledMetric(relativeTo: .title) private var avatarDisplaySize: CGFloat = 96
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }

    // Page state
    @State private var currentPage = 0
    // Steps: 0=pages, 1=theme, 2=pro offer
    @State private var currentStep = 0
    @ObservedObject private var proManager = ProManager.shared

    // Data collected
    @State private var userName = ""
    @State private var selectedAvatar = "🌱"
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()

    @FocusState private var nameFieldFocused: Bool
    var onComplete: () -> Void = {}

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "",
            emoji: "🔥",
            title: "Building habits\nmade fun",
            subtitle: "Streaks, XP, and levels — the system that actually works.",
            accentColor: .hlFlame
        ),
        OnboardingPage(
            systemImage: "person.crop.circle.badge.plus",
            title: "What's your name?",
            subtitle: "This is how you'll appear in the app.",
            accentColor: .hlPrimary
        ),
    ]

    private let avatarOptions = ["🌱", "😊", "😎", "🦊", "🐱", "🐶", "🦁", "🐼", "🦄", "🎯", "⭐", "🔥"]

    var body: some View {
        Group {
            switch currentStep {
            case 1:
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            withAnimation(HLAnimation.gentleSpring) { currentStep = 0 }
                        } label: {
                            HStack(spacing: HLSpacing.xxs) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(HLFont.callout(.medium))
                            .foregroundStyle(Color.hlTextSecondary)
                        }
                        .padding(.leading, HLSpacing.lg)
                        Spacer()
                    }
                    stepIndicator(step: 3)
                    ThemeOnboardingView {
                        withAnimation(HLAnimation.gentleSpring) {
                            currentStep = 2
                        }
                    }
                }
            case 2:
                VStack(spacing: 0) {
                    stepIndicator(step: 4)
                    proOfferStep
                }
            case 3:
                PaywallView(onDismissAction: {
                    withAnimation(HLAnimation.gentleSpring) {
                        currentStep = 2
                    }
                })
            default:
                pagesView
            }
        }
        .background(Color.hlBackground.ignoresSafeArea())
    }

    // MARK: - Pages View (TabView with progress bar)

    private var pagesView: some View {
        VStack(spacing: 0) {
            // Top bar: Back + Skip
            HStack {
                if currentPage > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage -= 1
                        }
                    } label: {
                        HStack(spacing: HLSpacing.xxs) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: min(badgeIconSize, 18), weight: .semibold))
                            Text("Back")
                                .font(HLFont.callout(.medium))
                        }
                        .foregroundColor(.hlTextSecondary)
                    }
                    .padding(.leading, HLSpacing.lg)
                }

                Spacer()

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        saveName()
                        withAnimation(HLAnimation.gentleSpring) {
                            currentStep = 1
                        }
                    }
                    .font(HLFont.callout(.medium))
                    .foregroundColor(.hlTextSecondary)
                    .padding(.trailing, HLSpacing.lg)
                }
            }
            .frame(height: 44)

            // Progress bar
            progressBar

            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    if index == pages.count - 1 {
                        nameEntryPage(page)
                            .tag(index)
                    } else if page.isLevelUpPage {
                        levelUpPageView(page)
                            .tag(index)
                    } else if page.isStreakPreview {
                        streakPreviewPage(page)
                            .tag(index)
                    } else if page.isSleepPreview {
                        sleepPreviewPage(page)
                            .tag(index)
                    } else {
                        pageView(page)
                            .tag(index)
                            .id("\(index)-\(currentPage)")
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Next / Choose My Habits button
            HLButton(
                currentPage == pages.count - 1 ? "Continue" : "Next",
                icon: "arrow.right",
                style: .primary,
                size: .lg,
                isFullWidth: true
            ) {
                if currentPage < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                } else {
                    nameFieldFocused = false
                    saveName()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(HLAnimation.gentleSpring) {
                            currentStep = 1
                        }
                    }
                }
            }
            .disabled(currentPage == pages.count - 1 && userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
        }
    }

    // MARK: - Step Indicator (for theme/trial steps)

    private func stepIndicator(step: Int) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            Text("Step \(step) of 4")
                .font(HLFont.caption(.medium))
                .foregroundColor(.hlTextTertiary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: HLRadius.full)
                        .fill(Color.hlDivider)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: HLRadius.full)
                        .fill(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(step) / 4.0, height: 4)
                        .animation(HLAnimation.standard, value: step)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, HLSpacing.xl)
        }
        .padding(.top, HLSpacing.lg)
        .padding(.bottom, HLSpacing.sm)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: HLSpacing.xxs) {
            Text("Step \(currentPage + 1) of 4")
                .font(HLFont.caption(.medium))
                .foregroundColor(.hlTextTertiary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: HLRadius.full)
                        .fill(Color.hlDivider)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: HLRadius.full)
                        .fill(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(currentPage + 1) / 4.0, height: 4)
                        .animation(HLAnimation.standard, value: currentPage)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, HLSpacing.xl)
        }
        .padding(.bottom, HLSpacing.sm)
    }

    // MARK: - Standard Page View

    @ViewBuilder
    private func pageView(_ page: OnboardingPage) -> some View {
        AnimatedOnboardingPage(page: page)
            .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Level Up Page

    @ViewBuilder
    private func levelUpPageView(_ page: OnboardingPage) -> some View {
        LevelUpPreviewPage(page: page, isActive: currentPage == 4)
            .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Streak Preview Page (Page 2)

    @ViewBuilder
    private func streakPreviewPage(_ page: OnboardingPage) -> some View {
        OnboardingPreviewPage(page: page, pageIndex: 1, currentPage: currentPage) {
            StreakPreviewContent(isActive: currentPage == 1)
        }
    }

    // MARK: - Sleep Preview Page (Page 3)

    @ViewBuilder
    private func sleepPreviewPage(_ page: OnboardingPage) -> some View {
        OnboardingPreviewPage(page: page, pageIndex: 2, currentPage: currentPage) {
            SleepPreviewContent(isActive: currentPage == 2)
        }
    }

    // MARK: - Name Entry + Avatar Picker

    @ViewBuilder
    private func nameEntryPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()

            // Selected avatar display — shrinks when keyboard shows
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(
                        width: min(avatarDisplaySize, nameFieldFocused ? 80 : 128),
                        height: min(avatarDisplaySize, nameFieldFocused ? 80 : 128)
                    )

                Text(selectedAvatar)
                    .font(.system(size: nameFieldFocused ? min(avatarEmojiSize * 0.6, 32) : min(avatarEmojiSize, 56)))
            }
            .animation(HLAnimation.gentleSpring, value: nameFieldFocused)

            Text(page.title)
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)
                .opacity(nameFieldFocused ? 0 : 1)
                .frame(height: nameFieldFocused ? 0 : nil)
                .clipped()

            Text(page.subtitle)
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)
                .opacity(nameFieldFocused ? 0 : 1)
                .frame(height: nameFieldFocused ? 0 : nil)
                .clipped()

            // Avatar picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.xs) {
                    ForEach(avatarOptions, id: \.self) { avatar in
                        Button {
                            selectedAvatar = avatar
                            HLHaptics.selection()
                        } label: {
                            Text(avatar)
                                .font(.system(size: min(selectorEmojiSize, 30)))
                                .frame(width: min(avatarPickerSize, 64), height: min(avatarPickerSize, 64))
                                .background(
                                    selectedAvatar == avatar
                                        ? Color.hlPrimary.opacity(0.15)
                                        : Color(.systemGray6)
                                )
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedAvatar == avatar ? Color.hlPrimary : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        }
                        .scaleEffect(selectedAvatar == avatar ? 1.1 : 1.0)
                        .animation(HLAnimation.microSpring, value: selectedAvatar)
                    }
                }
                .padding(.horizontal, HLSpacing.lg)
            }

            // Name field
            TextField("Your name", text: $userName)
                .font(HLFont.title3(.bold))
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .padding(HLSpacing.md)
                .background(Color(.systemGray6))
                .cornerRadius(HLRadius.md)
                .padding(.horizontal, HLSpacing.xl)
                .focused($nameFieldFocused)
                .submitLabel(.done)
                .onSubmit { nameFieldFocused = false }

            Spacer()
        }
        .padding(.horizontal, HLSpacing.lg)
        .animation(HLAnimation.gentleSpring, value: nameFieldFocused)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                nameFieldFocused = false
            }
        )
    }

    // MARK: - Save Name & Avatar

    private func saveName() {
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let profile = profile else { return }

        if !trimmed.isEmpty {
            profile.name = trimmed
            profile.username = "@\(trimmed.lowercased().replacingOccurrences(of: " ", with: ""))"
        }
        profile.avatarEmoji = selectedAvatar
        try? modelContext.save()
    }

    // MARK: - Reminder Setup Step

    @ScaledMetric(relativeTo: .largeTitle) private var largeIconSize: CGFloat = 64
    @ScaledMetric(relativeTo: .largeTitle) private var trialCircleSize: CGFloat = 160

    private var reminderSetupStep: some View {
        VStack(spacing: HLSpacing.xl) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: min(largeIconSize, 72)))
                .foregroundStyle(Color.hlPrimary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: HLSpacing.sm) {
                Text("When should we\nremind you?")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlTextPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)

                Text("Pick a time and we'll send you a daily reminder. You can change this in Settings.")
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, HLSpacing.lg)
            }

            DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxHeight: 150)

            Spacer()

            VStack(spacing: HLSpacing.sm) {
                Button {
                    saveReminderTime()
                    Task {
                        _ = await NotificationManager.shared.requestPermission()
                        await MainActor.run {
                            withAnimation(HLAnimation.gentleSpring) {
                                currentStep = 2
                            }
                        }
                    }
                } label: {
                    HStack(spacing: HLSpacing.xs) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: min(sectionIconSize, 20)))
                        Text("Enable Reminders")
                    }
                    .font(HLFont.headline())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.md)
                    .background(Color.hlPrimary)
                    .cornerRadius(HLRadius.lg)
                }

                Button {
                    withAnimation(HLAnimation.gentleSpring) {
                        currentStep = 2
                    }
                } label: {
                    Text("Skip for now")
                        .font(HLFont.subheadline())
                        .foregroundStyle(Color.hlTextSecondary)
                }
            }
            .padding(.horizontal, HLSpacing.xl)
            .padding(.bottom, HLSpacing.xxxl)
        }
    }

    private func saveReminderTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        UserDefaults.standard.set(components.hour ?? 20, forKey: "dailyReminderHour")
        UserDefaults.standard.set(components.minute ?? 0, forKey: "dailyReminderMinute")
    }

    // MARK: - Trial Welcome Step

    private var proOfferStep: some View {
        VStack(spacing: HLSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.hlGold.opacity(0.12))
                    .frame(width: min(trialCircleSize, 180), height: min(trialCircleSize, 180))

                Image(systemName: "crown.fill")
                    .font(.system(size: min(largeIconSize, 72)))
                    .foregroundStyle(Color.hlGold)
            }

            VStack(spacing: HLSpacing.sm) {
                Text("Unlock Your\nFull Potential")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlTextPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)

                Text("Go Pro for unlimited access to everything:")
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
            }

            VStack(alignment: .leading, spacing: HLSpacing.sm) {
                trialFeatureRow(icon: "infinity", text: "Unlimited habits", color: .hlPrimary)
                trialFeatureRow(icon: "moon.stars.fill", text: "Sleep tracking & insights", color: .hlSleep)
                trialFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed analytics", color: .hlGold)
                trialFeatureRow(icon: "trophy.fill", text: "All achievements", color: .hlFlame)
                trialFeatureRow(icon: "paintpalette.fill", text: "All themes & customization", color: .hlPrimary)
            }
            .padding(.horizontal, HLSpacing.xl)

            Spacer()

            VStack(spacing: HLSpacing.sm) {
                Button {
                    withAnimation(HLAnimation.gentleSpring) {
                        currentStep = 3
                    }
                } label: {
                    Text("Start Pro")
                        .font(HLFont.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HLSpacing.md)
                        .background(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(HLRadius.lg)
                }
                .accessibilityLabel("Start Pro subscription")

                Button {
                    onComplete()
                } label: {
                    Text("Maybe Later")
                        .font(HLFont.callout(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                }
                .accessibilityLabel("Skip Pro offer and continue")
            }
            .padding(.horizontal, HLSpacing.xl)
            .padding(.bottom, HLSpacing.xxxl)
        }
        .onChange(of: proManager.isPro) { _, isPro in
            if isPro {
                onComplete()
            }
        }
    }

    private func trialFeatureRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: min(cardIconSize, 22), weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 28)
            Text(text)
                .font(HLFont.body())
                .foregroundStyle(Color.hlTextPrimary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: min(cardIconSize, 22)))
                .foregroundStyle(Color.hlSuccess)
        }
    }

    // MARK: - First XP Award (no longer used — coaching handles this on home screen)
}

// MARK: - Animated Onboarding Page

// MARK: - Onboarding Preview Page (shared layout: title top, preview bottom with slide-up)

private struct OnboardingPreviewPage<Preview: View>: View {
    @ScaledMetric(relativeTo: .caption) private var sortIconSize: CGFloat = 11
    let page: OnboardingPage
    let pageIndex: Int
    let currentPage: Int
    @ViewBuilder let preview: () -> Preview
    @State private var showTitle = false
    @State private var showPreview = false
    @State private var showPills = false

    private var isActive: Bool { pageIndex == currentPage }

    var body: some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()
                .frame(height: HLSpacing.sm)

            // Preview card at top
            preview()
                .opacity(showPreview ? 1 : 0)
                .offset(y: showPreview ? 0 : -30)

            // Feature pills between preview and title
            if showPills {
                featurePills
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Title + subtitle at bottom
            VStack(spacing: HLSpacing.sm) {
                Text(page.title)
                    .font(HLFont.title1())
                    .foregroundColor(.hlTextPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)

                Text(page.subtitle)
                    .font(HLFont.body())
                    .foregroundColor(.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, HLSpacing.md)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 15)
            }

            Spacer()
                .frame(height: HLSpacing.md)
        }
        .padding(.horizontal, HLSpacing.md)
        .onAppear { runAnimations() }
        .onChange(of: currentPage) { _, newPage in
            if newPage == pageIndex {
                // Reset and replay
                showPreview = false
                showTitle = false
                showPills = false
                runAnimations()
            }
        }
    }

    private func runAnimations() {
        withAnimation(HLAnimation.bouncy.delay(0.15)) {
            showPreview = true
        }
        withAnimation(HLAnimation.standard.delay(0.4)) {
            showTitle = true
        }
        withAnimation(HLAnimation.standard.delay(0.7)) {
            showPills = true
        }
    }

    private var pills: [(icon: String, text: String, color: Color)] {
        if page.isStreakPreview {
            return [
                ("flame.fill", "Streaks", .hlFlame),
                ("star.fill", "XP", .hlGold),
                ("scroll.fill", "Quests", .hlPrimary)
            ]
        } else if page.isSleepPreview {
            return [
                ("moon.fill", "Sleep Log", .hlSleep),
                ("chart.bar.fill", "Analytics", .hlPrimary),
                ("link", "Correlation", .hlFitness)
            ]
        } else {
            return [
                ("person.2.fill", "Friends", .hlPrimary),
                ("trophy.fill", "Leaderboard", .hlGold),
                ("flag.fill", "Challenges", .hlFlame)
            ]
        }
    }

    private var featurePills: some View {
        HStack(spacing: HLSpacing.sm) {
            ForEach(Array(pills.enumerated()), id: \.offset) { index, pill in
                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: pill.icon)
                        .font(.system(size: min(sortIconSize, 15), weight: .semibold))
                        .foregroundStyle(pill.color)
                    Text(pill.text)
                        .font(HLFont.caption(.semibold))
                        .foregroundStyle(Color.hlTextPrimary)
                }
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xs)
                .background(pill.color.opacity(0.1))
                .cornerRadius(HLRadius.full)
            }
        }
    }
}

// MARK: - Streak Preview Content (with XP fill + Level Up animation)

private struct StreakPreviewContent: View {
    @ScaledMetric(relativeTo: .caption) private var tinyIconSize: CGFloat = 10
    @ScaledMetric(relativeTo: .caption) private var sortIconSize: CGFloat = 11
    @ScaledMetric(relativeTo: .caption) private var smallIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var cardIconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .title3) private var playIconSize: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var iconButtonSize: CGFloat = 40
    let isActive: Bool

    // Animation phases
    @State private var showHabitCard = false
    @State private var habitChecked = false
    @State private var showXPFloat = false
    @State private var streakCount = 0
    @State private var xpProgress: Double = 0.65
    @State private var showLevelUp = false
    @State private var levelText = "LV8"
    @State private var questCompleted = false
    @State private var streakTimer: Timer?

    var body: some View {
        VStack(spacing: HLSpacing.sm) {
            // 1. Mini habit card with auto-check
            if showHabitCard {
                HStack(spacing: HLSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Color.hlMindfulness.opacity(0.15))
                            .frame(width: min(iconButtonSize, 56), height: min(iconButtonSize, 56))
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: min(cardIconSize, 22)))
                            .foregroundStyle(Color.hlMindfulness)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Morning Meditation")
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlTextPrimary)
                        HStack(spacing: HLSpacing.xxs) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: min(tinyIconSize, 14)))
                                .foregroundStyle(Color.hlFlame)
                            Text("32 days")
                                .font(HLFont.caption())
                                .foregroundStyle(Color.hlTextSecondary)
                        }
                    }

                    Spacer()

                    // Checkmark animation
                    ZStack {
                        Circle()
                            .stroke(habitChecked ? Color.hlPrimary : Color.hlDivider, lineWidth: 3)
                            .frame(width: 32, height: 32)
                        if habitChecked {
                            Circle()
                                .fill(Color.hlPrimary)
                                .frame(width: 24, height: 24)
                            Image(systemName: "checkmark")
                                .font(.system(size: min(smallIconSize, 16), weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .scaleEffect(habitChecked ? 1.15 : 1.0)
                }
                .padding(HLSpacing.sm)
                .background(Color.hlSurface)
                .cornerRadius(HLRadius.lg)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // 2. Floating "+10 XP" after check
            if showXPFloat {
                Text("+10 XP")
                    .font(HLFont.caption(.bold))
                    .foregroundStyle(Color.hlGold)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // 3. Streak counter
            HStack(spacing: HLSpacing.md) {
                Image(systemName: "flame.fill")
                    .font(.system(size: min(playIconSize, 32), weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [.hlFlame, .hlGold], startPoint: .bottom, endPoint: .top)
                    )
                    .scaleEffect(habitChecked && streakCount == 33 ? 1.2 : 1.0)

                HStack(alignment: .firstTextBaseline, spacing: HLSpacing.xxs) {
                    Text("\(streakCount)")
                        .font(HLFont.title1())
                        .contentTransition(.numericText(value: Double(streakCount)))
                        .animation(.snappy, value: streakCount)
                    Text("day streak")
                        .font(HLFont.subheadline())
                        .foregroundColor(.hlTextSecondary)
                }

                Spacer()
            }
            .padding(HLSpacing.sm)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.lg)

            // 4. XP bar with level up
            HStack(spacing: HLSpacing.sm) {
                Text(levelText)
                    .font(HLFont.caption2(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, HLSpacing.xs)
                    .padding(.vertical, 3)
                    .background(Color.hlPrimary)
                    .cornerRadius(HLRadius.full)
                    .scaleEffect(showLevelUp ? 1.3 : 1.0)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: HLRadius.full)
                            .fill(Color.hlDivider)
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: HLRadius.full)
                            .fill(LinearGradient(colors: [.hlPrimary, .hlGold], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * xpProgress, height: 6)
                    }
                }
                .frame(height: 6)

                if showLevelUp {
                    Text("LEVEL UP!")
                        .font(HLFont.caption2(.bold))
                        .foregroundStyle(Color.hlGold)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.sm)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.lg)

            // 5. Quest completion
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: questCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(questCompleted ? Color.hlPrimary : Color.hlDivider)
                Text("Streak Guardian")
                    .font(HLFont.callout(.medium))
                    .foregroundStyle(questCompleted ? Color.hlTextTertiary : Color.hlTextPrimary)
                    .strikethrough(questCompleted)
                Spacer()
                Text("+100 XP")
                    .font(HLFont.caption(.bold))
                    .foregroundStyle(questCompleted ? Color.hlPrimary : Color.hlGold)
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.sm)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.lg)
        }
        .padding(.horizontal, HLSpacing.md)
        .onAppear { if isActive { runSequence() } }
        .onDisappear { streakTimer?.invalidate(); streakTimer = nil }
        .onChange(of: isActive) { _, active in
            if active { resetAndRun() } else { streakTimer?.invalidate(); streakTimer = nil }
        }
    }

    private func resetAndRun() {
        streakTimer?.invalidate()
        showHabitCard = false
        habitChecked = false
        showXPFloat = false
        streakCount = 0
        xpProgress = 0.65
        showLevelUp = false
        levelText = "LV8"
        questCompleted = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { runSequence() }
    }

    private func runSequence() {
        // Phase 1: Habit card appears (0.3s)
        withAnimation(HLAnimation.bouncy.delay(0.3)) {
            showHabitCard = true
        }

        // Phase 2: Auto-check the habit (1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(HLAnimation.bouncy) {
                habitChecked = true
            }
        }

        // Phase 3: "+10 XP" floats up (2.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(HLAnimation.spring) {
                showXPFloat = true
            }
        }

        // Phase 4: Streak counter 32→33 (2.3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            streakCount = 32
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.snappy) {
                    streakCount = 33
                }
            }
        }

        // Phase 5: XP bar fills → Level Up (3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(HLAnimation.spring) {
                showXPFloat = false
            }
            withAnimation(.easeInOut(duration: 1.0)) {
                xpProgress = 1.0
            }
        }

        // Phase 6: Level Up burst (4.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
            withAnimation(HLAnimation.bouncy) {
                showLevelUp = true
                levelText = "LV9"
            }
            withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
                xpProgress = 0.12
            }
        }

        // Phase 7: Quest completes (5.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(HLAnimation.spring) {
                questCompleted = true
                showLevelUp = false
            }
        }
    }
}

// MARK: - Sleep Preview Content (with animated duration + correlation count-up)

private struct SleepPreviewContent: View {
    @ScaledMetric(relativeTo: .caption) private var smallIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var badgeIconSize: CGFloat = 14
    let isActive: Bool
    @State private var sleepHours = 0
    @State private var sleepMinutes = 0
    @State private var showMood = false
    @State private var showTimes = false
    @State private var showInsight = false
    @State private var correlationPercent = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: HLSpacing.sm) {
            // Mini sleep card
            VStack(spacing: HLSpacing.sm) {
                HStack {
                    Text("Last Night")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                    Spacer()
                    if showMood {
                        Text("😊")
                            .font(HLFont.title3())
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                // Animated duration
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(sleepHours)")
                        .font(HLFont.title1())
                        .foregroundStyle(Color.hlSleep)
                        .contentTransition(.numericText(value: Double(sleepHours)))
                        .animation(.snappy, value: sleepHours)
                    Text("h ")
                        .font(HLFont.body())
                        .foregroundStyle(Color.hlSleep.opacity(0.7))
                    Text("\(sleepMinutes)")
                        .font(HLFont.title1())
                        .foregroundStyle(Color.hlSleep)
                        .contentTransition(.numericText(value: Double(sleepMinutes)))
                        .animation(.snappy, value: sleepMinutes)
                    Text("m")
                        .font(HLFont.body())
                        .foregroundStyle(Color.hlSleep.opacity(0.7))
                }

                if showTimes {
                    HStack(spacing: HLSpacing.lg) {
                        HStack(spacing: HLSpacing.xxs) {
                            Image(systemName: "bed.double.fill")
                                .font(.system(size: min(smallIconSize, 16)))
                                .foregroundStyle(Color.hlTextTertiary)
                            Text("23:04")
                                .font(HLFont.caption())
                                .foregroundStyle(Color.hlTextSecondary)
                        }
                        HStack(spacing: HLSpacing.xxs) {
                            Image(systemName: "sun.horizon.fill")
                                .font(.system(size: min(smallIconSize, 16)))
                                .foregroundStyle(Color.hlTextTertiary)
                            Text("06:46")
                                .font(HLFont.caption())
                                .foregroundStyle(Color.hlTextSecondary)
                        }
                    }
                    .transition(.opacity)
                }
            }
            .padding(HLSpacing.md)
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.lg)

            // Correlation insight with animated percentage
            if showInsight {
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: "link")
                        .font(.system(size: min(badgeIconSize, 18), weight: .semibold))
                        .foregroundStyle(Color.hlSleep)
                    Text("You complete ")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary) +
                    Text("\(correlationPercent)%")
                        .font(HLFont.caption(.bold))
                        .foregroundStyle(Color.hlSleep) +
                    Text(" more habits on days you sleep 7+ hours")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextSecondary)
                }
                .padding(HLSpacing.md)
                .background(Color.hlSleep.opacity(0.08))
                .cornerRadius(HLRadius.lg)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, HLSpacing.md)
        .onAppear { if isActive { runSequence() } }
        .onDisappear { timer?.invalidate(); timer = nil }
        .onChange(of: isActive) { _, active in
            if active { resetAndRun() } else { timer?.invalidate(); timer = nil }
        }
    }

    private func resetAndRun() {
        timer?.invalidate()
        sleepHours = 0
        sleepMinutes = 0
        showMood = false
        showTimes = false
        showInsight = false
        correlationPercent = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { runSequence() }
    }

    private func runSequence() {
        // Phase 1: Hours count up 0→7 (0.5s-1.5s)
        var h = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { t in
            h += 1
            withAnimation(.snappy) { sleepHours = h }
            if h >= 7 {
                t.invalidate()
                // Phase 2: Minutes count to 42 (fast)
                var m = 0
                timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { t2 in
                    m += 3
                    if m > 42 { m = 42 }
                    withAnimation(.snappy) { sleepMinutes = m }
                    if m >= 42 { t2.invalidate() }
                }
            }
        }

        // Phase 3: Mood emoji appears (2.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(HLAnimation.bouncy) { showMood = true }
        }

        // Phase 4: Bedtime/wake times appear (3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(HLAnimation.standard) { showTimes = true }
        }

        // Phase 5: Correlation insight slides up with count-up (3.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            withAnimation(HLAnimation.spring) { showInsight = true }
            // Count up 0→40%
            var pct = 0
            Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { t in
                pct += 2
                if pct > 40 { pct = 40 }
                correlationPercent = pct
                if pct >= 40 { t.invalidate() }
            }
        }
    }
}

private struct AnimatedOnboardingPage: View {
    @ScaledMetric(relativeTo: .caption) private var smallIconSize: CGFloat = 12
    let page: OnboardingPage
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showDecorations = false
    @State private var pulseGlow = false
    @State private var floatOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var outerCircleSize: CGFloat = 200
    @ScaledMetric(relativeTo: .largeTitle) private var innerCircleSize: CGFloat = 160
    @ScaledMetric(relativeTo: .largeTitle) private var iconFontSize: CGFloat = 60

    var body: some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()

            // Animated icon with floating + glow
            ZStack {
                Circle()
                    .stroke(page.accentColor.opacity(0.15), lineWidth: 2)
                    .frame(width: min(outerCircleSize, 220), height: min(outerCircleSize, 220))
                    .scaleEffect(pulseGlow ? 1.05 : 0.95)
                    .opacity(pulseGlow ? 0.3 : 0.6)

                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: min(innerCircleSize, 180), height: min(innerCircleSize, 180))
                    .hlGlow(page.accentColor, radius: 20, isActive: pulseGlow)

                if let emoji = page.emoji, !emoji.isEmpty {
                    Text(emoji)
                        .font(.system(size: min(iconFontSize, 66)))
                        .scaleEffect(showIcon ? 1.0 : 0.3)
                        .opacity(showIcon ? 1 : 0)
                } else {
                    Image(systemName: page.systemImage)
                        .font(.system(size: min(iconFontSize, 66), weight: .medium))
                        .foregroundStyle(page.accentColor)
                        .scaleEffect(showIcon ? 1.0 : 0.3)
                        .opacity(showIcon ? 1 : 0)
                }

            }
            .offset(y: floatOffset)

            Spacer()
                .frame(height: HLSpacing.lg)

            // Feature pills
            if showDecorations {
                featurePills
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
                .frame(height: HLSpacing.sm)

            // Text
            VStack(spacing: HLSpacing.sm) {
                Text(page.title)
                    .font(HLFont.title1())
                    .foregroundColor(.hlTextPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)

                Text(page.subtitle)
                    .font(HLFont.body())
                    .foregroundColor(.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, HLSpacing.lg)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 15)
            }

            Spacer()
        }
        .onAppear { startAnimations() }
    }

    private func startAnimations() {
        withAnimation(HLAnimation.bouncy.delay(0.1)) {
            showIcon = true
        }
        withAnimation(HLAnimation.standard.delay(0.4)) {
            showTitle = true
        }
        withAnimation(HLAnimation.standard.delay(0.6)) {
            showSubtitle = true
        }
        withAnimation(HLAnimation.standard.delay(0.9)) {
            showDecorations = true
        }
        guard !reduceMotion else { return }
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            floatOffset = -6
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            pulseGlow = true
        }
    }

    @ViewBuilder
    private var featurePills: some View {
        let pills: [(icon: String, text: String, color: Color)] = {
            if page.systemImage == "heart.slash" {
                return [
                    ("lock.shield.fill", "Private", .hlSuccess),
                    ("gamecontroller.fill", "Gamified", .hlPrimary),
                    ("bolt.fill", "Free", .hlGold)
                ]
            } else {
                // Track Everything (merged features page)
                return [
                    ("flame.fill", "Streaks", .hlFlame),
                    ("moon.stars.fill", "Sleep", .hlSleep),
                    ("chart.bar.fill", "Analytics", .hlPrimary)
                ]
            }
        }()

        HStack(spacing: HLSpacing.sm) {
            ForEach(Array(pills.enumerated()), id: \.offset) { index, pill in
                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: pill.icon)
                        .font(.system(size: min(smallIconSize, 16), weight: .semibold))
                        .foregroundStyle(pill.color)
                    Text(pill.text)
                        .font(HLFont.caption(.semibold))
                        .foregroundStyle(Color.hlTextPrimary)
                }
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xs)
                .background(pill.color.opacity(0.1))
                .cornerRadius(HLRadius.full)
                .hlStaggeredAppear(index: index)
            }
        }
    }

}

// MARK: - Level Up Preview Page

private struct LevelUpPreviewPage: View {
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 60
    @ScaledMetric(relativeTo: .body) private var mediumIconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .body) private var badgeSize: CGFloat = 44
    @ScaledMetric(relativeTo: .title) private var celebrationCircleSize: CGFloat = 140
    let page: OnboardingPage
    let isActive: Bool
    @State private var animateXP = false
    @State private var xpProgress: Double = 0
    @State private var showLevel = false
    @State private var showBadges = false

    var body: some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: min(celebrationCircleSize, 180), height: min(celebrationCircleSize, 180))
                    .hlGlow(page.accentColor, radius: 20, isActive: true)

                Image(systemName: page.systemImage)
                    .font(.system(size: min(heroIconSize, 72), weight: .medium))
                    .foregroundColor(page.accentColor)
                    .scaleEffect(showLevel ? 1.0 : 0.5)
                    .animation(HLAnimation.bouncy.delay(0.2), value: showLevel)
            }

            VStack(spacing: HLSpacing.sm) {
                HStack(spacing: HLSpacing.sm) {
                    Text("LV1")
                        .font(HLFont.caption2(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, HLSpacing.xs)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(HLRadius.full)
                        .scaleEffect(showLevel ? 1.0 : 0.0)
                        .animation(HLAnimation.bouncy.delay(0.4), value: showLevel)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: HLRadius.full)
                                .fill(Color.hlDivider)
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: HLRadius.full)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.hlPrimary, Color.hlGold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * xpProgress, height: 8)
                        }
                    }
                    .frame(height: 8)

                    if animateXP {
                        Text("+10 XP")
                            .font(HLFont.caption(.bold))
                            .foregroundStyle(Color.hlGold)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, HLSpacing.xl)

                if showBadges {
                    HStack(spacing: HLSpacing.sm) {
                        achievementBadge(icon: "flame.fill", color: .hlFlame, label: "Streaks")
                        achievementBadge(icon: "star.fill", color: .hlGold, label: "Achievements")
                        achievementBadge(icon: "chart.line.uptrend.xyaxis", color: .hlPrimary, label: "Progress")
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            Spacer()
                .frame(height: HLSpacing.md)

            VStack(spacing: HLSpacing.sm) {
                Text(page.title)
                    .font(HLFont.title1())
                    .foregroundColor(.hlTextPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(HLFont.body())
                    .foregroundColor(.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, HLSpacing.lg)
            }

            Spacer()
        }
        .onChange(of: isActive) { oldVal, newVal in
            if newVal && !oldVal {
                resetAndRun()
            }
        }
        .onAppear {
            if isActive { runAnimations() }
        }
    }

    private func resetAndRun() {
        animateXP = false
        xpProgress = 0
        showLevel = false
        showBadges = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            runAnimations()
        }
    }

    private func runAnimations() {
        withAnimation(HLAnimation.standard.delay(0.3)) {
            showLevel = true
        }
        withAnimation(.easeOut(duration: 1.2).delay(0.8)) {
            xpProgress = 0.65
        }
        withAnimation(HLAnimation.celebration.delay(1.0)) {
            animateXP = true
        }
        withAnimation(HLAnimation.standard.delay(1.6)) {
            showBadges = true
        }
    }

    private func achievementBadge(icon: String, color: Color, label: String) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: min(mediumIconSize, 24), weight: .semibold))
                .foregroundColor(color)
                .frame(width: min(badgeSize, 56), height: min(badgeSize, 56))
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(label)
                .font(HLFont.caption2())
                .foregroundColor(.hlTextTertiary)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .modelContainer(for: [Habit.self, UserProfile.self], inMemory: true)
}
