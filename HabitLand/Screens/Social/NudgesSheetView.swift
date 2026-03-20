import SwiftUI

struct NudgesSheetView: View {
    @Binding var nudges: [NudgeMessage]
    @StateObject private var cloudKit = CloudKitManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hlBackground.ignoresSafeArea()

                if nudges.isEmpty {
                    VStack(spacing: HLSpacing.md) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.hlTextTertiary)
                        Text("No Nudges")
                            .font(HLFont.title3())
                            .foregroundStyle(Color.hlTextPrimary)
                        Text("When friends nudge you, they'll appear here")
                            .font(HLFont.body())
                            .foregroundStyle(Color.hlTextSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: HLSpacing.sm) {
                            ForEach(nudges) { nudge in
                                nudgeCard(nudge)
                            }
                        }
                        .padding(.horizontal, HLSpacing.md)
                        .padding(.top, HLSpacing.sm)
                        .padding(.bottom, HLSpacing.xxxl)
                    }
                }
            }
            .navigationTitle("Nudges")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(HLFont.headline())
                        .foregroundStyle(Color.hlPrimary)
                }
            }
        }
    }

    private func nudgeCard(_ nudge: NudgeMessage) -> some View {
        HStack(spacing: HLSpacing.sm) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 20))
                .foregroundColor(.hlPrimary)
                .frame(width: 40, height: 40)
                .background(Color.hlPrimaryLight)
                .cornerRadius(HLRadius.full)

            VStack(alignment: .leading, spacing: HLSpacing.xxxs) {
                Text(nudge.fromName)
                    .font(HLFont.headline())
                    .foregroundColor(.hlTextPrimary)

                Text(nudge.message)
                    .font(HLFont.body())
                    .foregroundColor(.hlTextSecondary)

                Text(nudge.sentAt, style: .relative)
                    .font(HLFont.caption())
                    .foregroundColor(.hlTextTertiary)
            }

            Spacer()

            Button {
                Task {
                    await cloudKit.markNudgeRead(nudge)
                    nudges.removeAll { $0.id == nudge.id }
                }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.hlSuccess)
            }
        }
        .hlCard()
    }
}

#Preview {
    NudgesSheetView(nudges: .constant([]))
}
