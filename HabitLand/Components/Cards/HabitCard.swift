import SwiftUI
import SwiftData

struct HabitCard: View {
    let name: String
    let icon: String
    let color: Color
    let streak: Int
    let progress: Double
    let isCompleted: Bool
    let goalCount: Int
    let currentCount: Int
    let unit: String
    let isTimeBased: Bool
    let isHealthKit: Bool
    var onToggle: (() -> Void)?
    var onIncrement: (() -> Void)?
    var onStartTimer: (() -> Void)?

    // MARK: - Model Initializer

    init(habit: Habit, onToggle: (() -> Void)? = nil, onIncrement: (() -> Void)? = nil, onStartTimer: (() -> Void)? = nil) {
        self.name = habit.name
        self.icon = habit.icon
        self.color = habit.color
        self.streak = habit.currentStreak
        self.progress = habit.todayProgress
        self.isCompleted = habit.todayCompleted
        self.goalCount = habit.goalCount
        self.unit = habit.unit
        self.isTimeBased = habit.unit == "minutes" || habit.unit == "hours"
        self.isHealthKit = habit.healthKitMetric != nil
        self.onToggle = onToggle
        self.onIncrement = onIncrement
        self.onStartTimer = onStartTimer

        // Calculate today's count
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        self.currentCount = habit.safeCompletions
            .filter { calendar.startOfDay(for: $0.date) == today }
            .reduce(0) { $0 + $1.count }
    }

    // MARK: - Preview Initializer

    init(
        name: String,
        icon: String = "checkmark.circle",
        color: Color = .hlPrimary,
        streak: Int = 0,
        progress: Double = 0,
        isCompleted: Bool = false,
        goalCount: Int = 1,
        currentCount: Int = 0,
        unit: String = "times",
        isTimeBased: Bool = false,
        isHealthKit: Bool = false,
        onToggle: (() -> Void)? = nil
    ) {
        self.name = name
        self.icon = icon
        self.color = color
        self.streak = streak
        self.progress = progress
        self.isCompleted = isCompleted
        self.goalCount = goalCount
        self.currentCount = currentCount
        self.unit = unit
        self.isTimeBased = isTimeBased
        self.isHealthKit = isHealthKit
        self.onToggle = onToggle
        self.onIncrement = nil
        self.onStartTimer = nil
    }

    var isProgressive: Bool { goalCount > 1 }

