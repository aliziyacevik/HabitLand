import SwiftUI
import SwiftData

// MARK: - Long Term Progress View

struct LongTermProgressView: View {
    @Query(filter: #Predicate<Habit> { !$0.isArchived }) private var activeHabits: [Habit]
    @Query private var allHabits: [Habit]
    @Query private var profiles: [UserProfile]
    @State private var animateBars = false
    @State private var animateTimeline = false

    private var calendar: Calendar { Calendar.current }
    private var today: Date { calendar.startOfDay(for: Date()) }
    private var profile: UserProfile? { profiles.first }

    private var earliestDate: Date {
        allHabits.compactMap { $0.safeCompletions.min(by: { $0.date < $1.date })?.date }.min() ?? Date()
    }

    private var totalDaysTracked: Int {
        let uniqueDays = Set(allHabits.flatMap { $0.safeCompletions.filter(\.isCompleted) }.map { calendar.startOfDay(for: $0.date) })
        return uniqueDays.count
    }

    private var allTimeCompletions: Int {
        allHabits.reduce(0) { $0 + $1.totalCompletions }
    }

    private var allTimeRate: Double {
        guard !allHabits.isEmpty else { return 0 }
        let rates = allHabits.compactMap { habit -> Double? in
            let completed = habit.safeCompletions.filter(\.isCompleted).count
            guard completed > 0 else { return nil }
            let daysSinceCreated = max(1, calendar.dateComponents([.day], from: habit.createdAt, to: today).day ?? 1)
            return Double(completed) / Double(daysSinceCreated)
        }
        guard !rates.isEmpty else { return 0 }
        return rates.reduce(0, +) / Double(rates.count)
    }

    private var bestStreakAllTime: Int {
        allHabits.map(\.bestStreak).max() ?? 0
    }

    private var sinceDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        return fmt.string(from: earliestDate)
    }

    // Monthly bars for last 12 months
    private var monthlyBars: [(label: String, rate: Double)] {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM"
        return (0..<12).reversed().map { monthsAgo in
            let monthDate = calendar.date(byAdding: .month, value: -monthsAgo, to: today)!
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count
            var totalRate = 0.0
            var count = 0
            for dayOffset in 0..<daysInMonth {
                let day = calendar.date(byAdding: .day, value: dayOffset, to: monthStart)!
                let dayStart = calendar.startOfDay(for: day)
                guard dayStart <= today else { continue }
                let active = allHabits.filter { habit in
                    let wd = calendar.component(.weekday, from: day) - 1
                    return habit.targetDays.contains(wd) && !habit.isArchived && habit.createdAt <= day
                }
                guard !active.isEmpty else { continue }
                let completed = active.filter { habit in
                    habit.safeCompletions.contains { calendar.startOfDay(for: $0.date) == dayStart && $0.isCompleted }
                }.count
                totalRate += Double(completed) / Double(active.count)
                count += 1
            }
            return (fmt.string(from: monthDate), count > 0 ? totalRate / Double(count) : 0)
        }
    }

