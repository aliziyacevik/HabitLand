import SwiftUI

// MARK: - Challenge Card

struct ChallengeCard: View {
    let challenge: Challenge
    var isJoined: Bool = false
    var onJoin: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            // Header row
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: challenge.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.hlPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.hlPrimaryLight)
                    .cornerRadius(HLRadius.sm)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text(challenge.name)
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)
                        .lineLimit(1)

                    Text(challenge.descriptionText)
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            // Progress bar
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                ProgressView(value: challenge.progress, total: 1.0)
                    .tint(.hlPrimary)

                HStack {
                    Text("\(Int(challenge.progress * 100))% complete")
                        .font(HLFont.caption2(.medium))
                        .foregroundColor(.hlTextSecondary)

                    Spacer()
                }
            }

            // Footer: participants, days remaining, join button
            HStack {
                // Participants
                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: HLIcon.social)
                        .font(.system(size: 12))
                        .foregroundColor(.hlTextTertiary)

                    Text("\(challenge.participantCount) joined")
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }

                // Days remaining
                HStack(spacing: HLSpacing.xxs) {
                    Image(systemName: HLIcon.clock)
                        .font(.system(size: 12))
                        .foregroundColor(.hlTextTertiary)

                    Text("\(challenge.daysRemaining)d left")
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }

                Spacer()

                // Join / Joined button
                Button {
                    onJoin?()
                } label: {
                    Text(isJoined ? "Joined" : "Join")
                        .font(HLFont.caption(.semibold))
                        .foregroundColor(isJoined ? .hlPrimary : .white)
                        .padding(.horizontal, HLSpacing.md)
                        .padding(.vertical, HLSpacing.xs)
                        .background(isJoined ? Color.hlPrimaryLight : Color.hlPrimary)
                        .cornerRadius(HLRadius.full)
                }
                .buttonStyle(.plain)
                .disabled(isJoined)
            }
        }
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HLSpacing.md) {
        ChallengeCard(
            challenge: {
                let c = Challenge(
                    name: "30-Day Meditation",
                    descriptionText: "Meditate for at least 10 minutes every day for 30 days.",
                    icon: "brain.head.profile",
                    participantCount: 128
                )
                c.progress = 0.45
                return c
            }(),
            isJoined: false
        )

        ChallengeCard(
            challenge: {
                let c = Challenge(
                    name: "Hydration Hero",
                    descriptionText: "Drink 8 glasses of water daily for a week.",
                    icon: "drop.fill",
                    participantCount: 56
                )
                c.progress = 0.72
                return c
            }(),
            isJoined: true
        )
    }
    .padding()
}
