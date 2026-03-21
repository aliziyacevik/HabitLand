import SwiftUI
import SwiftData

struct HabitTimerView: View {
    @ObservedObject private var timerManager = HabitTimerManager.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            VStack(spacing: HLSpacing.xxxl) {
                Spacer()

                // Habit info
                VStack(spacing: HLSpacing.sm) {
                    Image(systemName: timerManager.habitIcon)
                        .font(.system(size: 28, weight: .semibold))
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
                        .frame(width: 240, height: 240)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: timerManager.progress)
                        .stroke(
                            timerManager.habitColor,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timerManager.progress)

                    // Time display
                    VStack(spacing: HLSpacing.xxs) {
                        Text(timerManager.formattedTime)
                            .font(.system(size: 56, weight: .light, design: .rounded))
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
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.hlTextSecondary)
                            .frame(width: 56, height: 56)
                            .background(Color.hlSurface)
                            .clipShape(Circle())
                    }

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
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(timerManager.habitColor)
                            .clipShape(Circle())
                    }

                    // Skip (complete early)
                    Button {
                        completeHabit()
                        timerManager.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(timerManager.habitColor)
                            .frame(width: 56, height: 56)
                            .background(timerManager.habitColor.opacity(0.12))
                            .clipShape(Circle())
                    }
                }

                Spacer()
                    .frame(height: HLSpacing.xxl)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .habitTimerCompleted)) { _ in
            completeHabit()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
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
    HabitTimerView()
        .modelContainer(for: Habit.self, inMemory: true)
}
