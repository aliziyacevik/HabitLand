import SwiftUI

// MARK: - Friend Card Action

enum FriendCardAction {
    case add

    var label: String {
        switch self {
        case .add: return "Add"
        }
    }

    var icon: String {
        switch self {
        case .add: return HLIcon.personAdd
        }
    }
}

// MARK: - Friend Card

struct FriendCard: View {
    let friend: Friend
    var action: FriendCardAction = .add
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: HLSpacing.sm) {
            // Avatar
            AvatarView(name: friend.name, size: 48, avatarType: friend.avatarType)

            // Info
            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                HStack(spacing: HLSpacing.xs) {
                    Text(friend.name)
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)

                    // Level badge
                    Text("Lv.\(friend.level)")
                        .font(HLFont.caption2(.bold))
                        .foregroundColor(.hlPrimary)
                        .padding(.horizontal, HLSpacing.xs)
                        .padding(.vertical, HLSpacing.xxxs)
                        .background(Color.hlPrimaryLight)
                        .cornerRadius(HLRadius.full)
                }

                Text("@\(friend.username)")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextTertiary)
            }

            Spacer()

            // Streak
            VStack(spacing: HLSpacing.xxxs) {
                HStack(spacing: HLSpacing.xxxs) {
                    Image(systemName: HLIcon.flame)
                        .font(.system(size: 12))
                        .foregroundColor(.hlFlame)

                    Text("\(friend.currentStreak)")
                        .font(HLFont.footnote(.semibold))
                        .foregroundColor(.hlTextPrimary)
                }

                // Action button
                Button {
                    onAction?()
                } label: {
                    HStack(spacing: HLSpacing.xxxs) {
                        Image(systemName: action.icon)
                            .font(.system(size: 11))
                        Text(action.label)
                            .font(HLFont.caption2(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, HLSpacing.sm)
                    .padding(.vertical, HLSpacing.xs)
                    .background(Color.hlPrimary)
                    .cornerRadius(HLRadius.full)
                }
                .buttonStyle(.plain)
            }
        }
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HLSpacing.sm) {
        FriendCard(
            friend: Friend(
                name: "Alex Rivera",
                username: "alexr",
                avatarEmoji: "🦊",
                level: 12,
                currentStreak: 23
            ),
            action: .add
        )

        FriendCard(
            friend: Friend(
                name: "Jordan Lee",
                username: "jordanl",
                avatarEmoji: "🐻",
                level: 5,
                currentStreak: 7
            ),
            action: .add
        )
    }
    .padding()
}
