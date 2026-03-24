import SwiftUI
import UIKit
import AudioToolbox

// MARK: - Haptic Feedback

struct HLHaptics {
    private static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "habit_hapticFeedback") == nil
            || UserDefaults.standard.bool(forKey: "habit_hapticFeedback")
    }

    static func light() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func medium() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func heavy() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    static func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    static func selection() {
        guard isEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// Plays haptic + completion sound (respects user setting)
    static func completionSuccess() {
        success()
        if UserDefaults.standard.object(forKey: "habit_completionSound") == nil || UserDefaults.standard.bool(forKey: "habit_completionSound") {
            AudioServicesPlaySystemSound(1407) // Tink — short, satisfying completion tone
        }
    }

    /// Plays heavy haptic + achievement fanfare sound
    static func achievementUnlocked() {
        heavy()
        AudioServicesPlaySystemSound(1025) // Fanfare — celebratory achievement tone
    }
}

// MARK: - Enhanced Motion System

extension HLAnimation {
    // Interaction springs (buttons, toggles)
    static let microSpring = Animation.spring(response: 0.28, dampingFraction: 0.68)
    static let gentleSpring = Animation.spring(response: 0.45, dampingFraction: 0.78)

    // Entry/exit
    static let fadeIn = Animation.easeOut(duration: 0.25)
    static let slideIn = Animation.spring(response: 0.4, dampingFraction: 0.82)

    // Progress & rings
    static let progressFill = Animation.easeOut(duration: 0.8)
    static let ringGlow = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)

    // Gamification
    static let celebration = Animation.spring(response: 0.35, dampingFraction: 0.55)
    static let shimmerLoop = Animation.linear(duration: 1.8).repeatForever(autoreverses: false)

    // MARK: - Sheet Transitions
    static let sheetContentAppear = Animation.easeOut(duration: 0.3)
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0),
                    ],
                    startPoint: .init(x: phase - 0.5, y: 0.5),
                    endPoint: .init(x: phase + 0.5, y: 0.5)
                )
                .allowsHitTesting(false)
            )
            .clipped()
            .onAppear {
                withAnimation(HLAnimation.shimmerLoop) {
                    phase = 2
                }
            }
    }
}

extension View {
    func hlShimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Sheet Content Modifier

struct HLSheetContent: ViewModifier {
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)
            .animation(.spring(duration: 0.35, bounce: 0.0), value: appeared)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    appeared = true
                }
            }
    }
}

extension View {
    func hlSheetContent() -> some View {
        modifier(HLSheetContent())
    }
}

// MARK: - Skeleton Loader

struct SkeletonView: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = HLRadius.sm

    @State private var phase: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.hlDivider)
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.hlDivider,
                                Color.hlDivider.opacity(0.4),
                                Color.hlDivider,
                            ],
                            startPoint: .init(x: phase - 0.5, y: 0.5),
                            endPoint: .init(x: phase + 0.5, y: 0.5)
                        )
                    )
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }
}

// MARK: - Skeleton Card Loader

struct SkeletonCardView: View {
    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            SkeletonView(width: 44, height: 44, cornerRadius: 22)

            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                SkeletonView(width: 120, height: 14)
                SkeletonView(width: 80, height: 10)
            }

            Spacer()

            SkeletonView(width: 36, height: 36, cornerRadius: 18)
        }
        .hlCard()
    }
}

// MARK: - Skeleton Loading Group (Dashboard)

struct DashboardSkeletonView: View {
    var body: some View {
        VStack(spacing: HLSpacing.lg) {
            // Progress card skeleton
            HStack(spacing: HLSpacing.lg) {
                SkeletonView(width: 100, height: 100, cornerRadius: 50)
                VStack(alignment: .leading, spacing: HLSpacing.xs) {
                    SkeletonView(width: 130, height: 16)
                    SkeletonView(width: 180, height: 12)
                    SkeletonView(width: 100, height: 10)
                }
                Spacer()
            }
            .hlCard()

            // Motivation skeleton
            HStack(spacing: HLSpacing.sm) {
                SkeletonView(width: 36, height: 36, cornerRadius: 18)
                VStack(alignment: .leading, spacing: HLSpacing.xs) {
                    SkeletonView(width: 200, height: 14)
                    SkeletonView(width: 150, height: 10)
                }
                Spacer()
            }
            .hlCard()

            // Habit cards skeleton
            ForEach(0..<3, id: \.self) { _ in
                SkeletonCardView()
            }
        }
    }
}