    // Milestones from real data
    private var milestones: [(icon: String, title: String, subtitle: String, date: String, color: Color)] {
        var result: [(String, String, String, String, Color)] = []
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"

        // First completion
        if let firstCompletion = allHabits.flatMap({ $0.safeCompletions.filter(\.isCompleted) }).min(by: { $0.date < $1.date }) {
            result.append(("footprints", "First Habit Completed", "Your journey began", fmt.string(from: firstCompletion.date), .hlPrimary))
        }

        // Best streak milestones
        let best = bestStreakAllTime
        if best >= 7 {
            result.append(("flame.fill", "7-Day Streak", "Consistency unlocked", "Achieved", .hlFlame))
        }
        if best >= 30 {
            result.append(("bolt.fill", "30-Day Streak", "Unstoppable!", "Achieved", .hlInfo))
        }

        // Completion milestones
        let total = allTimeCompletions
        if total >= 100 {
            result.append(("star.fill", "100 Completions", "Century milestone", "Achieved", .hlGold))
        }
        if total >= 500 {
            result.append(("crown.fill", "500 Completions", "Half a thousand", "Achieved", .hlGold))
        }
        if total >= 1000 {
            result.append(("trophy.fill", "1,000 Completions", "Grand milestone", "Achieved", .hlFlame))
        }

        // Level milestone
        if let p = profile, p.level >= 10 {
            result.append(("sparkles", "Level \(p.level) Reached", p.levelTitle, "Current", .hlMindfulness))
        }

        return result
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: HLSpacing.lg) {
                if allHabits.isEmpty {
                    emptyState
                } else {
                    headerSection
                    allTimeStatsGrid
                    if monthlyBars.contains(where: { $0.rate > 0 }) {
                        monthlyTrendCard
                    }
                    if !milestones.isEmpty {
                        milestonesCard
                    }
                    gamificationCard
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.bottom, HLSpacing.xxxl)
        }
        .background(Color.hlBackground.ignoresSafeArea())
        .navigationTitle("Long-Term Progress")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(HLAnimation.slow.delay(0.1)) {
                animateBars = true
            }
            withAnimation(HLAnimation.slow.delay(0.3)) {
                animateTimeline = true
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Spacer().frame(height: 80)
            ZStack {
                Circle()
                    .fill(Color.hlGold.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: HLIcon.trophy)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.hlGold.opacity(0.5))
            }
            Text("No data yet")
                .font(HLFont.title3(.semibold))
                .foregroundStyle(Color.hlTextPrimary)
            Text("Complete habits over time to\nsee your long-term progress.")
                .font(HLFont.subheadline())
                .foregroundStyle(Color.hlTextSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: HLSpacing.xxs) {
                Text("All-Time Progress")
                    .font(HLFont.title2())
                    .foregroundColor(.hlTextPrimary)
                Text("Since \(sinceDate)")
                    .font(HLFont.subheadline())
                    .foregroundColor(.hlTextSecondary)
            }
            Spacer()
            Image(systemName: HLIcon.trophy)
                .font(.title2)
                .foregroundColor(.hlGold)
        }
        .padding(.top, HLSpacing.xs)
    }

    // MARK: - All-Time Stats

    private var allTimeStatsGrid: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack(spacing: HLSpacing.sm) {
                statCard(title: "Days Tracked", value: "\(totalDaysTracked)", icon: HLIcon.calendar, color: .hlPrimary)
                statCard(title: "Completions", value: "\(allTimeCompletions)", icon: HLIcon.checkmark, color: .hlInfo)
            }
            HStack(spacing: HLSpacing.sm) {
                statCard(title: "Avg Rate", value: "\(Int(allTimeRate * 100))%", icon: HLIcon.chart, color: .hlWarning)
                statCard(title: "Best Streak", value: "\(bestStreakAllTime)d", icon: HLIcon.flame, color: .hlFlame)
            }
            HStack(spacing: HLSpacing.sm) {
                statCard(title: "Habits Created", value: "\(allHabits.count)", icon: HLIcon.add, color: .hlMindfulness)
                statCard(title: "Active Habits", value: "\(activeHabits.count)", icon: HLIcon.target, color: .hlPrimary)
            }
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(value)
                    .font(HLFont.title3())
                    .foregroundColor(.hlTextPrimary)
                Text(title)
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            Spacer()
        }
        .hlCard(padding: HLSpacing.sm)
    }

    // MARK: - Monthly Trend (12 months)

    private var monthlyTrendCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Monthly Trend")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            GeometryReader { geo in
                let w = geo.size.width
                let h: CGFloat = 20
                let barCount = CGFloat(monthlyBars.count)
                let spacing = w / barCount

                Path { path in
                    for (i, bar) in monthlyBars.enumerated() {
                        let x = spacing * CGFloat(i) + spacing / 2
                        let y = h - (bar.rate * h)
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.hlPrimary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .opacity(animateBars ? 1 : 0)
            }
            .frame(height: 20)

            HStack(alignment: .bottom, spacing: HLSpacing.xxxs) {
                ForEach(Array(monthlyBars.enumerated()), id: \.offset) { _, bar in
                    VStack(spacing: HLSpacing.xxxs) {
                        Text("\(Int(bar.rate * 100))")
                            .font(HLFont.caption2())
                            .foregroundColor(.hlTextTertiary)
                            .opacity(animateBars ? 1 : 0)

                        RoundedRectangle(cornerRadius: HLRadius.xs)
                            .fill(
                                LinearGradient(
                                    colors: [.hlPrimary, .hlPrimaryDark],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: animateBars ? max(12, bar.rate * 100) : 0)

                        Text(bar.label)
                            .font(HLFont.caption2())
                            .foregroundColor(.hlTextSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
        }
        .hlCard()
    }

    // MARK: - Milestones Timeline

    private var milestonesCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Label("Milestones", systemImage: HLIcon.medal)
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            ForEach(Array(milestones.enumerated()), id: \.offset) { index, milestone in
                HStack(alignment: .top, spacing: HLSpacing.sm) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(milestone.color)
                            .frame(width: 12, height: 12)
                        if index < milestones.count - 1 {
                            Rectangle()
                                .fill(Color.hlDivider)
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 12)

                    Image(systemName: milestone.icon)
                        .font(.title3)
                        .foregroundColor(milestone.color)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                        Text(milestone.title)
                            .font(HLFont.subheadline(.semibold))
                            .foregroundColor(.hlTextPrimary)
                        Text(milestone.subtitle)
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextSecondary)
                    }

                    Spacer()

                    Text(milestone.date)
                        .font(HLFont.caption2())
                        .foregroundColor(.hlTextTertiary)
                }
                .frame(minHeight: 44)
                .opacity(animateTimeline ? 1 : 0)
                .offset(x: animateTimeline ? 0 : -20)
            }
        }
        .hlCard()
    }

    // MARK: - Gamification Card

    private var gamificationCard: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: HLIcon.crown)
                .font(.system(size: 36))
                .foregroundColor(.hlGold)

            if let p = profile {
                Text("Level \(p.level)")
                    .font(HLFont.largeTitle())
                    .foregroundColor(.hlTextPrimary)

                Text(p.levelTitle)
                    .font(HLFont.subheadline())
                    .foregroundColor(.hlPrimary)

                // XP progress bar
                VStack(spacing: HLSpacing.xs) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.hlDivider)
                                .frame(height: 10)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.hlGold, .hlFlame],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: animateBars ? geo.size.width * p.levelProgress : 0, height: 10)
                        }
                    }
                    .frame(height: 10)

                    HStack {
                        Text("\(p.xp) XP")
                            .font(HLFont.caption(.semibold))
                            .foregroundColor(.hlTextPrimary)
                        Spacer()
                        Text("\(p.xpForNextLevel - p.xp) to next level")
                            .font(HLFont.caption())
                            .foregroundColor(.hlTextSecondary)
                    }
                }
            } else {
                Text("No Profile")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .hlCard(padding: HLSpacing.lg)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LongTermProgressView()
    }
    .modelContainer(for: [Habit.self, UserProfile.self], inMemory: true)
}
