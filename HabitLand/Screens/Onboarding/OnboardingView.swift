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

    init(systemImage: String, emoji: String? = nil, title: String, subtitle: String, accentColor: Color, isLevelUpPage: Bool = false) {
        self.systemImage = systemImage
        self.emoji = emoji
        self.title = title
        self.subtitle = subtitle
        self.accentColor = accentColor
        self.isLevelUpPage = isLevelUpPage
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }
    @State private var showStarterHabits = false
    @State private var userName = ""
    @State private var habitsCreatedCount = 0
    @FocusState private var nameFieldFocused: Bool
    var onComplete: () -> Void = {}

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "",
            emoji: "🌱",
            title: "Welcome to HabitLand",
            subtitle: "Build better habits, sleep well, and level up your life — one day at a time.",
            accentColor: .hlPrimary
        ),
        OnboardingPage(
            systemImage: "checkmark.circle.fill",
            title: "Track Your Habits",
            subtitle: "Create daily habits, track your streaks, and watch your consistency grow over time.",
            accentColor: .hlFitness
        ),
        OnboardingPage(
            systemImage: "moon.fill",
            title: "Sleep Better",
            subtitle: "Log your sleep, discover patterns, and optimize your rest for peak performance.",
            accentColor: .hlSleep
        ),
        OnboardingPage(
            systemImage: "trophy.fill",
            title: "Level Up Your Life",
            subtitle: "Every habit you complete earns XP. Level up, unlock achievements, and watch yourself grow.",
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

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        showStarterHabits = true
                    }
                    .font(HLFont.callout(.medium))
                    .foregroundColor(.hlTextSecondary)
                    .padding(.trailing, HLSpacing.lg)
                    .padding(.top, HLSpacing.md)
                }
            }
            .frame(height: 44)

            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    if index == pages.count - 1 {
                        nameEntryPage(page)
                            .tag(index)
                    } else if page.isLevelUpPage {
                        levelUpPageView(page)
                            .tag(index)
                    } else {
                        pageView(page)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(HLAnimation.gentleSpring, value: currentPage)

            // Page indicators
            HStack(spacing: HLSpacing.xs) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.hlPrimary : Color.hlDivider)
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(HLAnimation.standard, value: currentPage)
                }
            }
            .padding(.bottom, HLSpacing.xl)

            // Next / Get Started button
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
                    // Save name before showing starter habits
                    let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty, let profile = profile {
                        profile.name = trimmed
                        profile.username = "@\(trimmed.lowercased().replacingOccurrences(of: " ", with: ""))"
                        try? modelContext.save()
                    }
                    showStarterHabits = true
                }
            }
            .disabled(currentPage == pages.count - 1 && userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .fullScreenCover(isPresented: $showStarterHabits) {
            StarterHabitsView { count in
                habitsCreatedCount = count
                showStarterHabits = false
            }
            .onDisappear {
                if habitsCreatedCount > 0 {
                    awardFirstXP()
                }
                onComplete()
            }
            .hlSheetContent()
        }
    }

    // MARK: - Standard Page View (with animations)

    @ViewBuilder
    private func pageView(_ page: OnboardingPage) -> some View {
        AnimatedOnboardingPage(page: page)
            .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Level Up Page (animated XP preview)

    @ViewBuilder
    private func levelUpPageView(_ page: OnboardingPage) -> some View {
        LevelUpPreviewPage(page: page)
            .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Name Entry Page (inline in onboarding)

    @ViewBuilder
    private func nameEntryPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()

            Image(systemName: page.systemImage)
                .font(.system(size: 56))
                .foregroundColor(page.accentColor)
                .frame(width: 96, height: 96)
                .background(page.accentColor.opacity(0.12))
                .clipShape(Circle())

            Text(page.title)
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text(page.subtitle)
                .font(HLFont.subheadline())
                .foregroundColor(.hlTextSecondary)
                .multilineTextAlignment(.center)

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
                // Outer pulse ring
                Circle()
                    .stroke(page.accentColor.opacity(0.15), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseGlow ? 1.1 : 0.9)
                    .opacity(pulseGlow ? 0 : 0.6)

                // Background circle
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: 160, height: 160)
                    .hlGlow(page.accentColor, radius: pulseGlow ? 30 : 15, isActive: true)

                // Icon or emoji
                if let emoji = page.emoji {
                    Text(emoji)
                        .font(.system(size: 72))
                        .scaleEffect(showIcon ? 1.0 : 0.3)
                        .opacity(showIcon ? 1 : 0)
                } else {
                    Image(systemName: page.systemImage)
                        .font(.system(size: 60, weight: .medium))
                        .foregroundStyle(page.accentColor)
                        .scaleEffect(showIcon ? 1.0 : 0.3)
                        .opacity(showIcon ? 1 : 0)
                }

                // Floating particles
                if showDecorations {
                    floatingParticles
                }
            }
            .offset(y: floatOffset)

            Spacer()
                .frame(height: HLSpacing.lg)

            // Feature pills (themed per page)
            if showDecorations {
                featurePills
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
                .frame(height: HLSpacing.sm)

            // Text with staggered entry
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

    // MARK: - Animations

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
        // Continuous floating
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.3)) {
            floatOffset = -8
        }
        // Continuous pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
            pulseGlow = true
        }
    }

    // MARK: - Feature Pills (themed per page)

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
            } else if page.systemImage == "checkmark.circle.fill" {
                // Track habits page
                return [
                    ("flame.fill", "Streaks", .hlFlame),
                    ("bell.fill", "Reminders", .hlInfo),
                    ("chart.bar.fill", "Analytics", .hlPrimary)
                ]
            } else {
                // Sleep page
                return [
                    ("moon.stars.fill", "Quality Score", .hlSleep),
                    ("chart.xyaxis.line", "Trends", .hlMindfulness),
                    ("sparkles", "Insights", .hlGold)
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

    // MARK: - Floating Particles

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

            // Animated trophy
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

            // Animated XP bar demo
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

                // Achievement badges preview
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

            // Text
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
            // Animate the XP bar filling up
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
