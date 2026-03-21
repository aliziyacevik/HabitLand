import AVFoundation
import SwiftUI

@MainActor
final class AmbientSoundManager: ObservableObject {
    static let shared = AmbientSoundManager()

    @Published var currentSound: AmbientSound?
    @Published var isPlaying = false
    @Published var volume: Float = 0.5

    private var audioEngine: AVAudioEngine?
    private var noiseNode: AVAudioSourceNode?

    private init() {}

    func play(_ sound: AmbientSound) {
        stop()
        currentSound = sound

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }

        let engine = AVAudioEngine()
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let params = sound.noiseParams

        let sourceNode = AVAudioSourceNode(format: format) { _, _, frameCount, bufferList -> OSStatus in
            let buffer = UnsafeMutableAudioBufferListPointer(bufferList)
            for frame in 0..<Int(frameCount) {
                // Generate noise sample
                var sample = Float.random(in: -1.0...1.0)

                // Shape the noise based on type
                sample *= params.amplitude

                // Apply low-pass filter approximation for colored noise
                if params.smoothing > 0 {
                    let prev = frame > 0 ? buffer[0].mData!.assumingMemoryBound(to: Float.self)[frame - 1] : 0
                    sample = prev * params.smoothing + sample * (1.0 - params.smoothing)
                }

                buffer[0].mData!.assumingMemoryBound(to: Float.self)[frame] = sample
            }
            return noErr
        }

        engine.attach(sourceNode)
        let mixer = engine.mainMixerNode
        engine.connect(sourceNode, to: mixer, format: format)
        mixer.outputVolume = volume

        do {
            try engine.start()
            audioEngine = engine
            noiseNode = sourceNode
            isPlaying = true
        } catch {
            // Silent failure
        }
    }

    func stop() {
        audioEngine?.stop()
        if let node = noiseNode {
            audioEngine?.detach(node)
        }
        audioEngine = nil
        noiseNode = nil
        isPlaying = false
        currentSound = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func setVolume(_ vol: Float) {
        volume = vol
        audioEngine?.mainMixerNode.outputVolume = vol
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

struct NoiseParams: Sendable {
    let amplitude: Float
    let smoothing: Float // 0 = white noise, 0.5+ = brownish
}

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

    var noiseParams: NoiseParams {
        switch self {
        case .rain: return NoiseParams(amplitude: 0.15, smoothing: 0.3)
        case .forest: return NoiseParams(amplitude: 0.08, smoothing: 0.6)
        case .ocean: return NoiseParams(amplitude: 0.20, smoothing: 0.7)
        case .fire: return NoiseParams(amplitude: 0.12, smoothing: 0.4)
        case .wind: return NoiseParams(amplitude: 0.10, smoothing: 0.8)
        case .whiteNoise: return NoiseParams(amplitude: 0.18, smoothing: 0.0)
        }
    }
}
