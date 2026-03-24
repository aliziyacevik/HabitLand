import Testing
import Foundation
@testable import HabitLand

// MARK: - AmbientSound Enum Tests

struct AmbientSoundTests {

    @Test func allCasesExist() {
        #expect(AmbientSound.allCases.count == 6)
    }

    @Test func allSoundsHaveIcon() {
        for sound in AmbientSound.allCases {
            #expect(!sound.icon.isEmpty)
        }
    }

    @Test func allSoundsHaveId() {
        for sound in AmbientSound.allCases {
            #expect(sound.id == sound.rawValue)
        }
    }

    @Test func allSoundsHaveRawValue() {
        #expect(AmbientSound.rain.rawValue == "Rain")
        #expect(AmbientSound.forest.rawValue == "Forest")
        #expect(AmbientSound.ocean.rawValue == "Ocean")
        #expect(AmbientSound.fire.rawValue == "Fireplace")
        #expect(AmbientSound.wind.rawValue == "Wind")
        #expect(AmbientSound.whiteNoise.rawValue == "White Noise")
    }

    // MARK: - Noise Parameters

    @Test func allSoundsHaveValidNoiseParams() {
        for sound in AmbientSound.allCases {
            let params = sound.noiseParams
            #expect(params.amplitude > 0)
            #expect(params.amplitude <= 1.0)
            #expect(params.smoothing >= 0)
            #expect(params.smoothing <= 1.0)
        }
    }

    @Test func whiteNoiseHasZeroSmoothing() {
        #expect(AmbientSound.whiteNoise.noiseParams.smoothing == 0)
    }

    @Test func oceanHasHighSmoothing() {
        #expect(AmbientSound.ocean.noiseParams.smoothing >= 0.5)
    }

    @Test func windHasHighestSmoothing() {
        let windSmoothing = AmbientSound.wind.noiseParams.smoothing
        for sound in AmbientSound.allCases where sound != .wind {
            #expect(windSmoothing >= sound.noiseParams.smoothing)
        }
    }

    // MARK: - NoiseParams Struct

    @Test func noiseParamsInitialization() {
        let params = NoiseParams(amplitude: 0.5, smoothing: 0.3)
        #expect(params.amplitude == 0.5)
        #expect(params.smoothing == 0.3)
    }

    // MARK: - Specific Icons

    @Test func rainIcon() {
        #expect(AmbientSound.rain.icon == "cloud.rain.fill")
    }

    @Test func forestIcon() {
        #expect(AmbientSound.forest.icon == "leaf.fill")
    }

    @Test func fireIcon() {
        #expect(AmbientSound.fire.icon == "flame.fill")
    }
}
