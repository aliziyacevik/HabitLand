import SwiftUI

struct LevelBadge: View {
    let level: Int
    let xpProgress: Double // 0.0 to 1.0
    let title: String
    var size: BadgeSize = .md

    enum BadgeSize {
        case sm, md, lg

        var diameter: CGFloat {
            switch self {
            case .sm: return 40
            case .md: return 64
            case .lg: return 96
            }
        }

        var ringWidth: CGFloat {
            switch self {
            case .sm: return 3
            case .md: return 4
            case .lg: return 6
            }
        }

        var levelFont: Font {
            switch self {
            case .sm: return HLFont.caption(.bold)
            case .md: return HLFont.title3(.bold)
            case .lg: return HLFont.title1(.bold)
            }
        }

        var titleFont: Font {
            switch self {
            case .sm: return HLFont.caption2()
            case .md: return HLFont.caption(.medium)
            case .lg: return HLFont.footnote(.medium)
            }
        }

        var showTitle: Bool {
            self != .sm
        }
    }

    var body: some View {
        VStack(spacing: HLSpacing.xxs) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.hlDivider, lineWidth: size.ringWidth)

                // Progress ring
                Circle()
                    .trim(from: 0, to: xpProgress)
                    .stroke(
                        Color.hlPrimary,
                        style: StrokeStyle(
                            lineWidth: size.ringWidth,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                // Inner fill
                Circle()
                    .fill(Color.hlPrimaryLight)
                    .padding(size.ringWidth + 2)

                // Level number
                Text("\(level)")
                    .font(size.levelFont)
                    .foregroundStyle(Color.hlPrimaryDark)
            }
            .frame(width: size.diameter, height: size.diameter)

            if size.showTitle {
                Text(title)
                    .font(size.titleFont)
                    .foregroundStyle(Color.hlTextSecondary)
            }
        }
    }
}

#Preview {
    HStack(spacing: HLSpacing.xl) {
        LevelBadge(level: 3, xpProgress: 0.45, title: "Seedling", size: .sm)
        LevelBadge(level: 12, xpProgress: 0.7, title: "Sapling", size: .md)
        LevelBadge(level: 42, xpProgress: 0.25, title: "Forest", size: .lg)
    }
    .padding()
}
