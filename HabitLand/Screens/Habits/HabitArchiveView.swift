import SwiftUI
import SwiftData

struct HabitArchiveView: View {
    @Query(filter: #Predicate<Habit> { $0.isArchived }) private var archivedHabits: [Habit]
    @Environment(\.modelContext) private var modelContext

    @State private var habitToDelete: Habit?
    @State private var showDeleteAlert = false

    var body: some View {
        Group {
            if archivedHabits.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: HLSpacing.sm) {
                        ForEach(archivedHabits) { habit in
                            archivedHabitCard(habit)
                        }
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.bottom, HLSpacing.xl)
                }
            }
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Archived Habits")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Permanently?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let habit = habitToDelete {
                    modelContext.delete(habit)
                    habitToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                habitToDelete = nil
            }
        } message: {
            Text("This will permanently delete the habit and all its history. This cannot be undone.")
        }
    }

    // MARK: - Archived Habit Card

    private func archivedHabitCard(_ habit: Habit) -> some View {
        VStack(spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.sm) {
                // Icon
                ZStack {
                    Circle()
                        .fill(habit.color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: habit.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(habit.color)
                }

                // Info
                VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                    Text(habit.name)
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)

                    HStack(spacing: HLSpacing.xs) {
                        HStack(spacing: HLSpacing.xxxs) {
                            Image(systemName: habit.category.icon)
                                .font(HLFont.caption2())
                            Text(habit.category.rawValue)
                                .font(HLFont.caption(.medium))
                        }
                        .foregroundStyle(Color.hlTextSecondary)

                        Text("archived")
                            .font(HLFont.caption2(.medium))
                            .foregroundStyle(Color.hlTextTertiary)
                            .padding(.horizontal, HLSpacing.xxs)
                            .padding(.vertical, HLSpacing.xxxs)
                            .background(Color.hlDivider)
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                // Stats
                VStack(alignment: .trailing, spacing: HLSpacing.xxxs) {
                    Text("\(habit.totalCompletions)")
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlTextPrimary)
                    Text("completions")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }

            Divider().overlay(Color.hlDivider)

            // Action Buttons
            HStack(spacing: HLSpacing.md) {
                Button {
                    restoreHabit(habit)
                } label: {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: "arrow.uturn.backward.circle")
                        Text("Restore")
                    }
                    .font(HLFont.subheadline(.medium))
                    .foregroundStyle(Color.hlPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.xs)
                    .background(Color.hlPrimary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: HLRadius.sm))
                }

                Button {
                    habitToDelete = habit
                    showDeleteAlert = true
                } label: {
                    HStack(spacing: HLSpacing.xxs) {
                        Image(systemName: HLIcon.delete)
                        Text("Delete")
                    }
                    .font(HLFont.subheadline(.medium))
                    .foregroundStyle(Color.hlError)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.xs)
                    .background(Color.hlError.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: HLRadius.sm))
                }
            }
        }
        .hlCard()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.hlPrimaryLight)
                    .frame(width: 80, height: 80)
                Image(systemName: HLIcon.archive)
                    .font(.system(size: 36))
                    .foregroundStyle(Color.hlPrimary)
            }

            Text("No Archived Habits")
                .font(HLFont.title3())
                .foregroundStyle(Color.hlTextPrimary)

            Text("When you archive a habit, it will appear here. You can restore it anytime.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HLSpacing.xl)

            Spacer()
        }
    }

    // MARK: - Actions

    private func restoreHabit(_ habit: Habit) {
        habit.isArchived = false
        habit.updatedAt = Date()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitArchiveView()
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
