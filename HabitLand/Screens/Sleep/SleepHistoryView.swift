import SwiftUI
import SwiftData

struct SleepHistoryView: View {
    @ScaledMetric(relativeTo: .largeTitle) private var emptyIconSize: CGFloat = 48
    @Query(sort: \SleepLog.wakeTime, order: .reverse) private var sleepLogs: [SleepLog]

    private var groupedByMonth: [(key: String, logs: [SleepLog])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: sleepLogs) { log in
            formatter.string(from: log.wakeTime)
        }

        return grouped
            .map { (key: $0.key, logs: $0.value.sorted { $0.wakeTime > $1.wakeTime }) }
            .sorted { a, b in
                guard let dateA = a.logs.first?.wakeTime, let dateB = b.logs.first?.wakeTime else { return false }
                return dateA > dateB
            }
    }

    var body: some View {
        Group {
            if sleepLogs.isEmpty {
                emptyState
            } else {
                logsList
            }
        }
        .background(Color.hlBackground)
        .navigationTitle("Sleep History")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: HLIcon.moon)
                .font(.system(size: min(emptyIconSize, 56)))
                .foregroundStyle(Color.hlTextTertiary)
            Text("No sleep logs yet")
                .font(HLFont.headline())
                .foregroundStyle(Color.hlTextSecondary)
            Text("Start tracking your sleep to see history here.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(HLSpacing.xl)
    }

    @ViewBuilder
    private var logsList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedByMonth, id: \.key) { group in
                    Section {
                        VStack(spacing: HLSpacing.xs) {
                            ForEach(group.logs, id: \.id) { log in
                                sleepRow(log)
                            }
                        }
                        .padding(.horizontal, HLSpacing.md)
                        .padding(.bottom, HLSpacing.md)
                    } header: {
                        Text(group.key)
                            .font(HLFont.headline())
                            .foregroundStyle(Color.hlTextPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, HLSpacing.md)
                            .padding(.vertical, HLSpacing.xs)
                            .background(Color.hlBackground)
                    }
                }
            }
            .padding(.bottom, HLSpacing.xl)
        }
    }

    @ViewBuilder
    private func sleepRow(_ log: SleepLog) -> some View {
        HStack(spacing: HLSpacing.sm) {
            // Quality emoji
            Text(log.quality.icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Color.hlSleep.opacity(0.1), in: RoundedRectangle(cornerRadius: HLRadius.md))

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(log.wakeTime, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                    .font(HLFont.subheadline(.semibold))
                    .foregroundStyle(Color.hlTextPrimary)

                HStack(spacing: HLSpacing.sm) {
                    Label {
                        Text(log.bedTime, style: .time)
                            .font(HLFont.caption())
                    } icon: {
                        Image(systemName: HLIcon.bed)
                            .font(HLFont.caption2())
                    }
                    .foregroundStyle(Color.hlTextSecondary)

                    Image(systemName: "arrow.right")
                        .font(HLFont.caption2())
                        .foregroundStyle(Color.hlTextTertiary)

                    Label {
                        Text(log.wakeTime, style: .time)
                            .font(HLFont.caption())
                    } icon: {
                        Image(systemName: HLIcon.sunrise)
                            .font(HLFont.caption2())
                    }
                    .foregroundStyle(Color.hlTextSecondary)
                }
            }

            Spacer()

            Text(log.durationFormatted)
                .font(HLFont.headline())
                .foregroundStyle(Color.hlSleep)
        }
        .hlCard()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SleepHistoryView()
    }
    .modelContainer(for: SleepLog.self, inMemory: true)
}
