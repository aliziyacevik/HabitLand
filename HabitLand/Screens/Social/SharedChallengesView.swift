import SwiftUI
import SwiftData

// MARK: - SharedChallengesView

struct SharedChallengesView: View {
    @ScaledMetric(relativeTo: .title) private var emptyIconSize: CGFloat = 40
    @ScaledMetric(relativeTo: .caption) private var clockIconSize: CGFloat = 11
    @ScaledMetric(relativeTo: .caption) private var participantsIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var chevronSize: CGFloat = 14
    @ScaledMetric(relativeTo: .footnote) private var toolbarIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var cardIconSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) private var challengeIconSize: CGFloat = 20
    @Query private var challenges: [Challenge]
    @Query private var profiles: [UserProfile]
    private var profile: UserProfile? { profiles.first }
    @Environment(\.modelContext) private var modelContext
    @State private var showCreateChallenge = false

    private var activeChallenges: [Challenge] {
        challenges.filter(\.isActive)
    }

    private var completedChallenges: [Challenge] {
        challenges.filter { !$0.isActive }
    }

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            if challenges.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: HLSpacing.lg) {
                        createChallengeButton
                        if !activeChallenges.isEmpty {
                            activeChallengesSection
                        }
                        if !completedChallenges.isEmpty {
                            completedChallengesSection
                        }
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.top, HLSpacing.sm)
                    .padding(.bottom, HLSpacing.xxxl)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateChallenge = true
                } label: {
                    Image(systemName: HLIcon.add)
                        .font(.system(size: min(toolbarIconSize, 20), weight: .semibold))
                        .foregroundStyle(Color.hlPrimary)
                }
            }
        }
        .sheet(isPresented: $showCreateChallenge) {
            CreateChallengeView()
                .hlSheetContent()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.hlPrimary.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: HLIcon.challenge)
                    .font(.system(size: min(emptyIconSize, 48)))
                    .foregroundStyle(Color.hlPrimary.opacity(0.5))
            }

            Text("No challenges yet")
                .font(HLFont.title3(.semibold))
                .foregroundStyle(Color.hlTextPrimary)

            Text("Create a challenge and invite\nfriends to stay accountable together.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                showCreateChallenge = true
            } label: {
                HStack(spacing: HLSpacing.xs) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Challenge")
                }
                .font(HLFont.subheadline(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, HLSpacing.lg)
                .padding(.vertical, HLSpacing.sm)
                .background(Color.hlPrimary)
                .clipShape(Capsule())
            }
            .padding(.top, HLSpacing.xs)

            Spacer()
        }
    }

    // MARK: - Create Challenge Button

    private var createChallengeButton: some View {
        Button {
            showCreateChallenge = true
        } label: {
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: HLIcon.add)
                    .font(.system(size: min(cardIconSize, 22), weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.hlPrimary)
                    .cornerRadius(HLRadius.full)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text("Create Challenge")
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)
                    Text("Invite friends to a new challenge")
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: min(chevronSize, 18), weight: .semibold))
                    .foregroundColor(.hlTextTertiary)
            }
            .hlCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Active Challenges Section

    private var activeChallengesSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("Active")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                Spacer()
                Text("\(activeChallenges.count) challenge\(activeChallenges.count == 1 ? "" : "s")")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextTertiary)
            }

            ForEach(activeChallenges) { challenge in
                challengeCard(challenge)
            }
        }
    }

    // MARK: - Completed Challenges Section

    private var completedChallengesSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("Completed")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                Spacer()
                Text("\(completedChallenges.count) challenge\(completedChallenges.count == 1 ? "" : "s")")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextTertiary)
            }

            ForEach(completedChallenges) { challenge in
                completedCard(challenge)
            }
        }
    }

    // MARK: - Challenge Card

    private func challengeCard(_ challenge: Challenge) -> some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            // Header
            HStack(spacing: HLSpacing.sm) {
                Image(systemName: challenge.icon)
                    .font(.system(size: min(challengeIconSize, 24)))
                    .foregroundColor(.hlPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.hlPrimaryLight)
                    .cornerRadius(HLRadius.sm)

                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text(challenge.name)
                        .font(HLFont.headline())
                        .foregroundColor(.hlTextPrimary)

                    Text(challenge.descriptionText)
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                if let shareURL = URL(string: challengeShareURL) {
                    ShareLink(
                        item: shareURL,
                        subject: Text(challenge.name),
                        message: Text(challengeShareMessage(for: challenge))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: min(chevronSize, 18)))
                            .foregroundColor(.hlTextSecondary)
                    }
                }
            }

            // Participants
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: min(participantsIconSize, 16)))
                    .foregroundColor(.hlTextTertiary)
                Text("\(challenge.participantCount) participants")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            // Progress
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                HStack {
                    Text("\(Int(challenge.progress * 100))% complete")
                        .font(HLFont.caption(.medium))
                        .foregroundColor(.hlTextSecondary)
                    Spacer()
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: HLIcon.clock)
                            .font(.system(size: min(clockIconSize, 15)))
                        Text("\(challenge.daysRemaining)d left")
                            .font(HLFont.caption(.medium))
                    }
                    .foregroundColor(challenge.daysRemaining <= 2 ? .hlWarning : .hlTextTertiary)
                }

                ProgressView(value: challenge.progress)
                    .tint(challenge.progress >= 0.8 ? .hlPrimary : .hlInfo)
            }
        }
        .hlCard()
    }

    // MARK: - Completed Card

    private func completedCard(_ challenge: Challenge) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: challenge.icon)
                .font(.system(size: min(cardIconSize, 22)))
                .foregroundColor(.hlPrimary)
                .frame(width: 36, height: 36)
                .background(Color.hlPrimaryLight)
                .cornerRadius(HLRadius.sm)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(challenge.name)
                    .font(HLFont.subheadline(.medium))
                    .foregroundColor(.hlTextPrimary)

                Text("\(challenge.participantCount) participants")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: min(challengeIconSize, 24)))
                .foregroundColor(.hlSuccess)
        }
        .hlCard()
    }

    // MARK: - Share Helpers

    private var isTurkish: Bool {
        Locale.current.language.languageCode == .turkish
    }

    private var challengeShareURL: String {
        let baseURL = "https://apps.apple.com/app/habitland/id000000000"
        if let code = profile?.referralCode {
            return "\(baseURL)?ref=\(code)"
        }
        return baseURL
    }

    private func challengeShareMessage(for challenge: Challenge) -> String {
        if isTurkish {
            return "Bu challenge'a katil! \(challenge.name) -- HabitLand'i indir ve birlikte aliskanlik olusturalim!"
        } else {
            return "Join this challenge! \(challenge.name) -- Download HabitLand and let's build habits together!"
        }
    }
}

// MARK: - Preview

#Preview {
    SharedChallengesView()
        .modelContainer(for: Challenge.self, inMemory: true)
}
