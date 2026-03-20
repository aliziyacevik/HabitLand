import SwiftUI
import SwiftData

struct HabitNotesView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var modelContext

    @State private var newNote = ""
    @FocusState private var isEditorFocused: Bool

    private var completionsWithNotes: [HabitCompletion] {
        habit.safeCompletions
            .filter { $0.note != nil && !($0.note?.isEmpty ?? true) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: HLSpacing.md) {
                    noteEditor
                    notesList
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.bottom, HLSpacing.xl)
            }
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Note Editor

    private var noteEditor: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Add a Note")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            TextEditor(text: $newNote)
                .font(HLFont.body())
                .foregroundStyle(Color.hlTextPrimary)
                .frame(minHeight: 100)
                .padding(HLSpacing.xs)
                .background(Color.hlBackground)
                .cornerRadius(HLRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .stroke(isEditorFocused ? habit.color : Color.hlCardBorder, lineWidth: 1)
                )
                .focused($isEditorFocused)

            HStack {
                Text("\(newNote.count) characters")
                    .font(HLFont.caption2())
                    .foregroundStyle(Color.hlTextTertiary)

                Spacer()

                Button {
                    saveNote()
                } label: {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: "plus.circle.fill")
                        Text("Save Note")
                    }
                    .font(HLFont.subheadline(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.vertical, HLSpacing.xs)
                    .background(newNote.isEmpty ? Color.hlTextTertiary : habit.color)
                    .clipShape(Capsule())
                }
                .disabled(newNote.isEmpty)
            }
        }
        .hlCard()
    }

    // MARK: - Notes List

    private var notesList: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack {
                Text("Past Notes")
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlTextPrimary)
                Spacer()
                Text("\(completionsWithNotes.count) notes")
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextTertiary)
            }

            if completionsWithNotes.isEmpty {
                VStack(spacing: HLSpacing.sm) {
                    Image(systemName: HLIcon.note)
                        .font(.system(size: 36))
                        .foregroundStyle(Color.hlTextTertiary)
                    Text("No notes yet")
                        .font(HLFont.subheadline())
                        .foregroundStyle(Color.hlTextSecondary)
                    Text("Add your first note above to track your thoughts")
                        .font(HLFont.caption())
                        .foregroundStyle(Color.hlTextTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.lg)
            } else {
                ForEach(completionsWithNotes) { completion in
                    noteCard(completion)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Note Card

    private func noteCard(_ completion: HabitCompletion) -> some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            HStack {
                Image(systemName: HLIcon.calendar)
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextTertiary)
                Text(completion.date, style: .date)
                    .font(HLFont.caption(.medium))
                    .foregroundStyle(Color.hlTextSecondary)
                Text(completion.date, style: .time)
                    .font(HLFont.caption())
                    .foregroundStyle(Color.hlTextTertiary)
                Spacer()

                if completion.isCompleted {
                    Image(systemName: HLIcon.checkmark)
                        .font(HLFont.caption2(.bold))
                        .foregroundStyle(Color.hlPrimary)
                }
            }

            Text(completion.note ?? "")
                .font(HLFont.body())
                .foregroundStyle(Color.hlTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HLSpacing.sm)
        .background(Color.hlBackground)
        .cornerRadius(HLRadius.md)
    }

    // MARK: - Actions

    private func saveNote() {
        let completion = HabitCompletion(
            date: Date(),
            isCompleted: true,
            count: 1,
            note: newNote
        )
        completion.habit = habit
        modelContext.insert(completion)
        newNote = ""
        isEditorFocused = false
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitNotesView(habit: {
            let h = Habit(name: "Journal", icon: "note.text", colorHex: "#FF9A1A", category: .mindfulness)
            h.completions = [
                {
                    let c = HabitCompletion(date: Date().addingTimeInterval(-86400), note: "Had a productive morning session. Felt very focused and clear-headed afterwards.")
                    return c
                }(),
                {
                    let c = HabitCompletion(date: Date().addingTimeInterval(-172800), note: "Struggled a bit today but pushed through. 10 minutes is better than nothing.")
                    return c
                }(),
                {
                    let c = HabitCompletion(date: Date().addingTimeInterval(-345600), note: "Best session this week!")
                    return c
                }(),
            ]
            return h
        }())
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
