import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var name = ""
    @State private var username = ""
    @State private var bio = ""
    @State private var selectedEmoji = "🌱"
    @State private var sleepGoal: Double = 8
    @State private var dailyHabitGoal: Int = 5
    @State private var showEmojiPicker = false
    @State private var didLoad = false

    private let emojiOptions = ["🌱", "🌿", "🌳", "🔥", "⭐️", "🚀", "💪", "🧘", "🌙", "🎯", "🦁", "🐺", "🦊", "🐻", "🦉", "🌸", "🌺", "🍀", "⚡️", "🎨"]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: HLSpacing.lg) {
                avatarSection
                formSection
                goalsSection
                saveButton
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.md)
        }
        .background(Color.hlBackground)
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !didLoad, let p = profile else { return }
            name = p.name
            username = p.username
            bio = p.bio
            selectedEmoji = p.avatarEmoji
            sleepGoal = p.sleepGoalHours
            dailyHabitGoal = p.dailyHabitGoal
            didLoad = true
        }
    }

    private var avatarSection: some View {
        VStack(spacing: HLSpacing.sm) {
            Button {
                withAnimation(HLAnimation.spring) {
                    showEmojiPicker.toggle()
                }
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    Text(selectedEmoji)
                        .font(.system(size: 56))
                        .frame(width: 96, height: 96)
                        .background(Color.hlPrimaryLight)
                        .clipShape(Circle())

                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.hlPrimary)
                        .background(Color.white.clipShape(Circle()))
                }
            }

            if showEmojiPicker {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: HLSpacing.sm) {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Button {
                            withAnimation(HLAnimation.quick) {
                                selectedEmoji = emoji
                                showEmojiPicker = false
                            }
                        } label: {
                            Text(emoji)
                                .font(.system(size: 32))
                                .frame(width: 48, height: 48)
                                .background(selectedEmoji == emoji ? Color.hlPrimaryLight : Color.clear)
                                .cornerRadius(HLRadius.sm)
                                .overlay(
                                    RoundedRectangle(cornerRadius: HLRadius.sm)
                                        .stroke(selectedEmoji == emoji ? Color.hlPrimary : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
                .hlCard()
            }
        }
    }

    private var formSection: some View {
        VStack(spacing: HLSpacing.md) {
            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                Text("Name")
                    .font(HLFont.caption(.semibold))
                    .foregroundColor(.hlTextSecondary)
                TextField("Your name", text: $name)
                    .font(HLFont.body())
                    .padding(HLSpacing.sm)
                    .background(Color.hlSurface)
                    .cornerRadius(HLRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: HLRadius.md)
                            .stroke(Color.hlDivider, lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                Text("Username")
                    .font(HLFont.caption(.semibold))
                    .foregroundColor(.hlTextSecondary)
                HStack {
                    Text("@")
                        .font(HLFont.body())
                        .foregroundColor(.hlTextTertiary)
                    TextField("username", text: $username)
                        .font(HLFont.body())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(HLSpacing.sm)
                .background(Color.hlSurface)
                .cornerRadius(HLRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .stroke(Color.hlDivider, lineWidth: 1)
                )
            }

            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                Text("Bio")
                    .font(HLFont.caption(.semibold))
                    .foregroundColor(.hlTextSecondary)
                TextField("Tell us about yourself...", text: $bio, axis: .vertical)
                    .font(HLFont.body())
                    .lineLimit(3...5)
                    .padding(HLSpacing.sm)
                    .background(Color.hlSurface)
                    .cornerRadius(HLRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: HLRadius.md)
                            .stroke(Color.hlDivider, lineWidth: 1)
                    )
            }
        }
        .hlCard()
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Goals")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                HStack {
                    Text("Sleep Goal")
                        .font(HLFont.subheadline())
                        .foregroundColor(.hlTextPrimary)
                    Spacer()
                    Text("\(String(format: "%.1f", sleepGoal))h")
                        .font(HLFont.subheadline(.semibold))
                        .foregroundColor(.hlPrimary)
                }
                Slider(value: $sleepGoal, in: 5...12, step: 0.5)
                    .tint(.hlPrimary)
            }

            VStack(alignment: .leading, spacing: HLSpacing.xs) {
                HStack {
                    Text("Daily Habit Goal")
                        .font(HLFont.subheadline())
                        .foregroundColor(.hlTextPrimary)
                    Spacer()
                    HStack(spacing: HLSpacing.sm) {
                        Button {
                            if dailyHabitGoal > 1 { dailyHabitGoal -= 1 }
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.hlTextSecondary)
                        }
                        Text("\(dailyHabitGoal)")
                            .font(HLFont.headline())
                            .foregroundColor(.hlPrimary)
                            .frame(width: 32)
                        Button {
                            if dailyHabitGoal < 20 { dailyHabitGoal += 1 }
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.hlPrimary)
                        }
                    }
                }
            }
        }
        .hlCard()
    }

    private var saveButton: some View {
        Button {
            saveProfile()
            dismiss()
        } label: {
            Text("Save Changes")
                .font(HLFont.headline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.sm)
                .background(Color.hlPrimary)
                .cornerRadius(HLRadius.md)
        }
    }

    private func saveProfile() {
        if let p = profile {
            p.name = name
            p.username = username
            p.bio = bio
            p.avatarEmoji = selectedEmoji
            p.sleepGoalHours = sleepGoal
            p.dailyHabitGoal = dailyHabitGoal
        } else {
            let p = UserProfile(name: name, username: username, avatarEmoji: selectedEmoji, bio: bio)
            p.sleepGoalHours = sleepGoal
            p.dailyHabitGoal = dailyHabitGoal
            modelContext.insert(p)
        }
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .modelContainer(for: UserProfile.self, inMemory: true)
    }
}
