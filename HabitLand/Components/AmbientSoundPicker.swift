import SwiftUI

struct AmbientSoundPicker: View {
    @ObservedObject private var soundManager = AmbientSoundManager.shared

    var body: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.hlTextSecondary)
                Text("Ambient Sound")
                    .font(HLFont.caption(.semibold))
                    .foregroundStyle(Color.hlTextSecondary)
                Spacer()
                if soundManager.isPlaying {
                    Button {
                        soundManager.stop()
                    } label: {
                        Text("Stop")
                            .font(HLFont.caption(.medium))
                            .foregroundStyle(Color.hlFlame)
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.xs) {
                    ForEach(AmbientSound.allCases) { sound in
                        Button {
                            soundManager.toggle(sound)
                        } label: {
                            VStack(spacing: HLSpacing.xxs) {
                                Image(systemName: sound.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(soundManager.currentSound == sound ? .white : sound.color)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        soundManager.currentSound == sound
                                            ? sound.color
                                            : sound.color.opacity(0.12)
                                    )
                                    .clipShape(Circle())

                                Text(sound.rawValue)
                                    .font(HLFont.caption2(.medium))
                                    .foregroundStyle(
                                        soundManager.currentSound == sound
                                            ? sound.color
                                            : Color.hlTextTertiary
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if soundManager.isPlaying {
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.hlTextTertiary)
                    Slider(value: Binding(
                        get: { Double(soundManager.volume) },
                        set: { soundManager.setVolume(Float($0)) }
                    ), in: 0...1)
                    .tint(soundManager.currentSound?.color ?? .hlPrimary)
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.hlTextTertiary)
                }
            }
        }
        .padding(HLSpacing.md)
        .background(Color.hlSurface)
        .cornerRadius(HLRadius.lg)
    }
}

#Preview {
    AmbientSoundPicker()
        .padding()
}
