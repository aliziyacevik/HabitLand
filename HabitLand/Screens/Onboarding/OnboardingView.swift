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

    init(systemImage: String, emoji: String? = nil, title: String, subtitle: String, accentColor: Color, isLevelUpPage: Bool = false, isLeaderboardPreview: Bool = false) {
        self.systemImage = systemImage
        self.emoji = emoji
        self.title = title
        self.subtitle = subtitle
        self.accentColor = accentColor
        self.isLevelUpPage = isLevelUpPage
        self.isLeaderboardPreview = isLeaderboardPreview
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }

    // Page state
    @State private var currentPage = 0
    // Steps: 0=pages, 1=habits, 2=reminder+notif, 3=theme, 4=trial, 5=complete
    @State private var currentStep = 0

    // Data collected
    @State private var userName = ""
    @State private var selectedAvatar = "🌱"
    @State private var habitsCreatedCount = 0
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()

    @FocusState private var nameFieldFocused: Bool
    var onComplete: () -> Void = {}

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "",
            emoji: "😩",
            title: "Always giving up\non habits?",
            subtitle: "You're not lazy. You just didn't have the right system. Until now.",
            accentColor: .hlPrimary
        ),
        OnboardingPage(
            systemImage: "",
            emoji: "🔥",
            title: "This time is different",
            subtitle: "Streaks keep you accountable. XP makes it fun. Friends make it social. Science makes it stick.",
            accentColor: .hlFlame
        ),
        OnboardingPage(
            systemImage: "moon.stars.fill",
            title: "Sleep better,\ndo more",
            subtitle: "Track your sleep and discover how rest affects your habits. Better sleep = more completions.",
            accentColor: .hlSleep
        ),
        OnboardingPage(
            systemImage: "person.2.fill",
            title: "Compete with\nfriends",
            subtitle: "Challenge your friends, climb the leaderboard, and nudge each other when motivation drops.",
            accentColor: .hlFitness,
            isLeaderboardPreview: true
        ),
        OnboardingPage(
            systemImage: "trophy.fill",
            title: "Level Up Your Life",
            subtitle: "Every habit you complete earns XP. Unlock achievements, new themes, and watch yourself grow.",
            accentColor: .hlGold,
            isLevelUpPage: true
        ),
        OnboardingPage(
            systemImage: "person.crop.circle.badge.plus",
            title: "What's your name?",
            subtitle: "This is how your friends will see you on the leaderboard.",
            accentColor: .hlPrimary
        ),
    ]

    private let avatarOptions = ["🌱", "😊", "😎", "🦊", "🐱", "🐶", "🦁", "🐼", "🦄", "🎯", "⭐", "🔥"]

    var body: some View {
        Group {
            switch currentStep {
            case 1:
                StarterHabitsView { count in
                    habitsCreatedCount = count
                    withAnimation(HLAnimation.gentleSpring) {
                        currentStep = 2
                    }
                }
            case 2:
                reminderSetupStep
            case 3:
                ThemeOnboardingView {
                    withAnimation(HLAnimation.gentleSpring) {
                        currentStep = 4
                    }
                }
            case 4:
                trialWelcomeStep
            case 5:
                OnboardingCompleteView(
                    habitsCreated: habitsCreatedCount
                ) {
                    if habitsCreatedCount > 0 {
                        awardFirstXP()
                    }
                    onComplete()
                }
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
                        withAnimation(HLAnimation.standard) {
                            currentPage -= 1
                        }
                    } label: {
                        HStack(spacing: HLSpacing.xxs) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
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
                    } else if page.isLeaderboardPreview {
                        leaderboardPreviewPage(page)
                            .tag(index)
                    } else {
                        pageView(page)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(HLAnimation.gentleSpring, value: currentPage)

            // Next / Choose My Habits button
            HLButton(
                currentPage == pages.count - 1 ? "Choose My Habits" : "Next",
                icon: "arrow.right",
                style: .primary,
                size: .lg,
                isFullWidth: true
            ) {
                if currentPage < pages.count - 1 {
                    withAnimation(HLAnimation.standard) {
                        currentPage += 1
                    }
                } else {
                    saveName()
                    withAnimation(HLAnimation.gentleSpring) {
                        currentStep = 1
                    }
                }
            }
            .disabled(currentPage == pages.count - 1 && userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: HLSpacing.xxs) {
            Text("Step \(currentPage + 1) of \(pages.count)")
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
                        .frame(width: geo.size.width * CGFloat(currentPage + 1) / CGFloat(pages.count), height: 4)
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
        LevelUpPreviewPage(page: page)
            .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Leaderboard Preview Page

    @ViewBuilder
    private func leaderboardPreviewPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: HLSpacing.md) {
            Spacer()

            Text(page.title)
                .font(HLFont.title1())
                .foregroundColor(.hlTextPrimary)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HLSpacing.md)

            // Mini leaderboard preview
            VStack(spacing: 0) {
                // Podium
                HStack(alignment: .bottom, spacing: HLSpacing.sm) {
                    onboardingPodiumPlace(name: "Mike", emoji: "🐻", xp: 640, rank: 2, color: .hlSilver, height: 48)
                    onboardingPodiumPlace(name: "Sarah", emoji: "🦊", xp: 810, rank: 1, color: .hlGold, height: 64, hasCrown: true)
                    onboardingPodiumPlace(name: "You", emoji: selectedAvatar, xp: 520, rank: 3, color: .hlBronze, height: 36)
                }
                .padding(HLSpacing.md)

                Divider()

                // Rankings
                VStack(spacing: 0) {
                    onboardingRankRow(rank: 4, name: "Emma", emoji: "🐼", xp: 380, streak: 14)
                    onboardingRankRow(rank: 5, name: "James", emoji: "🐸", xp: 210, streak: 5)
                }
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xs)
            }
            .background(Color.hlSurface)
            .cornerRadius(HLRadius.lg)
            .hlShadow(HLShadow.sm)
            .padding(.horizontal, HLSpacing.xl)

            Spacer()
        }
        .padding(.horizontal, HLSpacing.md)
    }

    private func onboardingPodiumPlace(name: String, emoji: String, xp: Int, rank: Int, color: Color, height: CGFloat, hasCrown: Bool = false) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            if hasCrown {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.hlGold)
            }

            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: rank == 1 ? 52 : 40, height: rank == 1 ? 52 : 40)
                Text(emoji)
                    .font(.system(size: rank == 1 ? 24 : 18))
            }

            Text(name)
                .font(HLFont.caption(.semibold))
                .foregroundColor(.hlTextPrimary)
                .lineLimit(1)

            Text("\(xp) XP")
                .font(HLFont.caption2())
                .foregroundColor(.hlTextSecondary)

            RoundedRectangle(cornerRadius: HLRadius.xs)
                .fill(color.opacity(0.25))
                .frame(height: height)
                .overlay(
                    Text("#\(rank)")
                        .font(HLFont.caption(.bold))
                        .foregroundColor(color)
                )
        }
        .frame(maxWidth: .infinity)
    }

    private func onboardingRankRow(rank: Int, name: String, emoji: String, xp: Int, streak: Int) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Text("\(rank)")
                .font(HLFont.caption(.bold))
                .foregroundColor(.hlTextTertiary)
                .frame(width: 20)

            ZStack {
                Circle()
                    .fill(Color.hlPrimary.opacity(0.1))
                    .frame(width: 32, height: 32)
                Text(emoji)
                    .font(.system(size: 16))
            }

            Text(name)
                .font(HLFont.subheadline(.medium))
                .foregroundColor(.hlTextPrimary)

            Spacer()

            HStack(spacing: HLSpacing.xxs) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.hlFlame)
                Text("\(streak)d")
                    .font(HLFont.caption2())
                    .foregroundColor(.hlTextSecondary)
            }

            Text("\(xp) XP")
                .font(HLFont.caption(.semibold))
                .foregroundColor(.hlTextSecondary)
        }
        .padding(.vertical, HLSpacing.xs)
    }

    // MARK: - Name Entry + Avatar Picker

    @ViewBuilder
    private func nameEntryPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()

            // Selected avatar display
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: 96, height: 96)

                Text(selectedAvatar)
                    .font(HLFont.largeTitle(.bold))
            }

            Text(page.title)
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text(page.subtitle)
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)

            // Avatar picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.xs) {
                    ForEach(avatarOptions, id: \.self) { emoji in
                        Button {
                            selectedAvatar = emoji
                            HLHaptics.selection()
                        } label: {
                            Text(emoji)
                                .font(HLFont.title1())
                                .frame(width: 48, height: 48)
                                .background(
                                    selectedAvatar == emoji
                                        ? Color.hlPrimary.opacity(0.15)
                                        : Color(.systemGray6)
                                )
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedAvatar == emoji ? Color.hlPrimary : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        }
                        .scaleEffect(selectedAvatar == emoji ? 1.1 : 1.0)
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
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        nameFieldFocused = true
                    }
                }

            Spacer()
        }
        .padding(.horizontal, HLSpacing.lg)
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

    private var reminderSetupStep: some View {
        VStack(spacing: HLSpacing.xl) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.hlPrimary)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: HLSpacing.sm) {
                Text("When should we\nremind you?")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Pick a time and we'll send you a daily reminder. You can change this in Settings.")
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HLSpacing.lg)
            }

            DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 150)

            Spacer()

            VStack(spacing: HLSpacing.sm) {
                Button {
                    saveReminderTime()
                    Task {
                        _ = await NotificationManager.shared.requestPermission()
                        await MainActor.run {
                            withAnimation(HLAnimation.gentleSpring) {
                                currentStep = 3
                            }
                        }
                    }
                } label: {
                    HStack(spacing: HLSpacing.xs) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16))
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
                        currentStep = 3
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

    private var trialWelcomeStep: some View {
        VStack(spacing: HLSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.hlGold.opacity(0.12))
                    .frame(width: 160, height: 160)

                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.hlGold)
            }

            VStack(spacing: HLSpacing.sm) {
                Text("7 Days of Pro\nOn Us!")
                    .font(HLFont.title1())
                    .foregroundStyle(Color.hlTextPrimary)
                    .multilineTextAlignment(.center)

                Text("You get full access to everything for 7 days:")
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: HLSpacing.sm) {
                trialFeatureRow(icon: "infinity", text: "Unlimited habits", color: .hlPrimary)
                trialFeatureRow(icon: "moon.stars.fill", text: "Sleep tracking & insights", color: .hlSleep)
                trialFeatureRow(icon: "person.2.fill", text: "Friends, leaderboard & challenges", color: .hlFitness)
                trialFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed analytics", color: .hlGold)
                trialFeatureRow(icon: "paintpalette.fill", text: "All themes & customization", color: .hlFlame)
            }
            .padding(.horizontal, HLSpacing.xl)

            Spacer()

            Button {
                withAnimation(HLAnimation.gentleSpring) {
                    currentStep = 5
                }
            } label: {
                Text("Start My Free Trial")
                    .font(HLFont.headline())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.md)
                    .background(Color.hlPrimary)
                    .cornerRadius(HLRadius.lg)
            }
            .padding(.horizontal, HLSpacing.xl)
            .padding(.bottom, HLSpacing.xxxl)
        }
    }

    private func trialFeatureRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 28)
            Text(text)
                .font(HLFont.body())
                .foregroundStyle(Color.hlTextPrimary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.hlSuccess)
        }
    }

    // MARK: - First XP Award

    private func awardFirstXP() {
        let xpAmount = habitsCreatedCount * 10
        guard xpAmount > 0 else { return }
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? modelContext.fetch(descriptor).first else { return }
        profile.xp += xpAmount
        try? modelContext.save()
    }
}

