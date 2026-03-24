import SwiftUI
import SwiftData

// MARK: - Notification Detail View

struct NotificationDetailView: View {
    @ScaledMetric(relativeTo: .caption) private var smallIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var actionIconSize: CGFloat = 14
    @ScaledMetric(relativeTo: .footnote) private var statusIconSize: CGFloat = 16
    @ScaledMetric(relativeTo: .title) private var headerIconSize: CGFloat = 30
    let notification: AppNotification
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hlBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HLSpacing.lg) {
                        // Icon Header
                        iconHeader

                        // Content Card
                        contentCard

                        // Related Info
                        relatedInfoCard

                        // Actions
                        actionButtons
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.vertical, HLSpacing.lg)
                }
            }
            .navigationTitle("Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: HLIcon.close)
                            .font(.system(size: min(actionIconSize, 18), weight: .semibold))
                            .foregroundColor(.hlTextSecondary)
                            .frame(width: 30, height: 30)
                            .background(Color.hlDivider)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    // MARK: - Icon Header

    private var iconHeader: some View {
        VStack(spacing: HLSpacing.sm) {
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: notification.icon)
                    .font(.system(size: min(headerIconSize, 34), weight: .semibold))
                    .foregroundColor(notification.type.color)
            }

            Text(notification.type.rawValue)
                .font(HLFont.caption(.medium))
                .foregroundColor(notification.type.color)
                .padding(.horizontal, HLSpacing.sm)
                .padding(.vertical, HLSpacing.xxs)
                .background(notification.type.color.opacity(0.12))
                .cornerRadius(HLRadius.full)
        }
    }

    // MARK: - Content Card

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text(notification.title)
                .font(HLFont.title3())
                .foregroundColor(.hlTextPrimary)

            Text(notification.body)
                .font(HLFont.body())
                .foregroundColor(.hlTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Image(systemName: HLIcon.clock)
                    .font(.system(size: min(smallIconSize, 16)))
                    .accessibilityHidden(true)
                Text(notification.createdAt, style: .relative)
                    .font(HLFont.caption())
                Text("ago")
                    .font(HLFont.caption())
            }
            .foregroundColor(.hlTextTertiary)
            .padding(.top, HLSpacing.xxs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hlCard()
    }

    // MARK: - Related Info

    private var relatedInfoCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Related")
                .font(HLFont.headline())
                .foregroundColor(.hlTextPrimary)

            HStack(spacing: HLSpacing.sm) {
                relatedInfoItem(
                    icon: notification.relatedIcon,
                    title: notification.relatedTitle,
                    subtitle: notification.relatedSubtitle
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hlCard()
    }

    private func relatedInfoItem(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: min(statusIconSize, 20), weight: .medium))
                .foregroundColor(notification.type.color)
                .frame(width: 36, height: 36)
                .background(notification.type.color.opacity(0.12))
                .cornerRadius(HLRadius.sm)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(title)
                    .font(HLFont.subheadline(.medium))
                    .foregroundColor(.hlTextPrimary)
                Text(subtitle)
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: min(smallIconSize, 16), weight: .semibold))
                .foregroundColor(.hlTextTertiary)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: HLSpacing.sm) {
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: notification.actionIcon)
                    Text(notification.actionLabel)
                }
                .font(HLFont.headline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HLSpacing.sm)
                .background(Color.hlPrimary)
                .cornerRadius(HLRadius.md)
            }

            Button {
                dismiss()
            } label: {
                Text("Dismiss")
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.sm)
                    .background(Color.hlDivider)
                    .cornerRadius(HLRadius.md)
            }
        }
    }
}

// MARK: - Notification Computed Properties

extension AppNotification {
    var relatedIcon: String {
        switch type {
        case .habitReminder: return "checkmark.circle"
        case .streakAlert: return "flame.fill"
        case .achievement: return "trophy.fill"
        case .social: return "person.2.fill"
        case .general: return "bell.fill"
        }
    }

    var relatedTitle: String {
        switch type {
        case .habitReminder: return "Morning Meditation"
        case .streakAlert: return "Exercise Streak"
        case .achievement: return "Achievement Gallery"
        case .social: return "Friend Activity"
        case .general: return "HabitLand"
        }
    }

    var relatedSubtitle: String {
        switch type {
        case .habitReminder: return "Tap to go to this habit"
        case .streakAlert: return "7-day streak active"
        case .achievement: return "View all achievements"
        case .social: return "See what friends are doing"
        case .general: return "App information"
        }
    }

    var actionLabel: String {
        switch type {
        case .habitReminder: return "Go to Habit"
        case .streakAlert: return "View Streak"
        case .achievement: return "View Achievement"
        case .social: return "View Activity"
        case .general: return "Open"
        }
    }

    var actionIcon: String {
        switch type {
        case .habitReminder: return "checkmark.circle"
        case .streakAlert: return "flame.fill"
        case .achievement: return "trophy.fill"
        case .social: return "person.2.fill"
        case .general: return "arrow.right"
        }
    }
}

// MARK: - Preview

#Preview {
    NotificationDetailView(notification: AppNotification(title: "Test", body: "Test body", icon: "bell.fill", type: .general))
        .modelContainer(for: AppNotification.self, inMemory: true)
}