// MARK: - Pulse Effect

struct PulseModifier: ViewModifier {
    let color: Color
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(color.opacity(isPulsing ? 0 : 0.3))
                    .scaleEffect(isPulsing ? 2.5 : 1.0)
                    .allowsHitTesting(false)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func hlPulse(color: Color = .hlPrimary) -> some View {
        modifier(PulseModifier(color: color))
    }
}

// MARK: - Glow Effect

struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(0.4) : .clear, radius: radius)
            .shadow(color: isActive ? color.opacity(0.2) : .clear, radius: radius * 1.5)
    }
}

extension View {
    func hlGlow(_ color: Color, radius: CGFloat = 8, isActive: Bool = true) -> some View {
        modifier(GlowModifier(color: color, radius: radius, isActive: isActive))
    }
}

// MARK: - Inner Highlight (Light Reflection on Cards)

struct InnerHighlightModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0),
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)
            )
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.05),
                                Color.clear,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
                    .allowsHitTesting(false)
            )
    }
}

extension View {
    func hlInnerHighlight() -> some View {
        modifier(InnerHighlightModifier())
    }
}

// MARK: - Glassmorphism

struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat = HLRadius.xl

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
            .hlShadow(HLShadow.lg)
    }
}

extension View {
    func hlGlass(cornerRadius: CGFloat = HLRadius.xl) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Staggered Appearance

struct StaggeredAppearanceModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : (reduceMotion ? 0 : 12))
            .onAppear {
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(HLAnimation.slideIn.delay(baseDelay + Double(index) * 0.06)) {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    func hlStaggeredAppear(index: Int, baseDelay: Double = 0.05) -> some View {
        modifier(StaggeredAppearanceModifier(index: index, baseDelay: baseDelay))
    }
}

// MARK: - Confetti Burst

struct ConfettiModifier: ViewModifier {
    @Binding var isActive: Bool
    let particleCount: Int

    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, rotation: Double, scale: CGFloat, opacity: Double)] = []

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    ForEach(particles, id: \.id) { p in
                        confettiPiece(for: p)
                    }
                }
                .allowsHitTesting(false)
            )
            .onChange(of: isActive) { _, newValue in
                if newValue { burst() }
            }
    }

    private func confettiPiece(for p: (id: Int, x: CGFloat, y: CGFloat, rotation: Double, scale: CGFloat, opacity: Double)) -> some View {
        let colors: [Color] = [.hlPrimary, .hlGold, .hlFlame, .hlInfo, .hlMindfulness]
        return Circle()
            .fill(colors[p.id % colors.count])
            .frame(width: 6, height: 6)
            .scaleEffect(p.scale)
            .opacity(p.opacity)
            .offset(x: p.x, y: p.y)
            .rotationEffect(.degrees(p.rotation))
    }

    private func burst() {
        particles = (0..<particleCount).map { i in
            (id: i, x: CGFloat(0), y: CGFloat(0), rotation: 0.0, scale: CGFloat(1.0), opacity: 1.0)
        }

        withAnimation(.easeOut(duration: 0.8)) {
            particles = particles.map { p in
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 40...100)
                return (
                    id: p.id,
                    x: cos(angle) * distance,
                    y: sin(angle) * distance - 20,
                    rotation: Double.random(in: -360...360),
                    scale: CGFloat.random(in: 0.3...0.8),
                    opacity: 0.0
                )
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isActive = false
            particles = []
        }
    }
}