// MARK: - Animated Onboarding Page

private struct AnimatedOnboardingPage: View {
    let page: OnboardingPage
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showDecorations = false
    @State private var pulseGlow = false
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()

            // Animated icon with floating + glow
            ZStack {
                Circle()
                    .stroke(page.accentColor.opacity(0.15), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseGlow ? 1.1 : 0.9)
                    .opacity(pulseGlow ? 0 : 0.6)

                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: 160, height: 160)
                    .hlGlow(page.accentColor, radius: pulseGlow ? 30 : 15, isActive: true)

                if let emoji = page.emoji {
                    Text(emoji)
                        .font(HLFont.largeTitle(.bold))
                        .scaleEffect(showIcon ? 1.0 : 0.3)
                        .opacity(showIcon ? 1 : 0)
                } else {
                    Image(systemName: page.systemImage)
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(page.accentColor)
                        .scaleEffect(showIcon ? 1.0 : 0.3)
                        .opacity(showIcon ? 1 : 0)
                }

                if showDecorations {
                    floatingParticles
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
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)

                Text(page.subtitle)
                    .font(HLFont.body())
                    .foregroundColor(.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
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
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.3)) {
            floatOffset = -8
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
            pulseGlow = true
        }
    }

    @ViewBuilder
    private var featurePills: some View {
        let pills: [(icon: String, text: String, color: Color)] = {
            if page.emoji != nil {
                // Welcome page
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
                        .font(.system(size: 12, weight: .semibold))
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

    private var floatingParticles: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(page.accentColor.opacity(0.3))
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .offset(
                        x: CGFloat([-60, 70, -40, 55, -75][i]),
                        y: CGFloat([-50, -70, 60, 40, -30][i]) + floatOffset * CGFloat([1.2, -0.8, 1.5, -1.0, 0.7][i])
                    )
            }
        }
    }
}

// MARK: - Level Up Preview Page

private struct LevelUpPreviewPage: View {
    let page: OnboardingPage
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
                    .frame(width: 140, height: 140)
                    .hlGlow(page.accentColor, radius: 20, isActive: true)

                Image(systemName: page.systemImage)
                    .font(.system(size: 60, weight: .medium))
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
        .onAppear {
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
    }

    private func achievementBadge(icon: String, color: Color, label: String) -> some View {
        VStack(spacing: HLSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
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
