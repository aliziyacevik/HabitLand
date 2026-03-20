import SwiftUI
import SwiftData

// MARK: - SharedChallengesView

struct SharedChallengesView: View {
    @Query private var challenges: [Challenge]
    @Environment(\.modelContext) private var modelContext
    @State private var showCreateChallenge = false

    private var activeChallenges: [Challenge] {
        challenges.filter(\.isActive)
    }

    private var completedChallenges: [Challenge] {
        challenges.filter { !$0.isActive }
    }

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Challenges")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateChallenge = true
                    } label: {
                        Image(systemName: HLIcon.add)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.hlPrimary)
                    }
                }
            }
            .sheet(isPresented: $showCreateChallenge) {
                CreateChallengeView()
            }
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
                    .font(.system(size: 40))
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
                    .font(.system(size: 18, weight: .bold))
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
                    .font(.system(size: 14, weight: .semibold))
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
                    .font(.system(size: 20))
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
            }

            // Participants
            HStack(spacing: HLSpacing.xs) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 12))
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
                            .font(.system(size: 11))
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
                .font(.system(size: 18))
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
                .font(.system(size: 20))
                .foregroundColor(.hlSuccess)
        }
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    SharedChallengesView()
        .modelContainer(for: Challenge.self, inMemory: true)
}