extension View {
    func hlConfetti(isActive: Binding<Bool>, particleCount: Int = 20) -> some View {
        modifier(ConfettiModifier(isActive: isActive, particleCount: particleCount))
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dotScales: [CGFloat] = [1, 1, 1]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.hlTextTertiary)
                    .frame(width: 7, height: 7)
                    .scaleEffect(dotScales[i])
            }
        }
        .padding(.horizontal, HLSpacing.sm)
        .padding(.vertical, HLSpacing.xs)
        .background(Color.hlDivider)
        .cornerRadius(HLRadius.lg)
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        for i in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.4)
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.15)
            ) {
                dotScales[i] = 0.5
            }
        }
    }
}

// MARK: - Interactive Card Press Style

struct HLCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .hlShadow(configuration.isPressed ? HLShadow.sm : HLShadow.md)
            .animation(HLAnimation.microSpring, value: configuration.isPressed)
    }
}

// MARK: - Animated Checkmark

struct AnimatedCheckmark: View {
    let isCompleted: Bool
    let color: Color
    let size: CGFloat

    @State private var checkScale: CGFloat = 0
    @State private var ringScale: CGFloat = 1.0
    @State private var ringOpacity: Double = 0
    @State private var particlesVisible = false

    private let particleCount = 8

    var body: some View {
        ZStack {
            // Ripple ring
            Circle()
                .stroke(color, lineWidth: 2)
                .frame(width: size * 1.6, height: size * 1.6)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            // Burst particles
            ForEach(0..<particleCount, id: \.self) { i in
                Circle()
                    .fill(particleColor(i))
                    .frame(width: 4, height: 4)
                    .offset(particleOffset(index: i))
                    .opacity(particlesVisible ? 0 : 1)
                    .scaleEffect(particlesVisible ? 0.3 : 1)
            }

            // Main checkmark
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: size))
                .foregroundStyle(isCompleted ? color : Color.hlTextTertiary)
                .scaleEffect(checkScale)
        }
        .onChange(of: isCompleted) { _, newValue in
            if newValue {
                animateCompletion()
            } else {
                withAnimation(HLAnimation.microSpring) {
                    checkScale = 1.0
                }
            }
        }
        .onAppear {
            checkScale = 1.0
        }
    }

    private func animateCompletion() {
        // Step 1: Squish down
        withAnimation(.easeIn(duration: 0.1)) {
            checkScale = 0.6
        }
        // Step 2: Bounce up big
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.45)) {
                checkScale = 1.15
            }
            // Ripple
            withAnimation(.easeOut(duration: 0.5)) {
                ringScale = 2.0
                ringOpacity = 0.6
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                ringOpacity = 0
            }
            // Particles
            particlesVisible = false
            withAnimation(.easeOut(duration: 0.6)) {
                particlesVisible = true
            }
        }
        // Step 3: Settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                checkScale = 1.0
            }
        }
        // Reset particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            ringScale = 1.0
            particlesVisible = false
        }
    }

    private func particleOffset(index: Int) -> CGSize {
        let angle = (Double(index) / Double(particleCount)) * 2 * .pi
        let distance: CGFloat = particlesVisible ? size * 1.2 : size * 0.3
        return CGSize(
            width: CGFloat(cos(angle)) * distance,
            height: CGFloat(sin(angle)) * distance
        )
    }

    private func particleColor(_ index: Int) -> Color {
        let colors: [Color] = [.hlPrimary, .hlGold, .hlFlame, .hlInfo, .hlMindfulness, .hlHealth, .hlFitness, .hlWarning]
        return colors[index % colors.count]
    }
}

// MARK: - Celebration Confetti Overlay (Full Screen)

