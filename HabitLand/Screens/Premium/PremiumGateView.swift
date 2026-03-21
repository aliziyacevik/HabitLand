import SwiftUI

// MARK: - Premium Gate Overlay

struct PremiumGateView: View {
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
                        .font(.system(size: 32))
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
    let feature: String
    let icon: String
    let paywallContext: PaywallContext
    @ObservedObject private var proManager = ProManager.shared
    @State private var showPaywall = false

    private var isScreenshotMode: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-screenshotMode")
        #else
        return false
        #endif
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
                            .font(.system(size: 28))
                            .foregroundStyle(Color.hlPrimary)
                    }

                    Text("Unlock \(feature)")
                        .font(HLFont.title2(.bold))
                        .foregroundStyle(Color.hlTextPrimary)

                    Text(paywallContext.description)
                        .font(HLFont.subheadline())
                        .foregroundStyle(Color.hlTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, HLSpacing.md)

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
            }
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
