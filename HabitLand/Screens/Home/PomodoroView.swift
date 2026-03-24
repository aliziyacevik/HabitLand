import SwiftUI
import SwiftData

struct PomodoroView: View {
    @ScaledMetric(relativeTo: .footnote) private var closeIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var controlIconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .title3) private var playIconSize: CGFloat = 28
    @ScaledMetric(relativeTo: .title) private var phaseIconSize: CGFloat = 32
    @ScaledMetric(relativeTo: .body) private var closeButtonSize: CGFloat = 40
    @ScaledMetric(relativeTo: .title3) private var controlButtonSize: CGFloat = 56
    @ScaledMetric(relativeTo: .title) private var playButtonSize: CGFloat = 72
    @ScaledMetric(relativeTo: .largeTitle) private var timerRingSize: CGFloat = 260
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    @State private var phase: PomodoroPhase = .work
    @State private var remainingSeconds: Int = ProManager.shared.canAccessFullPomodoro ? 25 * 60 : ProManager.freePomodoroDuration
    @State private var isRunning = false
    @State private var completedSessions = 0
    @State private var timer: Timer?
    @State private var backgroundDate: Date?
    @State private var showUpgradeHint = false

    private var workDuration: Int { ProManager.shared.canAccessFullPomodoro ? 25 * 60 : ProManager.freePomodoroDuration }
    private let breakDuration = 5 * 60
    private let longBreakDuration = 15 * 60

    enum PomodoroPhase: String {
        case work = "Focus"
        case shortBreak = "Break"
        case longBreak = "Long Break"

        var color: Color {
            switch self {
            case .work: return .hlFlame
            case .shortBreak: return .hlPrimary
            case .longBreak: return .hlSleep
            }
        }

        var icon: String {
            switch self {
            case .work: return "brain.head.profile"
            case .shortBreak: return "cup.and.saucer.fill"
            case .longBreak: return "leaf.fill"
            }
        }
    }

    private var totalSeconds: Int {
        switch phase {
        case .work: return workDuration
        case .shortBreak: return breakDuration
        case .longBreak: return longBreakDuration
        }
    }

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }

    private var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Fixed top bar — always visible
            HStack {
                Button {
                    stopTimer()
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: min(closeIconSize, 20), weight: .semibold))
                        .foregroundStyle(Color.hlTextSecondary)
                        .frame(width: min(closeButtonSize, 56), height: min(closeButtonSize, 56))
                        .background(Color.hlSurface)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Close")
                Spacer()
                // Session dots
                HStack(spacing: HLSpacing.xs) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(i < completedSessions ? phase.color : Color.hlDivider)
                            .frame(width: 10, height: 10)
                    }
                }
                Spacer()
                Color.clear.frame(width: min(closeButtonSize, 56), height: min(closeButtonSize, 56))
            }
            .padding(.horizontal, HLSpacing.lg)
            .padding(.top, HLSpacing.sm)

            // Scrollable content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: HLSpacing.xl) {
                Spacer()
                    .frame(height: HLSpacing.md)

                // Phase indicator
                VStack(spacing: HLSpacing.sm) {
                    Image(systemName: phase.icon)
                        .font(.system(size: min(phaseIconSize, 36), weight: .semibold))
                        .foregroundStyle(phase.color)

                    Text(phase.rawValue)
                        .font(HLFont.title3(.semibold))
                        .foregroundStyle(phase.color)

                    if phase == .work {
                        Text("Session \(completedSessions + 1) of 4")
                            .font(HLFont.caption(.medium))
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                }

                // Timer ring
                ZStack {
                    Circle()
                        .stroke(Color.hlDivider, lineWidth: 10)
                        .frame(width: min(timerRingSize, 320), height: min(timerRingSize, 320))

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            phase.color,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: min(timerRingSize, 320), height: min(timerRingSize, 320))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    Text(formattedTime)
                        .font(HLFont.largeTitle(.thin))
                        .foregroundStyle(Color.hlTextPrimary)
                        .monospacedDigit()
                }

                Spacer()

                // Controls
                HStack(spacing: HLSpacing.xxxl) {
                    // Reset current phase
                    Button {
                        resetPhase()
                        HLHaptics.selection()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: min(controlIconSize, 24), weight: .semibold))
                            .foregroundStyle(Color.hlTextSecondary)
                            .frame(width: min(controlButtonSize, 72), height: min(controlButtonSize, 72))
                            .background(Color.hlSurface)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Reset timer")

                    // Play/Pause
                    Button {
                        if isRunning {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
                        HLHaptics.selection()
                    } label: {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: min(playIconSize, 32), weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: min(playButtonSize, 96), height: min(playButtonSize, 96))
                            .background(phase.color)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(isRunning ? "Pause" : "Play")

                    // Skip to next phase
                    Button {
                        advancePhase()
                        HLHaptics.selection()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: min(controlIconSize, 24), weight: .semibold))
                            .foregroundStyle(phase.color)
                            .frame(width: min(controlButtonSize, 72), height: min(controlButtonSize, 72))
                            .background(phase.color.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Skip to next phase")
                }

                // Ambient sounds
                AmbientSoundPicker()
                    .padding(.horizontal, HLSpacing.lg)

                // Session summary
                if completedSessions > 0 {
                    Text("\(completedSessions) session\(completedSessions > 1 ? "s" : "") completed")
                        .font(HLFont.caption(.medium))
                        .foregroundStyle(Color.hlTextTertiary)
                }

                Spacer()
                    .frame(height: HLSpacing.lg)
                }
                .padding(.bottom, HLSpacing.xl)
            }
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            stopTimer()
            AmbientSoundManager.shared.stop()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            handleBackground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            handleForeground()
        }
    }

    // MARK: - Timer Controls

    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                tick()
            }
        }
    }

    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        cancelNotification()
    }

    private func resetPhase() {
        stopTimer()
        remainingSeconds = totalSeconds
    }

    private func tick() {
        guard remainingSeconds > 0 else { return }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            phaseComplete()
        }
    }

    private func phaseComplete() {
        stopTimer()
        HLHaptics.success()

        if phase == .work {
            completedSessions += 1
            // Award XP for completed pomodoro session
            awardPomodoroXP()
        }
        advancePhase()
    }

    private func advancePhase() {
        stopTimer()
        withAnimation(HLAnimation.standard) {
            switch phase {
            case .work:
                phase = completedSessions % 4 == 0 ? .longBreak : .shortBreak
            case .shortBreak, .longBreak:
                phase = .work
            }
            remainingSeconds = totalSeconds
        }
    }

    // MARK: - Background Support

    private func handleBackground() {
        guard isRunning else { return }
        backgroundDate = Date()
        pauseTimer()
        scheduleNotification()
    }

    private func handleForeground() {
        cancelNotification()
        guard let bg = backgroundDate else { return }
        let elapsed = Int(Date().timeIntervalSince(bg))
        backgroundDate = nil
        remainingSeconds = max(0, remainingSeconds - elapsed)
        if remainingSeconds == 0 {
            phaseComplete()
        } else {
            startTimer()
        }
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = phase == .work ? "Focus session complete!" : "Break's over!"
        content.body = phase == .work ? "Great focus! Time for a break." : "Ready to focus again?"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(remainingSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro-timer", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["pomodoro-timer"])
    }

    // MARK: - XP Award

    private func awardPomodoroXP() {
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? modelContext.fetch(descriptor).first else { return }
        profile.xp += 15
        while profile.xp >= profile.xpForNextLevel {
            profile.xp -= profile.xpForNextLevel
            profile.level += 1
        }
        try? modelContext.save()
    }
}

#Preview {
    PomodoroView(isPresented: .constant(true))
        .modelContainer(for: UserProfile.self, inMemory: true)
}
