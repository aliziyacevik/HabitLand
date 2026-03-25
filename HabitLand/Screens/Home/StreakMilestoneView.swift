import SwiftUI

// MARK: - Streak Milestone View

struct StreakMilestoneView: View {
    let streakDays: Int
    let isPro: Bool
    var onDismiss: () -> Void

    @State private var showPaywall = false
    @State private var showConfetti = false
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var textOpacity: Double = 0
    @State private var textScale: CGFloat = 0.5

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 56
    @ScaledMetric(relativeTo: .caption2) private var confettiSize: CGFloat = 8

    // MARK: - Milestone Tracking

    private static let shownMilestonesKey = "shownStreakMilestones"

    static func shouldShow(for streak: Int) -> Bool {
        [7, 14, 30].contains(streak) && !shownMilestones.contains(streak)
    }

    static func markShown(_ milestone: Int) {
        var milestones = shownMilestones
        milestones.insert(milestone)
        UserDefaults.standard.set(Array(milestones), forKey: shownMilestonesKey)
    }

    private static var shownMilestones: Set<Int> {
        Set(UserDefaults.standard.array(forKey: shownMilestonesKey) as? [Int] ?? [])
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Confetti overlay
            ForEach(confettiPieces) { piece in
                confettiShape(piece)
                    .position(x: piece.x, y: piece.y)
                    .rotationEffect(.degrees(piece.rotation))
            }

            // Content
            VStack(spacing: HLSpacing.xl) {
                Spacer()

                // Icon
                Image(systemName: streakDays >= 30 ? "crown.fill" : "flame.fill")
                    .font(.system(size: min(iconSize, 64)))
                    .foregroundStyle(Color.hlGold)
                    .frame(width: min(iconSize + 24, 88), height: min(iconSize + 24, 88))
                    .background(
                        Circle()
                            .fill(Color.hlGold.opacity(0.15))
                    )
                    .accessibilityHidden(true)

                // Title
                Text("\(streakDays)-Day Streak!")
                    .font(HLFont.title1(.bold))
                    .foregroundStyle(Color.hlTextPrimary)
                    .minimumScaleFactor(0.75)

                // Subtitle
                Text(subtitleText)
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HLSpacing.lg)

                // Pro CTA or encouragement
                if !isPro {
                    proCTACard
                } else {
                    Text("Keep Going! Your consistency is inspiring.")
                        .font(HLFont.subheadline(.medium))
                        .foregroundStyle(Color.hlTextSecondary)
                        .padding(.top, HLSpacing.sm)
                }

                Spacer()

                // Dismiss button
                Button {
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(HLFont.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HLSpacing.md)
                        .background(Color.hlPrimary)
                        .cornerRadius(HLRadius.lg)
                }
                .accessibilityLabel("Continue")
                .padding(.horizontal, HLSpacing.lg)
                .padding(.bottom, HLSpacing.xl)
            }
            .opacity(textOpacity)
            .scaleEffect(textScale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.hlBackground)
        .sheet(isPresented: $showPaywall) {
            PaywallView(context: .analytics)
                .hlSheetContent()
        }
        .onAppear {
            HLHaptics.heavy()
            startConfetti()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                textOpacity = 1
                textScale = 1.0
            }
        }
    }

    // MARK: - Subtitle

    private var subtitleText: String {
        switch streakDays {
        case 7: return "A full week! You're building real momentum."
        case 14: return "Two weeks strong! This is becoming a habit."
        case 30: return "One month! You've proven your commitment."
        default: return "Amazing consistency! Keep it up."
        }
    }

    // MARK: - Pro CTA Card

    private var proCTACard: some View {
        VStack(spacing: HLSpacing.sm) {
            Text("Unlock detailed stats with Pro")
                .font(HLFont.subheadline(.medium))
                .foregroundStyle(Color.hlTextPrimary)

            Button {
                showPaywall = true
            } label: {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .accessibilityHidden(true)
                    Text("See My Progress")
                        .font(HLFont.headline())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, HLSpacing.xl)
                .padding(.vertical, HLSpacing.sm)
                .background(
                    LinearGradient(
                        colors: [Color.hlPrimary, Color.hlPrimaryDark],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(HLRadius.lg)
            }
            .accessibilityLabel("See My Progress, opens Pro upgrade")
        }
        .padding(HLSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(Color.hlSurface)
                .hlShadow(HLShadow.sm)
        )
        .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Confetti

    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let color: Color
        let size: CGFloat
        let rotation: Double
        let shape: Int
    }

    @ViewBuilder
    private func confettiShape(_ piece: ConfettiPiece) -> some View {
        switch piece.shape {
        case 0:
            Circle()
                .fill(piece.color)
                .frame(width: piece.size, height: piece.size)
        case 1:
            RoundedRectangle(cornerRadius: 1)
                .fill(piece.color)
                .frame(width: piece.size, height: piece.size * 1.5)
        default:
            RoundedRectangle(cornerRadius: 2)
                .fill(piece.color)
                .frame(width: piece.size, height: piece.size)
                .rotationEffect(.degrees(45))
        }
    }

    private func startConfetti() {
        let screenWidth = UIScreen.main.bounds.width
        let colors: [Color] = [.hlPrimary, .hlGold, .hlFlame, .hlInfo, .hlMindfulness, .hlHealth]

        confettiPieces = (0..<30).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: -50...0),
                color: colors.randomElement() ?? .hlPrimary,
                size: CGFloat.random(in: min(confettiSize - 2, 5)...min(confettiSize + 2, 12)),
                rotation: Double.random(in: 0...360),
                shape: Int.random(in: 0...2)
            )
        }

        withAnimation(.easeIn(duration: 2.0)) {
            confettiPieces = confettiPieces.map { piece in
                var p = piece
                p.y = UIScreen.main.bounds.height + 50
                p.x += CGFloat.random(in: -80...80)
                return p
            }
        }
    }
}

// MARK: - Preview

#Preview("Free User - 7 Day") {
    StreakMilestoneView(streakDays: 7, isPro: false) { }
}

#Preview("Pro User - 30 Day") {
    StreakMilestoneView(streakDays: 30, isPro: true) { }
}
