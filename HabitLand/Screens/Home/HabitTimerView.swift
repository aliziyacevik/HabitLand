import SwiftUI
import SwiftData

struct HabitTimerView: View {
    @ScaledMetric(relativeTo: .body) private var controlIconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .title3) private var playIconSize: CGFloat = 28
    @ScaledMetric(relativeTo: .title3) private var controlButtonSize: CGFloat = 56
    @ScaledMetric(relativeTo: .title) private var playButtonSize: CGFloat = 72
    @ScaledMetric(relativeTo: .largeTitle) private var timerRingSize: CGFloat = 240
    @ObservedObject private var timerManager = HabitTimerManager.shared
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            VStack(spacing: HLSpacing.xxxl) {
                Spacer()

                // Habit info
                VStack(spacing: HLSpacing.sm) {
                    Image(systemName: timerManager.habitIcon)
                        .font(.system(size: min(playIconSize, 32), weight: .semibold))
                        .foregroundStyle(timerManager.habitColor)
                    Text(timerManager.habitName)
                        .font(HLFont.title3(.medium))
                        .foregroundStyle(Color.hlTextPrimary)
                }

                // Timer ring
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.hlDivider, lineWidth: 8)
                        .frame(width: min(timerRingSize, 300), height: min(timerRingSize, 300))

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: timerManager.progress)
                        .stroke(
                            timerManager.habitColor,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: min(timerRingSize, 300), height: min(timerRingSize, 300))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timerManager.progress)

                    // Time display
                    VStack(spacing: HLSpacing.xxs) {
                        Text(timerManager.formattedTime)
                            .font(HLFont.display(.light))
                            .foregroundStyle(Color.hlTextPrimary)
                            .monospacedDigit()

                        Text(timerManager.isRunning ? "remaining" : "paused")
                            .font(HLFont.caption(.medium))
                            .foregroundStyle(Color.hlTextTertiary)
                    }
                }

                Spacer()

                // Controls
                HStack(spacing: HLSpacing.xxxl) {
                    // Cancel
                    Button {
                        timerManager.stop()
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: min(controlIconSize, 24), weight: .semibold))
                            .foregroundStyle(Color.hlTextSecondary)
                            .frame(width: min(controlButtonSize, 72), height: min(controlButtonSize, 72))
                            .background(Color.hlSurface)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Cancel timer")

                    // Play/Pause
                    Button {
                        if timerManager.isRunning {
                            timerManager.pause()
                        } else {
                            timerManager.resume()
                        }
                        HLHaptics.selection()
                    } label: {
                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: min(playIconSize, 32), weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: min(playButtonSize, 96), height: min(playButtonSize, 96))
                            .background(timerManager.habitColor)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(timerManager.isRunning ? "Pause" : "Resume")

                    // Skip (complete early)
                    Button {
                        completeHabit()
                        timerManager.stop()
                        isPresented = false
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: min(controlIconSize, 24), weight: .semibold))
                            .foregroundStyle(timerManager.habitColor)
                            .frame(width: min(controlButtonSize, 72), height: min(controlButtonSize, 72))
                            .background(timerManager.habitColor.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Complete early")
                }

                // Ambient sounds
                AmbientSoundPicker()
                    .padding(.horizontal, HLSpacing.lg)

                Spacer()
                    .frame(height: HLSpacing.xxl)
            }
        }
        .onDisappear {
            AmbientSoundManager.shared.stop()
        }
        .onReceive(NotificationCenter.default.publisher(for: .habitTimerCompleted)) { _ in
            completeHabit()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPresented = false
            }
        }
    }

    private func completeHabit() {
        guard let habitID = timerManager.habitID else { return }
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == habitID })
        guard let habit = try? modelContext.fetch(descriptor).first else { return }
        guard !habit.todayCompleted else { return }

        let completion = HabitCompletion(date: Date())
        completion.habit = habit
        modelContext.insert(completion)
        try? modelContext.save()
        HLHaptics.completionSuccess()
    }
}

#Preview {
    HabitTimerView(isPresented: .constant(true))
        .modelContainer(for: Habit.self, inMemory: true)
}