struct CelebrationOverlay: View {
    @ScaledMetric(relativeTo: .largeTitle) private var celebrationIconSize: CGFloat = 44
    @Binding var isActive: Bool
    var message: String = ""
    var icon: String = "star.fill"

    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var textOpacity: Double = 0
    @State private var textScale: CGFloat = 0.5
    @State private var textOffset: CGFloat = 20

    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let color: Color
        let size: CGFloat
        let rotation: Double
        let shape: Int // 0 = circle, 1 = rect, 2 = triangle
    }

    var body: some View {
        if isActive {
            ZStack {
                // Confetti particles
                ForEach(confettiPieces) { piece in
                    confettiShape(piece)
                        .position(x: piece.x, y: piece.y)
                        .rotationEffect(.degrees(piece.rotation))
                }

                // Message
                if !message.isEmpty {
                    VStack(spacing: HLSpacing.sm) {
                        Image(systemName: icon)
                            .font(.system(size: min(celebrationIconSize, 52)))
                            .foregroundStyle(Color.hlGold)

                        Text(message)
                            .font(HLFont.title2(.bold))
                            .foregroundStyle(Color.hlTextPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(HLSpacing.xl)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: HLRadius.xl))
                    .opacity(textOpacity)
                    .scaleEffect(textScale)
                    .offset(y: textOffset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
            .onAppear { startCelebration() }
        }
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
            Triangle()
                .fill(piece.color)
                .frame(width: piece.size, height: piece.size)
        }
    }

    private func startCelebration() {
        let screenWidth = UIScreen.main.bounds.width
        let colors: [Color] = [.hlPrimary, .hlGold, .hlFlame, .hlInfo, .hlMindfulness, .hlHealth, .hlWarning, .hlFitness]

        // Create confetti at top
        confettiPieces = (0..<40).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: -50...0),
                color: colors.randomElement() ?? .hlPrimary,
                size: CGFloat.random(in: 5...10),
                rotation: Double.random(in: 0...360),
                shape: Int.random(in: 0...2)
            )
        }

        // Animate falling
        withAnimation(.easeIn(duration: 2.0)) {
            confettiPieces = confettiPieces.map { piece in
                var p = piece
                p.y = UIScreen.main.bounds.height + 50
                p.x += CGFloat.random(in: -80...80)
                return p
            }
        }

        // Show text
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
            textOpacity = 1
            textScale = 1.0
            textOffset = 0
        }

        // Dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                textOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isActive = false
                confettiPieces = []
            }
        }
    }
}

// MARK: - Achievement Celebration Overlay

struct AchievementCelebrationOverlay: View {
    @ScaledMetric(relativeTo: .largeTitle) private var achieveIconSize: CGFloat = 44
    @Binding var achievement: AchievementCelebrationData?

    @State private var confettiPieces: [CelebrationOverlay.ConfettiPiece] = []
    @State private var showCard = false
    @State private var iconScale: CGFloat = 0.1
    @State private var glowOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -200

