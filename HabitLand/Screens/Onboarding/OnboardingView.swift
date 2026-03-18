import SwiftUI

// MARK: - Onboarding Page Model

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let emoji: String?
    let title: String
    let subtitle: String
    let accentColor: Color
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showStarterHabits = false
    var onComplete: () -> Void = {}

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "",
            emoji: "🌱",
            title: "Welcome to HabitLand",
            subtitle: "Build better habits, sleep well, and level up your life — one day at a time."
        , accentColor: .hlPrimary),
        OnboardingPage(
            systemImage: "checkmark.circle.fill",
            emoji: nil,
            title: "Track Your Habits",
            subtitle: "Create daily habits, track your streaks, and watch your consistency grow over time."
        , accentColor: .hlFitness),
        OnboardingPage(
            systemImage: "moon.fill",
            emoji: nil,
            title: "Sleep Better",
            subtitle: "Log your sleep, discover patterns, and optimize your rest for peak performance."
        , accentColor: .hlSleep),
        OnboardingPage(
            systemImage: "trophy.fill",
            emoji: nil,
            title: "Level Up",
            subtitle: "Earn XP, unlock achievements, climb leaderboards, and challenge your friends."
        , accentColor: .hlGold),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        onComplete()
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
                    pageView(page)
                        .tag(index)
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
                currentPage == pages.count - 1 ? "Get Started" : "Next",
                icon: currentPage == pages.count - 1 ? nil : "arrow.right",
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
            StarterHabitsView {
                onComplete()
            }
        }
    }

    // MARK: - Page View

    @ViewBuilder
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()

            // Illustration area
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

            // Text content
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
}

// MARK: - Preview

#Preview {
    OnboardingView()
}
