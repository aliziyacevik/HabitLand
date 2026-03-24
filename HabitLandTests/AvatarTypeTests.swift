import Testing
import Foundation
@testable import HabitLand

// MARK: - AvatarType Tests

struct AvatarTypeTests {

    // MARK: - Raw Storage Roundtrip

    @Test func initialRoundtrip() {
        let type = AvatarType.initial
        #expect(type.rawStorage == "initial")

        let parsed = AvatarType(rawStorage: "initial")
        #expect(parsed == .initial)
    }

    @Test func animalRoundtrip() {
        for animal in AnimalAvatar.allCases {
            let type = AvatarType.animal(animal)
            let raw = type.rawStorage
            #expect(raw == "animal.\(animal.rawValue)")

            let parsed = AvatarType(rawStorage: raw)
            #expect(parsed == type)
        }
    }

    @Test func frameRoundtrip() {
        for frame in AvatarFrame.allCases {
            let type = AvatarType.frame(frame)
            let raw = type.rawStorage
            #expect(raw == "frame.\(frame.rawValue)")

            let parsed = AvatarType(rawStorage: raw)
            #expect(parsed == type)
        }
    }

    @Test func invalidRawStorageReturnsNil() {
        #expect(AvatarType(rawStorage: "") == nil)
        #expect(AvatarType(rawStorage: "invalid") == nil)
        #expect(AvatarType(rawStorage: "animal.nonexistent") == nil)
        #expect(AvatarType(rawStorage: "frame.nonexistent") == nil)
        #expect(AvatarType(rawStorage: "unknown.fox") == nil)
    }

    // MARK: - Display Name

    @Test func initialDisplayName() {
        #expect(AvatarType.initial.displayName == "Default")
    }

    @Test func animalDisplayNames() {
        for animal in AnimalAvatar.allCases {
            let type = AvatarType.animal(animal)
            #expect(type.displayName == animal.rawValue.capitalized)
        }
    }

    @Test func frameDisplayNames() {
        for frame in AvatarFrame.allCases {
            let type = AvatarType.frame(frame)
            #expect(type.displayName == frame.rawValue.capitalized)
        }
    }

    // MARK: - SF Symbol

    @Test func initialHasNoSymbol() {
        #expect(AvatarType.initial.sfSymbol == nil)
    }

    @Test func animalHasSymbol() {
        for animal in AnimalAvatar.allCases {
            let type = AvatarType.animal(animal)
            #expect(type.sfSymbol != nil)
            #expect(!type.sfSymbol!.isEmpty)
        }
    }

    @Test func frameHasSymbol() {
        for frame in AvatarFrame.allCases {
            let type = AvatarType.frame(frame)
            #expect(type.sfSymbol != nil)
            #expect(!type.sfSymbol!.isEmpty)
        }
    }

    // MARK: - Gradient Colors

    @Test func allTypesHaveGradientColors() {
        #expect(AvatarType.initial.gradientColors.count >= 2)

        for animal in AnimalAvatar.allCases {
            #expect(AvatarType.animal(animal).gradientColors.count >= 2)
        }

        for frame in AvatarFrame.allCases {
            #expect(AvatarType.frame(frame).gradientColors.count >= 2)
        }
    }
}

// MARK: - AnimalAvatar Tests

struct AnimalAvatarTests {

    @Test func allCasesExist() {
        #expect(AnimalAvatar.allCases.count == 8)
    }

    @Test func allAnimalsHaveSFSymbol() {
        for animal in AnimalAvatar.allCases {
            #expect(!animal.sfSymbol.isEmpty)
        }
    }

    @Test func allAnimalsHaveDisplayName() {
        for animal in AnimalAvatar.allCases {
            #expect(!animal.displayName.isEmpty)
            #expect(animal.displayName == animal.rawValue.capitalized)
        }
    }

    @Test func allAnimalsHaveGradientColors() {
        for animal in AnimalAvatar.allCases {
            #expect(animal.gradientColors.count == 2)
        }
    }
}

// MARK: - AvatarFrame Tests

struct AvatarFrameTests {

    @Test func allCasesExist() {
        #expect(AvatarFrame.allCases.count == 4)
    }

    @Test func allFramesHaveSFSymbol() {
        for frame in AvatarFrame.allCases {
            #expect(!frame.sfSymbol.isEmpty)
        }
    }

    @Test func allFramesHaveDisplayName() {
        for frame in AvatarFrame.allCases {
            #expect(!frame.displayName.isEmpty)
        }
    }

    @Test func allFramesHaveGradientColors() {
        for frame in AvatarFrame.allCases {
            #expect(frame.gradientColors.count == 2)
        }
    }
}