    var body: some View {
        if let data = achievement {
            ZStack {
                // Dim background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }

                // Confetti
                ForEach(confettiPieces) { piece in
                    confettiShape(piece)
                        .position(x: piece.x, y: piece.y)
                        .rotationEffect(.degrees(piece.rotation))
                }

                // Achievement card
                VStack(spacing: HLSpacing.lg) {
                    // Glow ring + icon
                    ZStack {
                        Circle()
                            .fill(Color.hlGold.opacity(glowOpacity * 0.3))
                            .frame(width: 140, height: 140)

                        Circle()
                            .fill(Color.hlGold.opacity(0.15))
                            .frame(width: 110, height: 110)

                        Circle()
                            .stroke(Color.hlGold.opacity(0.5), lineWidth: 3)
                            .frame(width: 100, height: 100)

                        Image(systemName: data.icon)
                            .font(.system(size: min(achieveIconSize, 52)))
                            .foregroundStyle(Color.hlGold)
                            .scaleEffect(iconScale)
                    }

                    VStack(spacing: HLSpacing.xs) {
                        Text("Achievement Unlocked!")
                            .font(HLFont.caption(.semibold))
                            .foregroundStyle(Color.hlGold)
                            .textCase(.uppercase)
                            .tracking(1.5)

                        Text(data.name)
                            .font(HLFont.title2(.bold))
                            .foregroundStyle(Color.hlTextPrimary)

                        Text(data.description)
                            .font(HLFont.subheadline())
                            .foregroundStyle(Color.hlTextSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Progress indicator
                    HStack(spacing: HLSpacing.sm) {
                        // Mini progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: HLRadius.full)
                                    .fill(Color.hlDivider)
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: HLRadius.full)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.hlPrimary, Color.hlGold],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geo.size.width * CGFloat(data.unlockedCount) / CGFloat(max(data.totalCount, 1)),
                                        height: 6
                                    )
                            }
                        }
                        .frame(height: 6)

                        Text("\(data.unlockedCount)/\(data.totalCount)")
                            .font(HLFont.caption2(.bold))
                            .foregroundStyle(Color.hlPrimary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, HLSpacing.xs)

                    Button {
                        dismiss()
                    } label: {
                        Text("Awesome!")
                            .font(HLFont.headline())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, HLSpacing.sm)
                            .background(
                                LinearGradient(
                                    colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(HLRadius.md)
                    }
                }
                .padding(HLSpacing.xl)
                .background {
                    RoundedRectangle(cornerRadius: HLRadius.xl)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: HLRadius.xl)
                                .stroke(Color.hlPrimary.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, HLSpacing.xl)
                .scaleEffect(showCard ? 1.0 : 0.8)
                .opacity(showCard ? 1.0 : 0)
            }
            .onAppear { startCelebration() }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            showCard = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            achievement = nil
            confettiPieces = []
            showCard = false
            iconScale = 0.1
            glowOpacity = 0
        }
    }

    @ViewBuilder
    private func confettiShape(_ piece: CelebrationOverlay.ConfettiPiece) -> some View {
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
            Triangle()
                .fill(piece.color)
                .frame(width: piece.size, height: piece.size)
        }
    }

    private func startCelebration() {
        let screenWidth = UIScreen.main.bounds.width
        let colors: [Color] = [.hlGold, .hlFlame, .hlPrimary, .hlInfo, .hlMindfulness, .hlWarning]

        // Confetti burst
        confettiPieces = (0..<50).map { _ in
            CelebrationOverlay.ConfettiPiece(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: -50...0),
                color: colors.randomElement() ?? .hlPrimary,
                size: CGFloat.random(in: 5...12),
                rotation: Double.random(in: 0...360),
                shape: Int.random(in: 0...2)
            )
        }

        withAnimation(.easeIn(duration: 2.5)) {
            confettiPieces = confettiPieces.map { piece in
                var p = piece
                p.y = UIScreen.main.bounds.height + 50
                p.x += CGFloat.random(in: -100...100)
                return p
            }
        }

        // Card entrance
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
            showCard = true
        }

        // Icon bounce
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.3)) {
            iconScale = 1.0
        }

        // Glow pulse
        withAnimation(.easeInOut(duration: 1.0).delay(0.4).repeatForever(autoreverses: true)) {
            glowOpacity = 1.0
        }

        HLHaptics.achievementUnlocked()
    }
}

struct AchievementCelebrationData: Equatable {
    let name: String
    let description: String
    let icon: String
    let unlockedCount: Int
    let totalCount: Int
}

// MARK: - Level Up Celebration Overlay

