import AVFoundation
import SwiftUI

@MainActor
final class AmbientSoundManager: ObservableObject {
    static let shared = AmbientSoundManager()

    @Published var currentSound: AmbientSound?
    @Published var isPlaying = false
    @Published var volume: Float = 0.5

    private var player: AVAudioPlayer?

    private init() {}

    func play(_ sound: AmbientSound) {
        stop()
        currentSound = sound

        // Use system sounds via tone generation
        guard let url = sound.systemURL else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop forever
            player?.volume = volume
            player?.play()
            isPlaying = true
        } catch {
            // Silent failure — ambient sounds are optional
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentSound = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func setVolume(_ vol: Float) {
        volume = vol
        player?.volume = vol
    }

    func toggle(_ sound: AmbientSound) {
        if currentSound == sound && isPlaying {
            stop()
        } else {
            play(sound)
        }
    }
}

// MARK: - Ambient Sound Type

enum AmbientSound: String, CaseIterable, Identifiable {
    case rain = "Rain"
    case forest = "Forest"
    case ocean = "Ocean"
    case fire = "Fireplace"
    case wind = "Wind"
    case whiteNoise = "White Noise"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .rain: return "cloud.rain.fill"
        case .forest: return "leaf.fill"
        case .ocean: return "water.waves"
        case .fire: return "flame.fill"
        case .wind: return "wind"
        case .whiteNoise: return "waveform"
        }
    }

    var color: Color {
        switch self {
        case .rain: return .hlInfo
        case .forest: return .hlSuccess
        case .ocean: return .hlFitness
        case .fire: return .hlFlame
        case .wind: return .hlTextTertiary
        case .whiteNoise: return .hlSleep
        }
    }

    var systemURL: URL? {
        // Use built-in system audio files as ambient sound sources
        // These are short tones that will loop — a real app would bundle audio assets
        switch self {
        case .rain:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/RingerChanged.caf")
        case .forest:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/acknowledgment_received.caf")
        case .ocean:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/Swish.caf")
        case .fire:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/key_press_click.caf")
        case .wind:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/shake.caf")
        case .whiteNoise:
            return URL(fileURLWithPath: "/System/Library/Audio/UISounds/Tock.caf")
        }
    }
}
