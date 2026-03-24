import SwiftUI
import SwiftData

struct HabitChainView: View {
    @ScaledMetric(relativeTo: .largeTitle) private var habitIconSize: CGFloat = 48
    @ScaledMetric(relativeTo: .largeTitle) private var completeIconSize: CGFloat = 56
    @ScaledMetric(relativeTo: .footnote) private var chainStepIconSize: CGFloat = 16
    let habits: [Habit]
    let chainName: String
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var timerManager = HabitTimerManager.shared

    @State private var currentIndex = 0
    @State private var chainComplete = false
    @State private var showTimer = false
    @State private var startTime = Date()

    private var currentHabit: Habit? {
        guard currentIndex < habits.count else { return nil }
        return habits[currentIndex]
    }

    private var completedCount: Int {
        habits.prefix(currentIndex).count
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            if chainComplete {
                chainCompleteView
            } else if let habit = currentHabit {
                VStack(spacing: HLSpacing.xl) {
                    // Top bar
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: min(chainStepIconSize, 20), weight: .semibold))
                                .foregroundStyle(Color.hlTextSecondary)
                                .frame(width: 40, height: 40)
                                .background(Color.hlSurface)
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text(chainName)
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlTextPrimary)
                        Spacer()
                        Color.clear.frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    // Progress bar
                    VStack(spacing: HLSpacing.xxs) {
                        Text("Step \(currentIndex + 1) of \(habits.count)")
                            .font(HLFont.caption(.medium))
                            .foregroundStyle(Color.hlTextTertiary)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: HLRadius.full)
                                    .fill(Color.hlDivider)
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: HLRadius.full)
                                    .fill(habit.color)
                                    .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(habits.count), height: 6)
                                    .animation(HLAnimation.standard, value: currentIndex)
                            }
                        }
                        .frame(height: 6)
                        .padding(.horizontal, HLSpacing.xl)
                    }

                    Spacer()

                    // Current habit display
                    VStack(spacing: HLSpacing.lg) {
                        ZStack {
                            Circle()
                                .fill(habit.color.opacity(0.12))
                                .frame(width: 120, height: 120)

                            Image(systemName: habit.icon)
                                .font(.system(size: min(habitIconSize, 56), weight: .medium))
                                .foregroundStyle(habit.color)
                        }

                        Text(habit.name)
                            .font(HLFont.title2())
                            .foregroundStyle(Color.hlTextPrimary)

                        if habit.goalCount > 1 {
                            Text("\(habit.goalCount) \(habit.unit)")
                                .font(HLFont.body())
                                .foregroundStyle(Color.hlTextSecondary)
                        }
                    }

                    Spacer()

                    // Action buttons
                    VStack(spacing: HLSpacing.md) {
                        // Timer button for minute-based habits
                        if habit.unit == "minutes" && habit.goalCount > 0 {
                            HLButton(
                                "Start Timer (\(habit.goalCount) min)",
                                icon: "timer",
                                style: .secondary,
                                size: .lg,
                                isFullWidth: true
                            ) {
                                timerManager.start(habit: (
                                    id: habit.id,
                                    name: habit.name,
                                    icon: habit.icon,
                                    color: habit.color,
                                    minutes: habit.goalCount
                                ))
                                showTimer = true
                            }
                        }

                        // Complete & next
                        HLButton(
                            currentIndex < habits.count - 1 ? "Done — Next" : "Done — Finish",
                            icon: "checkmark",
                            style: .primary,
                            size: .lg,
                            isFullWidth: true
                        ) {
                            completeCurrentAndAdvance()
                        }

                        // Skip
                        Button {
                            withAnimation(HLAnimation.standard) {
                                currentIndex += 1
                                if currentIndex >= habits.count {
                                    chainComplete = true
                                }
                            }
                        } label: {
                            Text("Skip")
                                .font(HLFont.callout(.medium))
                                .foregroundStyle(Color.hlTextSecondary)
                        }
                    }
                    .padding(.horizontal, HLSpacing.lg)
                    .padding(.bottom, HLSpacing.xxl)
                }
            }
        }
        .fullScreenCover(isPresented: $showTimer) {
            HabitTimerView(isPresented: $showTimer)
        }
        .onReceive(NotificationCenter.default.publisher(for: .habitTimerCompleted)) { notification in
            if let completedID = notification.object as? UUID,
               completedID == currentHabit?.id {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(HLAnimation.standard) {
                        currentIndex += 1
                        if currentIndex >= habits.count {
                            chainComplete = true
                        }
                    }
                }
            }
        }
    }

    // MARK: - Complete View

    private var chainCompleteView: some View {
        VStack(spacing: HLSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.hlPrimary.opacity(0.12))
                    .frame(width: 140, height: 140)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: min(completeIconSize, 64), weight: .medium))
                    .foregroundStyle(Color.hlPrimary)
            }

            VStack(spacing: HLSpacing.sm) {
                Text("Chain Complete!")
                    .font(HLFont.largeTitle())
                    .foregroundStyle(Color.hlTextPrimary)

                let elapsed = Int(Date().timeIntervalSince(startTime))
                let minutes = elapsed / 60
                Text("\(completedCount) habits in \(minutes > 0 ? "\(minutes) min" : "\(elapsed)s")")
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
            }

            Spacer()

            HLButton(
                "Done",
                icon: "checkmark",
                style: .primary,
                size: .lg,
                isFullWidth: true
            ) {
                dismiss()
            }
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
        }
    }

    // MARK: - Actions

    private func completeCurrentAndAdvance() {
        guard let habit = currentHabit, !habit.todayCompleted else {
            advanceToNext()
            return
        }

        let completion = HabitCompletion(date: Date())
        completion.habit = habit
        modelContext.insert(completion)
        try? modelContext.save()
        HLHaptics.completionSuccess()
        advanceToNext()
    }

    private func advanceToNext() {
        withAnimation(HLAnimation.standard) {
            currentIndex += 1
            if currentIndex >= habits.count {
                chainComplete = true
            }
        }
    }
}

#Preview {
    HabitChainView(habits: [], chainName: "Morning Routine")
        .modelContainer(for: Habit.self, inMemory: true)
}