struct LevelUpCelebrationOverlay: View {
    @ScaledMetric(relativeTo: .footnote) private var titleBadgeIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .footnote) private var arrowIconSize: CGFloat = 14
    @Binding var levelUpData: LevelUpData?

    @State private var showCard = false
    @State private var showOldLevel = true
    @State private var numberScale: CGFloat = 0.1
    @State private var ringProgress: CGFloat = 0
    @State private var outerRingRotation: Double = 0
    @State private var glowPulse: Double = 0
    @State private var starBurst = false
    @State private var titleOpacity: Double = 0
    @State private var xpBarProgress: CGFloat = 0
    @State private var confettiPieces: [CelebrationOverlay.ConfettiPiece] = []

    var body: some View {
        if let data = levelUpData {
            ZStack {
                // Dim background
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }

                // Confetti
                ForEach(confettiPieces) { piece in
                    confettiShape(piece)
                        .position(x: piece.x, y: piece.y)
                        .rotationEffect(.degrees(piece.rotation))
                }

                VStack(spacing: HLSpacing.lg) {
                    // Level ring with animated transition
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.hlGold.opacity(glowPulse * 0.3), Color.clear],
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 90
                                )
                            )
                            .frame(width: 180, height: 180)

                        // Decorative rotating ring
                        Circle()
                            .trim(from: 0, to: 0.3)
                            .stroke(
                                Color.hlGold.opacity(0.4),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 6])
                            )
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(outerRingRotation))

                        // Background ring
                        Circle()
                            .stroke(Color.hlDivider, lineWidth: 8)
                            .frame(width: 120, height: 120)

                        // Progress ring (fills to 100%)
                        Circle()
                            .trim(from: 0, to: ringProgress)
                            .stroke(
                                AngularGradient(
                                    colors: [Color.hlPrimary, Color.hlGold, Color.hlPrimary],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        // Star burst particles
                        ForEach(0..<8, id: \.self) { i in
                            let angle = Double(i) * 45.0
                            Image(systemName: "sparkle")
                                .font(.system(size: starBurst ? 10 : 4))
                                .foregroundStyle(Color.hlGold)
                                .offset(
                                    x: CGFloat(cos(angle * .pi / 180)) * (starBurst ? 75 : 55),
                                    y: CGFloat(sin(angle * .pi / 180)) * (starBurst ? 75 : 55)
                                )
                                .opacity(starBurst ? 0 : 0.8)
                                .scaleEffect(starBurst ? 0.3 : 1)
                        }

                        // Level number with transition
                        VStack(spacing: 2) {
                            Text("LEVEL")
                                .font(HLFont.caption2(.heavy))
                                .foregroundStyle(Color.hlGold)
                                .tracking(2)

                            ZStack {
                                // Old level (fades out + scales down)
                                Text("\(data.oldLevel)")
                                    .font(HLFont.largeTitle(.heavy))
                                    .foregroundStyle(Color.hlTextTertiary)
                                    .opacity(showOldLevel ? 1 : 0)
                                    .scaleEffect(showOldLevel ? 1 : 0.3)

                                // New level (fades in + bounces up)
                                Text("\(data.newLevel)")
                                    .font(HLFont.largeTitle(.heavy))
                                    .foregroundStyle(Color.hlTextPrimary)
                                    .scaleEffect(numberScale)
                                    .opacity(showOldLevel ? 0 : 1)
                            }
                        }
                    }

                    // Title & info
                    VStack(spacing: HLSpacing.sm) {
                        Text("LEVEL UP!")
                            .font(HLFont.footnote(.black))
                            .foregroundStyle(Color.hlGold)
                            .tracking(3)

                        // Title badge
                        HStack(spacing: HLSpacing.xs) {
                            Image(systemName: levelIcon(for: data.newLevel))
                                .font(.system(size: min(titleBadgeIconSize, 20)))
                                .foregroundStyle(Color.hlGold)
                            Text(data.newTitle)
                                .font(HLFont.title3(.bold))
                                .foregroundStyle(Color.hlTextPrimary)
                        }
                        .opacity(titleOpacity)

                        Text("Level \(data.oldLevel) → Level \(data.newLevel)")
                            .font(HLFont.subheadline())
                            .foregroundStyle(Color.hlTextSecondary)
                    }

                    // Next level XP info
                    VStack(spacing: HLSpacing.xs) {
                        HStack {
                            Text("Next Level")
                                .font(HLFont.caption(.medium))
                                .foregroundStyle(Color.hlTextTertiary)
                            Spacer()
                            Text("0/\(data.newLevel * 100) XP")
                                .font(HLFont.caption(.semibold))
                                .foregroundStyle(Color.hlPrimary)
                                .monospacedDigit()
                        }

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
                                    .frame(width: geo.size.width * xpBarProgress, height: 8)
                            }
                        }
                        .frame(height: 8)

                        Text("+10 XP per habit completion")
                            .font(HLFont.caption2())
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                    .padding(HLSpacing.sm)
                    .background(Color.hlSurface.opacity(0.5))
                    .cornerRadius(HLRadius.md)

                    // Button
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: HLSpacing.xs) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: min(arrowIconSize, 18), weight: .bold))
                            Text("Keep Going!")
                                .font(HLFont.headline())
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HLSpacing.sm)
                        .background(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(HLRadius.md)
                    }
                }
                .padding(HLSpacing.xl)
                .background {
                    RoundedRectangle(cornerRadius: HLRadius.xl)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: HLRadius.xl)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.hlGold.opacity(0.5), Color.hlPrimary.opacity(0.3), Color.hlGold.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                }
                .padding(.horizontal, HLSpacing.lg)
                .scaleEffect(showCard ? 1.0 : 0.8)
                .opacity(showCard ? 1.0 : 0)
            }
            .onAppear { startCelebration() }
        }
    }

    private func levelIcon(for level: Int) -> String {
        switch level {
        case 1...5: return "leaf.fill"
        case 6...10: return "leaf.arrow.triangle.circlepath"
        case 11...20: return "tree.fill"
        case 21...35: return "tree.fill"
        case 36...50: return "sparkles"
        default: return "crown.fill"
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            showCard = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            levelUpData = nil
            confettiPieces = []
            showCard = false
            showOldLevel = true
            numberScale = 0.1
            ringProgress = 0
            outerRingRotation = 0
            glowPulse = 0
            starBurst = false
            titleOpacity = 0
            xpBarProgress = 0
        }
    }

    @ViewBuilder
    private func confettiShape(_ piece: CelebrationOverlay.ConfettiPiece) -> some View {
        switch piece.shape {
        case 0:
            Circle().fill(piece.color).frame(width: piece.size, height: piece.size)
        case 1:
            RoundedRectangle(cornerRadius: 1).fill(piece.color).frame(width: piece.size, height: piece.size * 1.5)
        default:
            Triangle().fill(piece.color).frame(width: piece.size, height: piece.size)
        }
    }

    private func startCelebration() {
        let screenWidth = UIScreen.main.bounds.width
        let colors: [Color] = [.hlGold, .hlPrimary, .hlFlame, .hlInfo, .hlMindfulness]

        // Confetti burst
        confettiPieces = (0..<60).map { _ in
            CelebrationOverlay.ConfettiPiece(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: -50...0),
                color: colors.randomElement() ?? .hlPrimary,
                size: CGFloat.random(in: 5...12),
                rotation: Double.random(in: 0...360),
                shape: Int.random(in: 0...2)
            )
        }
        withAnimation(.easeIn(duration: 3.0)) {
            confettiPieces = confettiPieces.map { piece in
                var p = piece
                p.y = UIScreen.main.bounds.height + 50
                p.x += CGFloat.random(in: -100...100)
                return p
            }
        }

        // Card entrance
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
            showCard = true
        }

        // Ring fills up
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            ringProgress = 1.0
        }

        // Outer ring rotates continuously
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            outerRingRotation = 360
        }

        // Level number transition: old fades → new bounces in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.2)) {
                showOldLevel = false
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.45).delay(0.2)) {
                numberScale = 1.0
            }
            // Star burst on number change
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                starBurst = true
            }
        }

        // Title fades in
        withAnimation(.easeOut(duration: 0.4).delay(1.2)) {
            titleOpacity = 1.0
        }

        // Glow pulse
        withAnimation(.easeInOut(duration: 1.2).delay(0.5).repeatForever(autoreverses: true)) {
            glowPulse = 1.0
        }

        HLHaptics.achievementUnlocked()
    }
}

