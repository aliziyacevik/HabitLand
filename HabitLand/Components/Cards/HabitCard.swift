import SwiftUI
import SwiftData

struct HabitCard: View {
    let name: String
    let icon: String
    let color: Color
    let streak: Int
    let progress: Double
    let isCompleted: Bool
    var onToggle: (() -> Void)?

    // MARK: - Model Initializer

    init(habit: Habit, onToggle: (() -> Void)? = nil) {
        self.name = habit.name
        self.icon = habit.icon
        self.color = habit.color
        self.streak = habit.currentStreak
        self.progress = habit.todayProgress
        self.isCompleted = habit.todayCompleted
        self.onToggle = onToggle
    }

    // MARK: - Preview Initializer

    init(
        name: String,
        icon: String = "checkmark.circle",
        color: Color = .hlPrimary,
        streak: Int = 0,
        progress: Double = 0,
        isCompleted: Bool = false,
        onToggle: (() -> Void)? = nil
    ) {
        self.name = name
        self.icon = icon
        self.color = color
        self.streak = streak
        self.progress = progress
        self.isCompleted = isCompleted
        self.onToggle = onToggle
    }

    @State private var justCompleted = false
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 36
    @ScaledMetric(relativeTo: .body) private var checkmarkSize: CGFloat = 36

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            // Icon in colored circle
            iconView

            // Name and streak
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text(name)
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                    .lineLimit(1)

                if streak > 0 {
                    streakLabel
                }
            }

            Spacer()

            // Completion ring + checkmark button
            checkmarkButton
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
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
        }
    }

    private var streakLabel: some View {
        HStack(spacing: HLSpacing.xxs) {
            Image(systemName: HLIcon.flame)
                .font(.system(size: 12))
                .foregroundColor(.hlFlame)
                .accessibilityHidden(true)

            Text("\(streak) day\(streak == 1 ? "" : "s")")
                .font(HLFont.caption(.medium))
                .foregroundColor(.hlTextSecondary)
        }
    }

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
                        .frame(width: 36, height: 36)
                        .scaleEffect(justCompleted ? 2.2 : 1.0)
                        .opacity(justCompleted ? 0 : 0.4)
                        .animation(.easeOut(duration: 0.5), value: justCompleted)
                }

                // Progress ring
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 3)
                    .frame(width: 36, height: 36)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))

                // Checkmark or empty
                if isCompleted {
                    Circle()
                        .fill(color)
                        .frame(width: 28, height: 28)
                        .hlGlow(color, radius: 6, isActive: justCompleted)

                    Image(systemName: HLIcon.checkmark)
                        .font(.system(size: 14, weight: .bold))
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
