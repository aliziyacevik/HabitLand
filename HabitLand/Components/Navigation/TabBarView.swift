import SwiftUI

// MARK: - Tab Definition

enum HLTab: Int, CaseIterable, Identifiable {
    case home, habits, sleep, profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .habits: return "Habits"
        case .sleep: return "Sleep"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return HLIcon.home
        case .habits: return HLIcon.habits
        case .sleep: return HLIcon.sleep
        case .profile: return HLIcon.profile
        }
    }
}

// MARK: - Tab Bar View

struct TabBarView: View {
    @Binding var selectedTab: HLTab
    @ObservedObject private var proManager = ProManager.shared

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HLTab.allCases) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    isPro: proManager.isPro
                ) {
                    withAnimation(HLAnimation.spring) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, HLSpacing.xs)
        .padding(.top, HLSpacing.xs)
        .padding(.bottom, HLSpacing.xxs)
        .background(
            Color.hlSurface
                .hlShadow(HLShadow.md)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Tab Bar Item

private struct TabBarItem: View {
    @ScaledMetric(relativeTo: .title3) private var tabIconSize: CGFloat = 22
    @ScaledMetric(relativeTo: .caption2) private var crownSize: CGFloat = 8

    let tab: HLTab
    let isSelected: Bool
    let isPro: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: HLSpacing.xxs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: min(tabIconSize, 26), weight: isSelected ? .semibold : .regular))
                        .scaleEffect(isSelected ? 1.1 : 1.0)

                    if tab == .sleep && !isPro {
                        Image(systemName: "crown.fill")
                            .font(.system(size: min(crownSize, 10)))
                            .foregroundStyle(Color.hlGold)
                            .offset(x: 6, y: -2)
                            .accessibilityHidden(true)
                    }
                }

                Text(tab.title)
                    .font(HLFont.caption2(isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .hlPrimary : .hlTextTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.xxs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var tab: HLTab = .home
        var body: some View {
            VStack {
                Spacer()
                TabBarView(selectedTab: $tab)
            }
            .background(Color.hlBackground)
        }
    }
    return PreviewWrapper()
}