struct LevelUpData: Equatable {
    let oldLevel: Int
    let newLevel: Int
    let newTitle: String
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Streak Fire Animation

struct StreakFireView: View {
    @ScaledMetric(relativeTo: .title3) private var glowFlameSize: CGFloat = 28
    @ScaledMetric(relativeTo: .title3) private var mainFlameSize: CGFloat = 22
    let streak: Int
    @State private var flameScale: CGFloat = 1.0
    @State private var flameGlow: Double = 0.3

    private var intensity: Double {
        switch streak {
        case 0...6: return 0.5
        case 7...29: return 0.7
        case 30...99: return 0.85
        default: return 1.0
        }
    }

    private var flameColor: Color {
        switch streak {
        case 0...6: return .hlFlame
        case 7...29: return .hlFlame
        case 30...99: return .hlGold
        default: return Color(red: 0.2, green: 0.8, blue: 1.0) // Diamond blue
        }
    }

    var body: some View {
        ZStack {
            // Glow
            Image(systemName: "flame.fill")
                .font(.system(size: min(glowFlameSize, 32)))
                .foregroundStyle(flameColor.opacity(flameGlow))
                .blur(radius: 6)
                .scaleEffect(flameScale * 1.2)

            // Main flame
            Image(systemName: "flame.fill")
                .font(.system(size: min(mainFlameSize, 26)))
                .foregroundStyle(flameColor)
                .scaleEffect(flameScale)
        }
        .onAppear {
            guard streak > 0 else { return }
            withAnimation(
                .easeInOut(duration: 0.8 / intensity)
                .repeatForever(autoreverses: true)
            ) {
                flameScale = 1.0 + CGFloat(intensity) * 0.15
                flameGlow = 0.3 + intensity * 0.4
            }
        }
    }
}

// MARK: - XP Gain Animation

struct XPGainView: View {
    let amount: Int
    @State private var isVisible = false
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Text("+\(amount) XP")
            .font(HLFont.subheadline(.bold))
            .foregroundStyle(Color.hlGold)
            .shadow(color: .hlGold.opacity(0.5), radius: 4)
            .offset(y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    yOffset = -40
                    opacity = 0
                }
            }
    }
}

