import SwiftUI
import SwiftData

struct PendingRequestsView: View {
    @ScaledMetric(relativeTo: .title) private var emptyIconSize: CGFloat = 40
    @ScaledMetric(relativeTo: .caption) private var closeIconSize: CGFloat = 12
    @ScaledMetric(relativeTo: .footnote) private var actionIconSize: CGFloat = 14
    @StateObject private var cloudKit = CloudKitManager.shared
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Color.hlBackground.ignoresSafeArea()

            if cloudKit.pendingRequests.isEmpty {
                VStack(spacing: HLSpacing.md) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: min(emptyIconSize, 48)))
                        .foregroundStyle(Color.hlSuccess)
                    Text("No Pending Requests")
                        .font(HLFont.title3())
                        .foregroundStyle(Color.hlTextPrimary)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: HLSpacing.sm) {
                        ForEach(cloudKit.pendingRequests) { request in
                            requestCard(request)
                        }
                    }
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.top, HLSpacing.sm)
                    .padding(.bottom, HLSpacing.xxxl)
                }
            }
        }
        .navigationTitle("Friend Requests")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await cloudKit.fetchPendingRequests()
        }
    }

    private func requestCard(_ request: FriendRequest) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Text(request.fromEmoji)
                .font(HLFont.largeTitle())
                .frame(width: 48, height: 48)
                .background(Color.hlPrimaryLight)
                .cornerRadius(HLRadius.full)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(request.fromName)
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)

                HStack(spacing: HLSpacing.xs) {
                    Text(request.fromUsername)
                        .font(HLFont.caption())
                        .foregroundColor(.hlTextSecondary)

                    Text("Lv.\(request.fromLevel)")
                        .font(HLFont.caption2(.bold))
                        .foregroundColor(.hlPrimary)
                        .padding(.horizontal, HLSpacing.xs)
                        .padding(.vertical, HLSpacing.xxxs)
                        .background(Color.hlPrimaryLight)
                        .cornerRadius(HLRadius.full)
                }
            }

            Spacer()

            VStack(spacing: HLSpacing.xxs) {
                Button {
                    Task {
                        _ = await cloudKit.acceptFriendRequest(request, context: modelContext)
                        HLHaptics.success()
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: min(actionIconSize, 18), weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.hlSuccess)
                        .cornerRadius(HLRadius.full)
                }

                Button {
                    Task {
                        await cloudKit.declineFriendRequest(request)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: min(closeIconSize, 16), weight: .bold))
                        .foregroundStyle(Color.hlTextTertiary)
                        .frame(width: 36, height: 36)
                        .background(Color.hlSurface)
                        .cornerRadius(HLRadius.full)
                        .overlay(
                            Circle().stroke(Color.hlCardBorder, lineWidth: 1)
                        )
                }
            }
        }
        .hlCard()
    }
}

#Preview {
    NavigationStack {
        PendingRequestsView()
    }
}
