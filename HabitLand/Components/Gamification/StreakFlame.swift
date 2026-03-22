import SwiftUI
import UIKit

struct StreakFlame: View {
    let count: Int
    var size: FlameSize = .md
    var isActive: Bool { count > 0 }

    @State private var isPulsing = false
    @State private var flameBurst = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum FlameSize {
        case sm, md, lg

        var iconSize: CGFloat {
            switch self {
            case .sm: return 16
            case .md: return 24
            case .lg: return 36
            }
        }

        var fontSize: Font {
            switch self {
            case .sm: return HLFont.caption2(.bold)
            case .md: return HLFont.footnote(.bold)
            case .lg: return HLFont.title3(.bold)
            }
        }

        var spacing: CGFloat {
            switch self {
            case .sm: return HLSpacing.xxxs
            case .md: return HLSpacing.xxs
            case .lg: return HLSpacing.xs
            }
        }

        var glowRadius: CGFloat {
            switch self {
            case .sm: return 4
            case .md: return 8
            case .lg: return 14
            }
        }
    }

    var body: some View {
        HStack(spacing: size.spacing) {
            Image(systemName: HLIcon.flame)
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundStyle(isActive ? Color.hlFlame : Color.hlTextTertiary)
                .accessibilityHidden(true)
                .shadow(
                    color: isActive ? Color.hlFlame.opacity(isPulsing ? 0.6 : 0.2) : .clear,
                    radius: size.glowRadius
                )
                .scaleEffect(flameBurst ? 1.4 : (isActive && isPulsing ? 1.1 : 1.0))
                .offset(y: flameBurst ? -4 : 0)

            Text("\(count)")
                .font(size.fontSize)
                .foregroundStyle(isActive ? Color.hlTextPrimary : Color.hlTextTertiary)
                .contentTransition(.numericText())
        }
        .animation(HLAnimation.celebration, value: flameBurst)
        .onAppear {
            guard isActive, !reduceMotion else { return }
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
        .onChange(of: count) { oldValue, newValue in
            if newValue > oldValue && newValue > 0 {
                HLHaptics.success()
                guard !reduceMotion else { return }
                flameBurst = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    flameBurst = false
                }
            }
            guard !reduceMotion else { return }
            if newValue > 0 {
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }
}

#Preview {
    VStack(spacing: HLSpacing.xl) {
        StreakFlame(count: 0, size: .sm)
        StreakFlame(count: 7, size: .sm)
        StreakFlame(count: 14, size: .md)
        StreakFlame(count: 42, size: .lg)
    }
    .padding()
}