// MARK: - Success Ripple Effect

struct RippleModifier: ViewModifier {
    let isActive: Bool
    let color: Color
    @State private var ripple1Scale: CGFloat = 0.8
    @State private var ripple2Scale: CGFloat = 0.8
    @State private var ripple1Opacity: Double = 0
    @State private var ripple2Opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .scaleEffect(ripple1Scale)
                        .opacity(ripple1Opacity)

                    Circle()
                        .stroke(color, lineWidth: 1.5)
                        .scaleEffect(ripple2Scale)
                        .opacity(ripple2Opacity)
                }
            )
            .onChange(of: isActive) { _, newValue in
                if newValue { triggerRipple() }
            }
    }

    private func triggerRipple() {
        ripple1Scale = 0.8
        ripple1Opacity = 0.6
        ripple2Scale = 0.8
        ripple2Opacity = 0

        withAnimation(.easeOut(duration: 0.6)) {
            ripple1Scale = 2.5
            ripple1Opacity = 0
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
            ripple2Scale = 2.5
            ripple2Opacity = 0.4
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            ripple2Opacity = 0
        }
    }
}

extension View {
    func hlRipple(isActive: Bool, color: Color = .hlPrimary) -> some View {
        modifier(RippleModifier(isActive: isActive, color: color))
    }
}

// MARK: - Bounce Appear

struct BounceAppearModifier: ViewModifier {
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

extension View {
    func hlBounceAppear() -> some View {
        modifier(BounceAppearModifier())
    }
}

// MARK: - Progress Ring Glow

struct ProgressRingGlowModifier: ViewModifier {
    let progress: Double
    let color: Color
    @State private var glowOpacity: Double = 0.2

    func body(content: Content) -> some View {
        content
            .shadow(
                color: progress >= 1.0 ? color.opacity(glowOpacity) : .clear,
                radius: 8
            )
            .onAppear {
                guard progress >= 1.0 else { return }
                withAnimation(HLAnimation.ringGlow) {
                    glowOpacity = 0.6
                }
            }
    }
}

extension View {
    func hlRingGlow(progress: Double, color: Color = .hlPrimary) -> some View {
        modifier(ProgressRingGlowModifier(progress: progress, color: color))
    }
}

// MARK: - Page Transition

struct SlideUpTransitionModifier: ViewModifier {
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 24)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func hlPageTransition() -> some View {
        modifier(SlideUpTransitionModifier())
    }
}
