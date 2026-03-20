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
    @State private var showStarterHabits = false
    @State private var habitsCreatedCount = 0
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
                    if page.isLevelUpPage {
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
                icon: currentPage == pages.count - 1 ? "arrow.right" : "arrow.right",
                style: .primary,
                size: .lg,
                isFullWidth: true
            ) {
                if currentPage < pages.count - 1 {
                    withAnimation(HLAnimation.standard) {
                        currentPage += 1
                    }
                } else {
                    showStarterHabits = true
                }
            }
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
        }
    }

    // MARK: - Standard Page View

    @ViewBuilder
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: 180, height: 180)
                    .hlGlow(page.accentColor, radius: 20, isActive: true)

                if let emoji = page.emoji {
                    Text(emoji)
                        .font(.system(size: 80))
                } else {
                    Image(systemName: page.systemImage)
                        .font(.system(size: 72, weight: .medium))
                        .foregroundColor(page.accentColor)
                }
            }

            Spacer()
                .frame(height: HLSpacing.xl)

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
        .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Level Up Page (animated XP preview)

    @ViewBuilder
    private func levelUpPageView(_ page: OnboardingPage) -> some View {
        LevelUpPreviewPage(page: page)
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
