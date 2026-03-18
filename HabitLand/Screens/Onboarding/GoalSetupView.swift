import SwiftUI

struct GoalSetupView: View {
    @State private var dailyHabitGoal: Double = 5
    @State private var sleepGoalHours: Double = 8
    var onContinue: (Int, Double) -> Void = { _, _ in }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: HLSpacing.xxxl) {
                    // Header
                    VStack(spacing: HLSpacing.xs) {
                        Text("Set Your Goals")
                            .font(HLFont.largeTitle())
                            .foregroundColor(.hlTextPrimary)

                        Text("We'll use these to personalize your experience.")
                            .font(HLFont.body())
                            .foregroundColor(.hlTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, HLSpacing.xxl)

                    // Daily Habit Goal
                    VStack(spacing: HLSpacing.lg) {
                        VStack(spacing: HLSpacing.xxs) {
                            Text("\(Int(dailyHabitGoal))")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(.hlPrimary)

                            Text("daily habits")
                                .font(HLFont.callout())
                                .foregroundColor(.hlTextSecondary)
                        }

                        VStack(spacing: HLSpacing.xs) {
                            Slider(value: $dailyHabitGoal, in: 1...10, step: 1)
                                .tint(.hlPrimary)

                            HStack {
                                Text("1")
                                    .font(HLFont.caption(.medium))
                                    .foregroundColor(.hlTextTertiary)
                                Spacer()
                                Text("10")
                                    .font(HLFont.caption(.medium))
                                    .foregroundColor(.hlTextTertiary)
                            }
                        }
                        .padding(.horizontal, HLSpacing.md)
                    }
                    .padding(HLSpacing.lg)
                    .background(Color.hlSurface)
                    .cornerRadius(HLRadius.xl)
                    .hlShadow(HLShadow.sm)

                    // Sleep Goal
                    VStack(spacing: HLSpacing.lg) {
                        VStack(spacing: HLSpacing.xxs) {
                            HStack(alignment: .firstTextBaseline, spacing: HLSpacing.xxs) {
                                Text(sleepGoalFormatted.hours)
                                    .font(.system(size: 64, weight: .bold, design: .rounded))
                                    .foregroundColor(.hlSleep)

                                Text("h")
                                    .font(HLFont.title2())
                                    .foregroundColor(.hlSleep)

                                if !sleepGoalFormatted.minutes.isEmpty {
                                    Text(sleepGoalFormatted.minutes)
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .foregroundColor(.hlSleep)

                                    Text("m")
                                        .font(HLFont.title2())
                                        .foregroundColor(.hlSleep)
                                }
                            }

                            Text("sleep per night")
                                .font(HLFont.callout())
                                .foregroundColor(.hlTextSecondary)
                        }

                        VStack(spacing: HLSpacing.xs) {
                            Slider(value: $sleepGoalHours, in: 5...12, step: 0.5)
                                .tint(.hlSleep)

                            HStack {
                                Text("5h")
                                    .font(HLFont.caption(.medium))
                                    .foregroundColor(.hlTextTertiary)
                                Spacer()
                                Text("12h")
                                    .font(HLFont.caption(.medium))
                                    .foregroundColor(.hlTextTertiary)
                            }
                        }
                        .padding(.horizontal, HLSpacing.md)
                    }
                    .padding(HLSpacing.lg)
                    .background(Color.hlSurface)
                    .cornerRadius(HLRadius.xl)
                    .hlShadow(HLShadow.sm)
                }
                .padding(.horizontal, HLSpacing.lg)
                .padding(.bottom, HLSpacing.xl)
            }

            // Continue button
            HLButton(
                "Continue",
                style: .primary,
                size: .lg,
                isFullWidth: true
            ) {
                onContinue(Int(dailyHabitGoal), sleepGoalHours)
            }
            .padding(.horizontal, HLSpacing.lg)
            .padding(.bottom, HLSpacing.xxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
    }

    // MARK: - Helpers

    private var sleepGoalFormatted: (hours: String, minutes: String) {
        let h = Int(sleepGoalHours)
        let m = Int((sleepGoalHours - Double(h)) * 60)
        return ("\(h)", m > 0 ? "\(m)" : "")
    }
}

#Preview {
    GoalSetupView()
}
