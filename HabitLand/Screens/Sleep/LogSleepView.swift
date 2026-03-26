import SwiftUI
import SwiftData

struct LogSleepView: View {
    @ScaledMetric(relativeTo: .title) private var moonIconSize: CGFloat = 40
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var bedTime: Date = {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 23
        components.minute = 0
        return calendar.date(from: components)?.addingTimeInterval(-86400) ?? Date()
    }()

    @State private var wakeTime: Date = {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 7
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }()

    @State private var selectedQuality: SleepQuality = .good
    @State private var mood: Int = 3
    @State private var notes: String = ""

    private var duration: TimeInterval {
        wakeTime.timeIntervalSince(bedTime)
    }

    private var durationFormatted: String {
        guard duration > 0 else { return "0h 0m" }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private var isValid: Bool {
        duration > 0 && duration < 24 * 3600
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HLSpacing.lg) {
                    durationDisplay
                    timePickersSection
                    qualitySection
                    moodSection
                    notesSection
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.bottom, HLSpacing.xxxl)
                .hlAdaptiveWidth()
            }
            .background(Color.hlBackground)
            .navigationTitle("Log Sleep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.hlTextSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveSleep()
                    }
                    .font(HLFont.headline())
                    .foregroundStyle(isValid ? Color.hlSleep : Color.hlTextTertiary)
                    .disabled(!isValid)
                }
            }
        }
    }

    // MARK: - Duration Display

    @ViewBuilder
    private var durationDisplay: some View {
        VStack(spacing: HLSpacing.xs) {
            Image(systemName: HLIcon.moon)
                .font(.system(size: min(moonIconSize, 48)))
                .foregroundStyle(Color.hlSleep)

            Text(durationFormatted)
                .font(HLFont.largeTitle(.bold))
                .foregroundStyle(duration > 0 ? Color.hlTextPrimary : Color.hlTextTertiary)

            Text("Duration")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HLSpacing.lg)
        .hlCard()
    }

    // MARK: - Time Pickers

    @ViewBuilder
    private var timePickersSection: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack {
                Label("Bedtime", systemImage: HLIcon.bed)
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlSleep)
                Spacer()
                DatePicker("", selection: $bedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .tint(Color.hlSleep)
            }

            Divider()
                .background(Color.hlDivider)

            HStack {
                Label("Wake Time", systemImage: HLIcon.sunrise)
                    .font(HLFont.headline())
                    .foregroundStyle(Color.hlFlame)
                Spacer()
                DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .tint(Color.hlSleep)
            }
        }
        .hlCard()
    }

    // MARK: - Quality

    private var qualitySection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Sleep Quality")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            VStack(spacing: HLSpacing.xs) {
                ForEach(SleepQuality.allCases, id: \.self) { quality in
                    Button {
                        withAnimation(HLAnimation.quick) {
                            selectedQuality = quality
                        }
                        HLHaptics.selection()
                    } label: {
                        HStack(spacing: HLSpacing.sm) {
                            Text(quality.icon)
                                .font(HLFont.title2())

                            Text(quality.rawValue)
                                .font(HLFont.body(.medium))
                                .foregroundStyle(
                                    selectedQuality == quality ? Color.hlSleep : Color.hlTextPrimary
                                )

                            Spacer()

                            if selectedQuality == quality {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.hlSleep)
                            }
                        }
                        .padding(.horizontal, HLSpacing.md)
                        .padding(.vertical, HLSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: HLRadius.lg)
                                .fill(selectedQuality == quality ? Color.hlSleep.opacity(0.1) : Color.hlSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: HLRadius.lg)
                                .stroke(
                                    selectedQuality == quality ? Color.hlSleep : Color.hlDivider,
                                    lineWidth: selectedQuality == quality ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Mood

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Morning Mood")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            VStack(spacing: HLSpacing.xs) {
                ForEach(1...5, id: \.self) { value in
                    let emoji = moodEmojiFor(value)
                    let label = moodLabelFor(value)
                    Button {
                        withAnimation(HLAnimation.quick) {
                            mood = value
                        }
                        HLHaptics.selection()
                    } label: {
                        HStack(spacing: HLSpacing.sm) {
                            Text(emoji)
                                .font(HLFont.title2())

                            Text(label)
                                .font(HLFont.body(.medium))
                                .foregroundStyle(
                                    mood == value ? Color.hlSleep : Color.hlTextPrimary
                                )

                            Spacer()

                            if mood == value {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.hlSleep)
                            }
                        }
                        .padding(.horizontal, HLSpacing.md)
                        .padding(.vertical, HLSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: HLRadius.lg)
                                .fill(mood == value ? Color.hlSleep.opacity(0.1) : Color.hlSurface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: HLRadius.lg)
                                .stroke(
                                    mood == value ? Color.hlSleep : Color.hlDivider,
                                    lineWidth: mood == value ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .hlCard()
    }

    // MARK: - Notes

    @ViewBuilder
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.xs) {
            Text("Notes")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextPrimary)

            TextField("How did you sleep? Any dreams?", text: $notes, axis: .vertical)
                .font(HLFont.body())
                .foregroundStyle(Color.hlTextPrimary)
                .lineLimit(3...6)
                .padding(HLSpacing.sm)
                .background(Color.hlBackground, in: RoundedRectangle(cornerRadius: HLRadius.md))
        }
        .hlCard()
    }

    // MARK: - Helpers

    private func moodEmojiFor(_ value: Int) -> String {
        switch value {
        case 1: return "😩"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }

    private func moodLabelFor(_ value: Int) -> String {
        switch value {
        case 1: return "Exhausted"
        case 2: return "Tired"
        case 3: return "Neutral"
        case 4: return "Refreshed"
        case 5: return "Energized"
        default: return ""
        }
    }

    // MARK: - Save

    private func saveSleep() {
        let log = SleepLog(
            bedTime: bedTime,
            wakeTime: wakeTime,
            quality: selectedQuality,
            notes: notes,
            mood: mood
        )
        modelContext.insert(log)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    LogSleepView()
        .modelContainer(for: SleepLog.self, inMemory: true)
}
