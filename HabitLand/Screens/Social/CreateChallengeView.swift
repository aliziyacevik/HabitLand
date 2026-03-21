import SwiftUI
import SwiftData

struct CreateChallengeView: View {
    var inviteFriend: Friend?

    @State private var name = ""
    @State private var description = ""
    @State private var selectedCategory: HabitCategory = .health
    @State private var durationDays = 7
    @State private var isCreating = false
    @State private var created = false

    @StateObject private var cloudKit = CloudKitManager.shared
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let durationOptions = [3, 7, 14, 21, 30]

    private let challengeIcons: [(icon: String, label: String)] = [
        ("flame.fill", "Streak"),
        ("figure.run", "Fitness"),
        ("brain.head.profile", "Focus"),
        ("book.fill", "Reading"),
        ("drop.fill", "Hydration"),
        ("moon.fill", "Sleep"),
    ]

    @State private var selectedIcon = "flame.fill"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hlBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HLSpacing.lg) {
                        nameSection
                        iconSection
                        categorySection
                        durationSection

                        if let friend = inviteFriend {
                            invitePreview(friend)
                        }

                        createButton
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.vertical, HLSpacing.md)
                }
            }
            .navigationTitle("New Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.hlTextSecondary)
                }
            }
        }
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Challenge Name")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            TextField("e.g. 7-Day Meditation Sprint", text: $name)
                .font(HLFont.body())
                .padding(HLSpacing.sm)
                .background(Color.hlSurface)
                .cornerRadius(HLRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .stroke(Color.hlDivider, lineWidth: 1)
                )

            TextField("Description (optional)", text: $description)
                .font(HLFont.body())
                .padding(HLSpacing.sm)
                .background(Color.hlSurface)
                .cornerRadius(HLRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .stroke(Color.hlDivider, lineWidth: 1)
                )
        }
        .hlCard()
    }

    // MARK: - Icon

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Icon")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: HLSpacing.sm) {
                ForEach(challengeIcons, id: \.icon) { item in
                    Button {
                        selectedIcon = item.icon
                        HLHaptics.selection()
                    } label: {
                        VStack(spacing: HLSpacing.xxs) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedIcon == item.icon ? .white : .hlPrimary)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == item.icon ? Color.hlPrimary : Color.hlPrimaryLight)
                                .cornerRadius(HLRadius.md)

                            Text(item.label)
                                .font(HLFont.caption2())
                                .foregroundColor(.hlTextTertiary)
                        }
                    }
                }
            }
        }
        .hlCard()
    }

    // MARK: - Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Category")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.xs) {
                    ForEach(HabitCategory.allCases, id: \.self) { category in
                        Button {
                            selectedCategory = category
                            HLHaptics.selection()
                        } label: {
                            HStack(spacing: HLSpacing.xxs) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 12))
                                Text(category.rawValue)
                                    .font(HLFont.caption(.semibold))
                            }
                            .foregroundColor(selectedCategory == category ? .white : .hlTextSecondary)
                            .padding(.horizontal, HLSpacing.sm)
                            .padding(.vertical, HLSpacing.xs)
                            .background(selectedCategory == category ? Color.hlPrimary : Color.hlSurface)
                            .cornerRadius(HLRadius.full)
                        }
                    }
                }
            }
        }
        .hlCard()
    }

    // MARK: - Duration

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Duration")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            HStack(spacing: HLSpacing.xs) {
                ForEach(durationOptions, id: \.self) { days in
                    Button {
                        durationDays = days
                        HLHaptics.selection()
                    } label: {
                        Text("\(days)d")
                            .font(HLFont.subheadline(.semibold))
                            .foregroundColor(durationDays == days ? .white : .hlTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, HLSpacing.xs)
                            .background(durationDays == days ? Color.hlPrimary : Color.hlSurface)
                            .cornerRadius(HLRadius.sm)
                    }
                }
            }
        }
        .hlCard()
    }

    // MARK: - Invite Preview

    private func invitePreview(_ friend: Friend) -> some View {
        HStack(spacing: HLSpacing.sm) {
            AvatarView(name: friend.name, size: 40)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text("Challenging \(friend.name)")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)
                Text("They'll receive an invitation to join")
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.hlSuccess)
        }
        .hlCard()
    }

    // MARK: - Create Button

    private var createButton: some View {
        Button {
            createChallenge()
        } label: {
            HStack(spacing: HLSpacing.xs) {
                if isCreating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: HLIcon.challenge)
                    Text("Create Challenge")
                }
            }
            .font(HLFont.headline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, HLSpacing.md)
            .background(name.isEmpty ? Color.hlTextTertiary : Color.hlPrimary)
            .cornerRadius(HLRadius.lg)
        }
        .disabled(name.isEmpty || isCreating)
    }

    // MARK: - Create

    private func createChallenge() {
        isCreating = true
        Task {
            if let ckRecord = await cloudKit.createChallenge(
                name: name,
                description: description,
                icon: selectedIcon,
                durationDays: durationDays,
                habitCategory: selectedCategory.rawValue
            ) {
                // Save locally
                let challenge = Challenge(
                    name: name,
                    descriptionText: description,
                    icon: selectedIcon,
                    endDate: Date().addingTimeInterval(Double(durationDays) * 86400)
                )
                challenge.cloudKitRecordName = ckRecord.recordID.recordName
                modelContext.insert(challenge)
                try? modelContext.save()

                // Invite friend if specified
                if let friend = inviteFriend, let friendCK = friend.cloudKitRecordName {
                    _ = await cloudKit.inviteFriendToChallenge(
                        friendRecordName: friendCK,
                        challengeRecordName: ckRecord.recordID.recordName
                    )
                }

                HLHaptics.success()
                dismiss()
            }
            isCreating = false
        }
    }
}

#Preview {
    CreateChallengeView()
        .modelContainer(for: Challenge.self, inMemory: true)
}
