import SwiftUI
import SwiftData

// MARK: - Premium Gate Overlay

struct PremiumGateView: View {
    @ScaledMetric(relativeTo: .title) private var gateIconSize: CGFloat = 32
    let feature: String
    let icon: String
    var comingSoon: Bool = false
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer()

            VStack(spacing: HLSpacing.md) {
                ZStack {
                    Circle()
                        .fill(comingSoon ? Color.hlGold.opacity(0.12) : Color.hlPrimary.opacity(0.12))
                        .frame(width: 80, height: 80)

                    Image(systemName: comingSoon ? icon : "lock.fill")
                        .font(.system(size: min(gateIconSize, 36)))
                        .foregroundStyle(comingSoon ? Color.hlGold : Color.hlPrimary)
                }

                if comingSoon {
                    Text("Coming Soon")
                        .font(HLFont.caption(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, HLSpacing.sm)
                        .padding(.vertical, HLSpacing.xxs)
                        .background(
                            LinearGradient(
                                colors: [Color.hlGold, Color.hlFlame],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }

                Text("Pro Feature")
                    .font(HLFont.title2(.bold))
                    .foregroundStyle(Color.hlTextPrimary)

                Text(comingSoon
                    ? "\(feature) will be available with HabitLand Pro.\nWe're working hard to bring this to you!"
                    : "\(feature) is available with HabitLand Pro")
                    .font(HLFont.body())
                    .foregroundStyle(Color.hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HLSpacing.xl)

                Button {
                    showPaywall = true
                    HLHaptics.medium()
                } label: {
                    HStack(spacing: HLSpacing.xs) {
                        Image(systemName: "crown.fill")
                        Text("Upgrade to Pro")
                    }
                    .font(HLFont.headline())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.md)
                    .background(
                        LinearGradient(
                            colors: [Color.hlPrimary, Color.hlPrimaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(HLRadius.lg)
                }
                .padding(.horizontal, HLSpacing.xl)
                .padding(.top, HLSpacing.xs)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.hlBackground.ignoresSafeArea())
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .hlSheetContent()
        }
    }
}

// MARK: - View Modifier for Premium Gating

struct PremiumGateModifier: ViewModifier {
    let feature: String
    let icon: String
    var comingSoon: Bool = false
    @ObservedObject private var proManager = ProManager.shared

    private var isScreenshotMode: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-screenshotMode")
        #else
        return false
        #endif
    }

    func body(content: Content) -> some View {
        if proManager.isPro && (!comingSoon || isScreenshotMode) {
            content
        } else {
            PremiumGateView(feature: feature, icon: icon, comingSoon: comingSoon)
        }
    }
}

extension View {
    func premiumGated(feature: String, icon: String = "lock.fill", comingSoon: Bool = false) -> some View {
        modifier(PremiumGateModifier(feature: feature, icon: icon, comingSoon: comingSoon))
    }
}

// MARK: - Small Pro Badge (for inline use)

struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(HLFont.caption2(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                LinearGradient(
                    colors: [Color.hlPrimary, Color.hlPrimaryDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
    }
}

// MARK: - Blurred Premium Gate (shows content behind blur)

struct BlurredPremiumGateModifier: ViewModifier {
    @ScaledMetric(relativeTo: .caption) private var statIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .title3) private var lockIconSize: CGFloat = 28
    let feature: String
    let icon: String
    let paywallContext: PaywallContext
    @ObservedObject private var proManager = ProManager.shared
    @Query private var habits: [Habit]
    @Query private var sleepLogs: [SleepLog]
    @State private var showPaywall = false

    private var isScreenshotMode: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-screenshotMode")
        #else
        return false
        #endif
    }

    private var hasTrialData: Bool {
        sleepLogs.count > 0 || habits.count > 0
    }

    func body(content: Content) -> some View {
        if proManager.isPro || isScreenshotMode {
            content
        } else {
            ZStack {
                content
                    .blur(radius: 10)
                    .allowsHitTesting(false)

                VStack(spacing: HLSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.hlPrimary.opacity(0.12))
                            .frame(width: 72, height: 72)
                        Image(systemName: "lock.fill")
                            .font(.system(size: min(lockIconSize, 32)))
                            .foregroundStyle(Color.hlPrimary)
                    }

                    Text("Unlock \(feature)")
                        .font(HLFont.title2(.bold))
                        .foregroundStyle(Color.hlTextPrimary)

                    if hasTrialData {
                        personalizedLossCard
                    } else {
                        Text(paywallContext.description)
                            .font(HLFont.subheadline())
                            .foregroundStyle(Color.hlTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, HLSpacing.md)
                    }

                    Button {
                        showPaywall = true
                        HLHaptics.medium()
                    } label: {
                        HStack(spacing: HLSpacing.xs) {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Pro")
                        }
                        .font(HLFont.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: 280)
                        .padding(.vertical, HLSpacing.md)
                        .background(
                            LinearGradient(
                                colors: [Color.hlPrimary, Color.hlPrimaryDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(HLRadius.lg)
                    }
                }
                .padding(HLSpacing.xl)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: paywallContext)
                    .hlSheetContent()
            }
        }
    }

    @ViewBuilder
    private var personalizedLossCard: some View {
        VStack(spacing: HLSpacing.sm) {
            Text("Don't lose your progress")
                .font(HLFont.subheadline(.semibold))
                .foregroundStyle(Color.hlFlame)

            VStack(spacing: HLSpacing.xs) {
                if sleepLogs.count > 0 {
                    let avgHours = sleepLogs.map(\.durationHours).reduce(0, +) / Double(sleepLogs.count)
                    lossRow(
                        icon: "moon.fill",
                        color: .hlSleep,
                        text: "\(sleepLogs.count) nights logged · \(String(format: "%.1f", avgHours))h avg"
                    )
                }
                if habits.count > 0 {
                    let totalCompletions = habits.reduce(0) { $0 + $1.totalCompletions }
                    let bestStreak = habits.map(\.bestStreak).max() ?? 0
                    lossRow(
                        icon: "checkmark.circle.fill",
                        color: .hlPrimary,
                        text: "\(habits.count) habits · \(totalCompletions) completions · \(bestStreak)d streak"
                    )
                }
            }
        }
        .padding(HLSpacing.md)
        .background(Color.hlFlame.opacity(0.06))
        .cornerRadius(HLRadius.md)
        .padding(.horizontal, HLSpacing.sm)
    }

    private func lossRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: HLSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: min(statIconSize, 14)))
                .foregroundStyle(color)
                .frame(width: 18)
            Text(text)
                .font(HLFont.caption())
                .foregroundStyle(Color.hlTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Spacer()
        }
    }
}

extension View {
    func blurredPremiumGate(feature: String, icon: String, context: PaywallContext) -> some View {
        modifier(BlurredPremiumGateModifier(feature: feature, icon: icon, paywallContext: context))
    }
}

#Preview {
    PremiumGateView(feature: "Advanced Analytics", icon: "chart.bar.fill")
}
