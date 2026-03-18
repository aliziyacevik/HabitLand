import SwiftUI
import SwiftData

// MARK: - Notification Center View

struct NotificationCenterView: View {
    @Query(sort: \AppNotification.createdAt, order: .reverse) private var notifications: [AppNotification]
    @Environment(\.modelContext) private var modelContext
    @State private var showingDetail: AppNotification?

    private var todayNotifications: [AppNotification] {
        notifications.filter { Calendar.current.isDateInToday($0.createdAt) }
    }

    private var earlierNotifications: [AppNotification] {
        notifications.filter { !Calendar.current.isDateInToday($0.createdAt) }
    }

    private var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hlBackground.ignoresSafeArea()

                if notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if unreadCount > 0 {
                        Button("Mark All Read") {
                            withAnimation(HLAnimation.standard) {
                                for notification in notifications {
                                    notification.isRead = true
                                }
                            }
                        }
                        .font(HLFont.subheadline(.medium))
                        .foregroundColor(.hlPrimary)
                    }
                }
            }
            .sheet(item: $showingDetail) { notification in
                NotificationDetailView(notification: notification)
            }
        }
    }

    // MARK: - Notification List

    private var notificationList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HLSpacing.lg) {
                if !todayNotifications.isEmpty {
                    notificationSection(title: "Today", items: todayNotifications)
                }

                if !earlierNotifications.isEmpty {
                    notificationSection(title: "Earlier", items: earlierNotifications)
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.sm)
        }
    }

    private func notificationSection(title: String, items: [AppNotification]) -> some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text(title)
                .font(HLFont.headline())
                .foregroundColor(.hlTextSecondary)
                .padding(.leading, HLSpacing.xxs)

            VStack(spacing: HLSpacing.xs) {
                ForEach(items) { notification in
                    NotificationRow(notification: notification)
                        .onTapGesture {
                            markAsRead(notification)
                            showingDetail = notification
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                dismiss(notification)
                            } label: {
                                Label("Dismiss", systemImage: HLIcon.delete)
                            }
                        }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.hlTextTertiary)

            Text("All Caught Up!")
                .font(HLFont.title2())
                .foregroundColor(.hlTextPrimary)

            Text("You have no notifications right now.")
                .font(HLFont.body())
                .foregroundColor(.hlTextSecondary)
        }
    }

    // MARK: - Actions

    private func markAsRead(_ notification: AppNotification) {
        withAnimation(HLAnimation.quick) {
            notification.isRead = true
        }
    }

    private func dismiss(_ notification: AppNotification) {
        withAnimation(HLAnimation.standard) {
            modelContext.delete(notification)
        }
    }
}

// MARK: - Notification Row

struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: HLSpacing.sm) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: notification.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(notification.type.color)
            }

            // Content
            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                HStack {
                    Text(notification.title)
                        .font(HLFont.subheadline(notification.isRead ? .regular : .semibold))
                        .foregroundColor(.hlTextPrimary)

                    Spacer()

                    if !notification.isRead {
                        Circle()
                            .fill(Color.hlPrimary)
                            .frame(width: 8, height: 8)
                    }
                }

                Text(notification.body)
                    .font(HLFont.footnote())
                    .foregroundColor(.hlTextSecondary)
                    .lineLimit(2)

                Text(notification.timeAgo)
                    .font(HLFont.caption2())
                    .foregroundColor(.hlTextTertiary)
            }
        }
        .hlCard()
    }
}

// MARK: - AppNotification Time Ago

extension AppNotification {
    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
}

// MARK: - NotificationType Color Extension

extension NotificationType {
    var color: Color {
        switch self {
        case .habitReminder: return .hlPrimary
        case .streakAlert: return .hlFlame
        case .achievement: return .hlGold
        case .social: return .hlSocial
        case .general: return .hlTextSecondary
        }
    }
}

// MARK: - Preview

#Preview {
    NotificationCenterView()
        .modelContainer(for: AppNotification.self, inMemory: true)
}