    @State private var justCompleted = false
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 36
    @ScaledMetric(relativeTo: .body) private var checkmarkSize: CGFloat = 36
    @ScaledMetric(relativeTo: .caption) private var counterTextSize: CGFloat = 11
    @ScaledMetric(relativeTo: .caption) private var flameSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var checkIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .body) private var habitIconSize: CGFloat = 20

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            // Icon in colored circle
            iconView

            // Name, streak, and progress
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text(name)
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                    .lineLimit(1)

                HStack(spacing: HLSpacing.sm) {
                    if isHealthKit {
                        HStack(spacing: HLSpacing.xxxs) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: min(flameSize, 16)))
                                .foregroundStyle(.red.opacity(0.7))
                                .accessibilityHidden(true)
                            Text("Health")
                                .font(HLFont.caption())
                                .foregroundStyle(.red.opacity(0.6))
                        }
                    }
                    if streak > 0 {
                        streakLabel
                    }
                    if isProgressive && !isCompleted {
                        Text("\(currentCount)/\(goalCount) \(unit)")
                            .font(HLFont.caption())
                            .foregroundColor(.hlPrimary)
                    }
                }
            }

            Spacer()

            // Action button: health sync / timer / counter / checkmark
            if isHealthKit && !isCompleted {
                healthSyncView
            } else if isTimeBased && !isCompleted {
                timerButton
            } else if isProgressive && !isCompleted {
                counterButton
            } else {
                checkmarkButton
            }
        }
        .hlCard()
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(streak > 0 ? "\(streak)-day streak, " : "")\(isCompleted ? "completed" : "not completed")")
    }

    // MARK: - Subviews

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: iconSize + 8, height: iconSize + 8)

            Image(systemName: icon)
                .font(.system(size: min(habitIconSize, 24), weight: .semibold))
                .foregroundColor(color)
        }
    }

    private var streakLabel: some View {
        HStack(spacing: HLSpacing.xxs) {
            Image(systemName: HLIcon.flame)
                .font(.system(size: min(flameSize, 16)))
                .foregroundColor(.hlFlame)
                .accessibilityHidden(true)

            Text("\(streak) day\(streak == 1 ? "" : "s")")
                .font(HLFont.caption(.medium))
                .foregroundColor(.hlTextSecondary)
        }
    }

    // MARK: - Health Sync View (for HealthKit habits)

    private var healthSyncView: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: 3)
                .frame(width: checkmarkSize, height: checkmarkSize)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: checkmarkSize, height: checkmarkSize)
                .rotationEffect(.degrees(-90))

            Image(systemName: "heart.fill")
                .font(.system(size: min(checkIconSize, 18), weight: .semibold))
                .foregroundStyle(.red.opacity(0.8))
        }
        .accessibilityLabel("Syncs from Apple Health, \(Int(progress * 100))% complete")
    }

    // MARK: - Timer Button (for time-based habits)

    private var timerButton: some View {
        Button {
            onStartTimer?()
            HLHaptics.selection()
        } label: {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 3)
                    .frame(width: checkmarkSize, height: checkmarkSize)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: checkmarkSize, height: checkmarkSize)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "play.fill")
                    .font(.system(size: min(flameSize, 16), weight: .bold))
                    .foregroundColor(color)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start timer for \(name), \(currentCount) of \(goalCount) \(unit)")
    }

    // MARK: - Counter Button (for progressive habits)

    private var counterButton: some View {
        Button {
            onIncrement?()
            HLHaptics.light()
        } label: {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 3)
                    .frame(width: checkmarkSize, height: checkmarkSize)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: checkmarkSize, height: checkmarkSize)
                    .rotationEffect(.degrees(-90))

                Text("+1")
                    .font(.system(size: min(counterTextSize, 15), weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add one \(unit) to \(name), \(currentCount) of \(goalCount)")
    }

    // MARK: - Checkmark Button (for binary habits)

    private var checkmarkButton: some View {
        Button {
            if !isCompleted {
                justCompleted = true
                HLHaptics.completionSuccess()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    justCompleted = false
                }
            } else {
                HLHaptics.light()
            }
            onToggle?()
        } label: {
            ZStack {
                // Pulse ripple on completion
                if justCompleted {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: checkmarkSize, height: checkmarkSize)
                        .scaleEffect(justCompleted ? 2.2 : 1.0)
                        .opacity(justCompleted ? 0 : 0.4)
                        .animation(.easeOut(duration: 0.5), value: justCompleted)
                }

                // Progress ring
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 3)
                    .frame(width: checkmarkSize, height: checkmarkSize)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: checkmarkSize, height: checkmarkSize)
                    .rotationEffect(.degrees(-90))

                // Checkmark or empty
                if isCompleted {
                    Circle()
                        .fill(color)
                        .frame(width: 28, height: 28)
                        .hlGlow(color, radius: 6, isActive: justCompleted)

                    Image(systemName: HLIcon.checkmark)
                        .font(.system(size: min(checkIconSize, 18), weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .fill(Color.hlSurface)
                        .frame(width: 28, height: 28)
                }
            }
            .scaleEffect(justCompleted ? 1.15 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isCompleted ? "Mark \(name) as incomplete" : "Mark \(name) as complete")
        .animation(HLAnimation.celebration, value: justCompleted)
        .animation(HLAnimation.microSpring, value: isCompleted)
        .animation(HLAnimation.progressFill, value: progress)
    }
}

// MARK: - Preview

#Preview("Incomplete") {
    VStack(spacing: HLSpacing.sm) {
        HabitCard(
            name: "Morning Meditation",
            icon: "brain.head.profile",
            color: .hlMindfulness,
            streak: 12,
            progress: 0,
            isCompleted: false
        )

        HabitCard(
            name: "Drink Water",
            icon: "drop.fill",
            color: .hlFitness,
            streak: 3,
            progress: 0.5,
            isCompleted: false
        )

        HabitCard(
            name: "Exercise",
            icon: "figure.run",
            color: .hlHealth,
            streak: 0,
            progress: 1.0,
            isCompleted: true
        )
    }
    .padding()
    .background(Color.hlBackground)
}
